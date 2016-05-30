class ElasticsearchPluginController < ApplicationController
  no_design_blocks

  def index
    search()
    render :action => 'search'
  end

  def search
    @results = []
    @query = params[:q]
    @checkbox = {}

    if params[:model].present?
      params[:model].keys.each do |model|
        model = model.singularize
        @checkbox[model.to_sym] = true
        klass = model.classify.constantize
        query = get_query params[:q], klass

        @results |= klass.__elasticsearch__.search(query).records.to_a
        puts "="*80
        puts @results.inspect
      end
    end

  end

  private

  def get_query text, klass
    query = {}
    unless text.blank?
    puts "="*80

       fields = klass::SEARCHABLE_FIELDS.map do |key, value|
         if value[:weight]
           "#{key}^#{value[:weight]}"
         else
           "#{key}"
         end
       end

       query = {
           query: {
               regexp: {
                   name: {
                     value: "*" + text + "*"

                   }
                 }
               }
       }
    end
    puts "="*80
    puts query.inspect
    query
  end

  def get_terms params
    terms = {}
    return terms unless params[:filter].present?
    params[:filter].keys.each do |model|
      terms[model] = {}
      params[:filter][model].keys.each do |filter|
        @checkbox[filter.to_sym] = true
        terms[model][params[:filter][model.to_sym][filter]] = filter
      end
    end
    terms
  end
end
