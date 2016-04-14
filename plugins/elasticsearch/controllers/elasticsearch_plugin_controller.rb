class ElasticsearchPluginController < ApplicationController

  def communities
    @communities = environment.communities
  end
end
