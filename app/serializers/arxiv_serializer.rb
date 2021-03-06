# Serialize a Paper in the Arxiv format

class ArxivSerializer < ActiveModel::Serializer

  attributes :arxiv_url, :sha, :title, :summary, :links, :authors, :source, :self_owned

  def arxiv_url
    object.location.sub(/\.pdf$/,'')
  end

  def links
    [
        {
            url:          object.location,
            content_type: 'application/pdf'
        }
    ]
  end

  def authors
    object.author_list
  end

  def self_owned
    scope && scope == object.user
  end

  def source
    'theoj'
  end

end
