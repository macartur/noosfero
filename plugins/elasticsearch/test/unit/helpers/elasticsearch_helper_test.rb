require "#{File.dirname(__FILE__)}/../../test_helper"
require_relative '../../../helpers/elasticsearch_helper.rb'

class ElasticsearchHelperTest < ActiveSupport::TestCase

  include ElasticsearchTestHelper
  include ElasticsearchHelper

  attr_accessor :params

  def indexed_models
    [Person,TextArticle,UploadedFile,Community,Event]
  end

  def create_instances
    create_user "Jose Abreu"
    create_user "Joao Abreu"
    create_user "Joana Abreu"
    create_user "Ana Abreu"
  end

  should 'return default_per_page when nil is passed' do
    assert_not_nil default_per_page nil
    assert_equal 10, default_per_page(nil)
  end

  should 'return default_per_page when per_page is passed' do
    assert_equal 15, default_per_page(15)
  end

  should 'have indexed_models in searchable_models' do
    assert_equivalent indexed_models, searchable_models
  end

  should 'return match_all if expression is blank' do
    assert_includes query_method.keys, :match_all
  end

  should 'return multi_match if expression is valid' do

    query= "my_query"
    fields = ['name','login']
    result = query_method(query,fields)

    assert_includes result.keys, :multi_match
    assert_includes result[:multi_match][:query], query
    assert_equivalent result[:multi_match][:fields], fields
  end


  should 'return fields from models using weight' do
    class StubClass
      SEARCHABLE_FIELDS = {:name  => {:weight => 10},
                           :login =>  {:weight => 20},
                           :description => {:weight => 2}}
    end

    expected = ["name^10", "login^20", "description^2"]
    assert_equivalent expected, fields_from_models([StubClass])
  end

  should 'search from model Person sorted by Alphabetic' do
    self.params= {:selected_type => 'person',
                  :selected_filter => 'lexical',
                  :per_page => 4}

    result = process_results
    assert_equal ["Ana Abreu","Joana Abreu","Joao Abreu","Jose Abreu"], result.map(&:name)
  end

  should 'search from model Person sorted by More Recent' do
    self.params= {:selected_type => 'person',
                  :selected_filter => 'more_recent',
                  :per_page => 4}

    result = process_results
    assert_equal ["Jose Abreu","Joao Abreu","Joana Abreu","Ana Abreu"],result.map(&:name)
  end

  should 'search from model Person sorted by Relevance' do
    self.params= {:selected_type => 'person',
                  :selected_filter => 'more_recent',
                  :query => 'JOAO ABREU',
                  :per_page => 4}

    result = process_results
    assert_equal ["Joao Abreu","Jose Abreu","Joana Abreu","Ana Abreu"],result.map(&:name)
  end

end
