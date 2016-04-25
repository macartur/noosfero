class ElasticsearchPluginController < ApplicationController

  no_design_blocks
 
  def search
    @results = []
    @query = params[:q]
    @checkbox = {}
    if params[:model].present?
        params[:model].keys.each do |model|
            @checkbox[model.to_sym] = true
            klass = model.classify.constantize
            query = get_query params[:q], klass
            @results += klass.__elasticsearch__.search(query).records.to_a
        end
    end

  end

  private

  def get_query text, klass
    query = {}
    unless text.blank?

       fields = klass::SEARCHABLE_FIELDS.map {|k, v|  "#{k}^#{v[:weight]}"}

       query = {
           query: {
               multi_match: {
                   query: text,
                   fields: fields
               }
           }
       }
    end
    query
  end

end
