module ElasticsearchIndexedModel

  def self.included base
    base.send :include, Elasticsearch::Model
    base.send :index_name, "#{Rails.env}_#{base.index_name}"
    base.extend ClassMethods
    base.class_eval do
      settings index: { number_of_shards: 1 } do
        mappings dynamic: 'false' do
          base.indexable_fields.each do |field, value|
            value = {} if value.nil?
            indexes field, type: value[:type].presence, fields: {"raw" =>
                                                                 {"index" => "not_analyzed",
                                                                  "type" => "String"
                                                                 }  }
            print '.'
          end
        end

        base.__elasticsearch__.client.indices.delete \
          index: base.index_name rescue nil
        base.__elasticsearch__.client.indices.create \
          index: base.index_name,
          body: {
            settings: base.settings.to_hash,
            mappings: base.mappings.to_hash
          }
      end
    end
   base.send :import
  end

  module ClassMethods
    def indexable_fields
      self::SEARCHABLE_FIELDS.merge self.control_fields
    end
  end

end
