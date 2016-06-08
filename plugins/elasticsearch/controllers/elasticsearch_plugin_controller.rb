class ElasticsearchPluginController < ApplicationController
  no_design_blocks

  SEARCHABLE_TYPES = { :all       => { label: _("All Results")},
                       :community => { label: _("Communities")},
                       :event     => { label: _("Events")},
                       :person    => { label: _("People")}
                     }

  SEARCH_FILTERS   = { :lexical => { label: _("Alphabetical Order")},
                       :recent => { label: _("More Recent Order")},
                       :access => { label: _("More accessed")}
                     }

  def index
    search()
    render :action => 'search'
  end

  def search
    define_searchable_types
    define_search_fields_types

    @query = params[:q]
    @results = []

    if @selected_type == :all
      SEARCHABLE_TYPES.keys.each do |type|
         results type.to_s
      end
    else
      results @selected_type
    end
  end


  private

  def get_query text, klass
    query = {}
    unless text.blank?
       text = text.downcase
       fields = klass::SEARCHABLE_FIELDS.map do |key, value|
         if value[:weight]
           "#{key}^#{value[:weight]}"
         else
           "#{key}"
         end
       end

       query = {
         query: {
           match_all: {
           }
         },
         filter: {
           regexp: {
             name: {
               value: ".*" + text + ".*" }
           }
         },
         suggest: {
           autocomplete: {
             text: text,
             term: {
               field: "name",
               suggest_mode: "always"
             }
           }
         }

       }
    end
    query
  end

  def results model
    begin
      klass = model.to_s.classify.constantize
    rescue
      return
    end
    query = get_query params[:q], klass
    @results |= klass.__elasticsearch__.search(query).records.to_a
  end

  def define_searchable_types
    @searchable_types = SEARCHABLE_TYPES
    @selected_type = params[:selected_type].nil? ? :all : params[:selected_type].to_sym
  end

  def define_search_fields_types
    @search_filter_types = SEARCH_FILTERS
    @selected_filter_field = params[:selected_filter_field].nil? ? SEARCH_FILTERS.keys.first : params[:selected_filter_field].to_sym
  end

end
