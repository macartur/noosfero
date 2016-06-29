require_dependency 'text_article'
require_relative '../elasticsearch_indexed_model'

class TextArticle
  def self.control_fields
    {
      :advertise => {},
      :published => {},
      :created_at => {type: 'date'}
    }
  end
  include ElasticsearchIndexedModel
end
