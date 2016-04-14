require_dependency 'community'

require 'elasticsearch/model'

Community.class_eval do
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  def self.search(query)
    __elasticsearch__.search(
      {
        query: {
          multi_match: {
            query: query,
            fields: ['name', 'identifier']
          }
        },
        highlight: {
          pre_tags: ['<em>'],
          post_tags: ['</em>'],
          fields: {
            name: {},
            identifier: {}
          }
        }
      }
    )
  end

  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :name, analyzer: 'english', index_options: 'offsets'
      indexes :identifier, analyzer: 'english'
    end
  end
end

Community.__elasticsearch__.client.indices.delete index: Community.index_name rescue nil

# Create the new index with the new mapping
Community.__elasticsearch__.client.indices.create \
  index: Community.index_name,
  body: { settings: Community.settings.to_hash, mappings: Community.mappings.to_hash }

# Index all Community records from the DB to Elasticsearch
Community.import
