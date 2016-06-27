require_relative '../helpers/elasticsearch_helper'

class ElasticsearchPluginController < ApplicationController
  no_design_blocks
  include ElasticsearchHelper

  def index
    search()
    render :action => 'search'
  end

  def search
    define_searchable_types
    define_search_fields_types
    define_results
  end

  def define_results
    @query = params[:query]
    @results = process_results
  end

  def define_searchable_types
    @searchable_types = ElasticsearchHelper::searchable_types
    @selected_type = (params[:selected_type]|| :all ).to_sym
  end

  def define_search_fields_types
    @search_filter_types = ElasticsearchHelper::search_filters
    @selected_filter_field = (params[:selected_filter_field] || :relevance).to_sym
  end
end
