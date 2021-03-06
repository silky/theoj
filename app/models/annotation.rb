class Annotation < ActiveRecord::Base
  include AASM

  belongs_to :paper
  belongs_to :user

  has_many :responses, :class_name => "Annotation", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Annotation", :foreign_key => "parent_id"

  scope :root_annotations , -> { where(parent_id: nil) }

  validates_presence_of :body, :paper_id

  aasm column: :state, no_direct_assignment:true do
    state :unresolved,       initial:true
    state :resolved
    state :disputed

    event :unresolve, guard: :can_change_state? do
      transitions to: :unresolved
    end

    event :resolve, guard: :can_change_state? do
      transitions to: :resolved
    end

    event :dispute, guard: :can_change_state? do
      transitions to: :disputed
    end

  end

  def is_issue?
    parent_id.nil?
  end

  def has_responses?
    responses.any?
  end

  private

  def can_change_state?
    is_issue? && paper && paper.under_review?
  end

end
