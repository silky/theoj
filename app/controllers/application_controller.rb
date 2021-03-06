class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  # before_filter :require_user

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { render :json => {}, :status => :forbidden }
    end
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
  end

  rescue_from  Arxiv::Error::ManuscriptNotFound do render_error(:not_found) end

  rescue_from  ActiveRecord::RecordNotUnique do render_error(:conflict) end

  private

  def ability_with(user, paper=nil, annotation=nil)
    Ability.new(user, paper, annotation)
  end

  def etag(params, state)
    etag = Digest::MD5.hexdigest(TheOJVersion + params.inspect + state)
    headers['ETag'] = etag
  end

  def require_user
    render_error :forbidden unless current_user
  end

  def require_editor
    render_error :forbidden unless (current_user && current_user.editor?)
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def render_error(status_code)
    code    = Rack::Utils::SYMBOL_TO_STATUS_CODE[status_code]
    message = "#{code} #{Rack::Utils::HTTP_STATUS_CODES[code]}"

    respond_to do |format|
      format.html { render plain:message, status: status_code }
      format.json { render json: {error:message}, status: status_code }
    end

  end

end
