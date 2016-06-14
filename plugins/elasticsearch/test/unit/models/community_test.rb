require "#{File.dirname(__FILE__)}/../../test_helper"

class CommunityTest < ElasticsearchTestHelper

  def indexed_models
    [Community, Person]
  end

  def setup
    @profile = create_user('testing').person
    super
  end

  should 'index custom fields for Event model' do
    community_cluster = Community.__elasticsearch__.client.cluster

    assert_not_nil Community.mappings.to_hash[:community][:properties][:name]
    assert_not_nil Community.mappings.to_hash[:community][:properties][:identifier]
    assert_not_nil Community.mappings.to_hash[:community][:properties][:nickname]
  end
end
