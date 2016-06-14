require "#{File.dirname(__FILE__)}/../../test_helper"

class EventTest < ElasticsearchTestHelper

  def indexed_models
    [Event]
  end

  def setup
    @profile = create_user('testing').person
    super
  end

  should 'index custom fields for Event model' do
    event_cluster = Event.__elasticsearch__.client.cluster

    assert_not_nil Event.mappings.to_hash[:event][:properties][:advertise]
    assert_not_nil Event.mappings.to_hash[:event][:properties][:published]
  end
end
