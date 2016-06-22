module ElasticsearchHelper

  def self.searchable_types
    {
     :all              => { label: _("All Results")},
     :text_article     => { label: _("Articles")},
     :uploaded_file    => { label: _("Files")},
     :community        => { label: _("Communities")},
     :event            => { label: _("Events")},
     :person           => { label: _("People")}
    }
  end

  def self.search_filters
    {
     :lexical => { label: _("Alphabetical Order")},
     :recent => { label: _("More Recent Order")},
     :access => { label: _("More accessed")}
    }
  end

  def fields_from_models klasses
    fields = Set.new
    klasses.each do |klass|
      klass::SEARCHABLE_FIELDS.map do |key, value|
        if value and value[:weight]
          fields.add "#{key}^#{value[:weight]}"
        else
          fields.add "#{key}"
        end
      end
    end
    fields.to_a
  end

  def process_results
    selected_type = (params[:selected_type]|| :all).to_sym
    if  selected_type == :all
      search_from_all_models
    else
      search_from_model selected_type
    end
  end

  def search_from_all_models
    query = get_query params[:query]
    models = searchable_models
    Elasticsearch::Model.search(query, models, size: default_per_page(params[:per_page])).page(params[:page]).records
  end

  def search_from_model model
    begin
      klass = model.to_s.classify.constantize
      query = get_query params[:query], klass
      klass.search(query, size: default_per_page(params[:per_page])).page(params[:page]).records
    rescue
      []
    end
  end

  def default_per_page per_page
    per_page ||= 10
  end

  private
  
  def searchable_models
    SEARCHABLE_TYPES.except(:all).keys.map { | model | model.to_s.classify.constantize }
  end

  def query_method expression, fields
    query_exp = {}
    if expression.blank?
      query_exp = {
        match_all: {}
      }
    else
      query_exp = {
        multi_match: {
          query: expression,
          type: "phrase",
          fields: fields,
          zero_terms_query: "none"
        }
      }
    end
    query_exp
  end

  def get_query text="", klass=nil
    fields = klass.nil? ? (fields_from_models searchable_models) : (fields_from_models [klass])
    query = {
      query: query_method(text, fields),
      sort: [
        {"name.raw" => {"order" => "asc"}}
    ],
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
    query
  end

end
