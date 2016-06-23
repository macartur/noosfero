require_dependency 'event'
require_relative '../elasticsearch_indexed_model'

class Event
  def self.control_fields
    {
      :advertise => {},
      :published => {},
      :name => {type: "string", analyzer: "english", fields: {
      raw:{
        type: "string",
        index: "not_analyzed"
      }
    }}
    }
  end
  include ElasticsearchIndexedModel
end
