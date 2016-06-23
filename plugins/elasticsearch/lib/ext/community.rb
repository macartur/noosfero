require_dependency 'community'
require_relative '../elasticsearch_indexed_model'

class Community
  def self.control_fields
    {:name => {type: "string", analyzer: "english", fields: {
      raw:{
        type: "string",
        index: "not_analyzed"
      }
    }}}
  end
  include ElasticsearchIndexedModel
end
