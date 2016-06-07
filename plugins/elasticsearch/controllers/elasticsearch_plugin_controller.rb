class ElasticsearchPluginController < ApplicationController
  no_design_blocks

  SEARCHABLE_TYPES = { :all       => { label: _("All Results")},
                       :community => { label: _("Communities")},
                       :article   => { label: _("Articles")},
                       :event     => { label: _("Events")},
                       :person    => { label: _("People")}
                      }
  SEARCH_FILTERS = { :lexical => { label: _("Alphabetical Order")},
                     :recent => { label: _("More Recent Order")},
                     :access => { label: _("More accessed")}
                   }

  def index
    search()
    render :action => 'search'
  end

  def search
    @searchable_types = SEARCHABLE_TYPES
    @selected_type = selected_type params
    @search_filter_types = SEARCH_FILTERS

    @query = params[:q]
    @results = []

#    results 'article'
#    results 'people'
     results "community"
  end

  def selected_type params
    return :all if params[:selected_type].nil?
    params[:selected_type]
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
    klass = model.to_s.classify.constantize
    query = get_query params[:q], klass
    query = {}
    @results |= klass.__elasticsearch__.search(query).records.to_a
  end

end
