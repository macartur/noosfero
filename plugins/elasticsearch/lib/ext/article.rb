require_dependency 'article'
require_relative '../elasticsearch_indexed_model'

class Article
  include ElasticsearchIndexedModel

  def self.control_fields
    [
      :advertise,
      :published,
    ]
  end

  def self.indexable_fields
    SEARCHABLE_FIELDS.keys + self.control_fields 
  end

end
