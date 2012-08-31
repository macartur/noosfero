class MezuroPluginMyprofileController < ProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../views')

 
  def choose_base_tool
    @configuration_content = profile.articles.find(params[:id])
    @base_tools = Kalibro::BaseTool.all_names
  end

  def choose_metric
    @configuration_content = profile.articles.find(params[:id])
    @base_tool = params[:base_tool]
    @supported_metrics = Kalibro::BaseTool.find_by_name(@base_tool).supported_metrics
  end
  
  def new_metric_configuration
    @configuration_content = profile.articles.find(params[:id])
    @metric = Kalibro::BaseTool.find_by_name(params[:base_tool]).metric params[:metric_name]
  end
  
  def new_compound_metric_configuration
    @configuration_content = profile.articles.find(params[:id])
    @metric_configurations = @configuration_content.metric_configurations
  end
  
  def edit_metric_configuration
    @configuration_content = profile.articles.find(params[:id])
    @metric_configuration = Kalibro::MetricConfiguration.find_by_configuration_name_and_metric_name(@configuration_content.name, params[:metric_name])
    @metric = @metric_configuration.metric
  end

  def edit_compound_metric_configuration
    @configuration_content = profile.articles.find(params[:id])
    @metric_configuration = Kalibro::MetricConfiguration.find_by_configuration_name_and_metric_name(@configuration_content.name, params[:metric_name])
    @metric_configurations = @configuration_content.metric_configurations
    @metric = @metric_configuration.metric
  end
  
  def create_metric_configuration
    id = params[:id]
    metric_name = params[:metric_configuration][:metric][:name]
    (Kalibro::MetricConfiguration.new(params[:metric_configuration])).save
    redirect_to "/myprofile/#{profile.identifier}/plugin/mezuro/edit_metric_configuration?id=#{id}&metric_name=#{metric_name.gsub(/\s/, '+')}"
  end
  
  def create_compound_metric_configuration
    id = params[:id]
    metric_name = params[:metric_configuration][:metric][:name]
    Kalibro::MetricConfiguration.new(params[:metric_configuration]).save
    redirect_to "/myprofile/#{profile.identifier}/plugin/mezuro/edit_compound_metric_configuration?id=#{id}&metric_name=#{metric_name.gsub(/\s/, '+')}"
  end

  def update_metric_configuration
    @configuration_content = profile.articles.find(params[:id])
    metric_name = params[:metric_configuration][:metric][:name]
    metric_configuration = Kalibro::MetricConfiguration.find_by_configuration_name_and_metric_name(@configuration_content.name, metric_name)
    metric_configuration.update_attributes params[:metric_configuration]
    redirect_to "/#{profile.identifier}/#{@configuration_content.slug}"
  end

  def update_compound_metric_configuration
    @configuration_content = profile.articles.find(params[:id])
    metric_name = params[:metric_configuration][:metric][:name]
    metric_configuration = Kalibro::MetricConfiguration.find_by_configuration_name_and_metric_name(@configuration_content.name, metric_name)
    metric_configuration.update_attributes params[:metric_configuration]
    redirect_to "/#{profile.identifier}/#{@configuration_content.slug}"
  end

  def remove_metric_configuration
    configuration_content = profile.articles.find(params[:id])
    metric_name = params[:metric_name]
    metric_configuration = Kalibro::MetricConfiguration.find_by_configuration_name_and_metric_name(configuration_content.name, metric_name)
    metric_configuration.destroy
    redirect_to "/#{profile.identifier}/#{configuration_content.slug}"
  end
  
  def new_range
    @configuration_content = profile.articles.find(params[:id])
    @metric_name = params[:metric_name]
    @range = Kalibro::Range.new
  end
  
  def edit_range
    @configuration_content = profile.articles.find(params[:id])
    @metric_name = params[:metric_name]
    @beginning_id = params[:beginning_id]
    metric_configuration = Kalibro::MetricConfiguration.find_by_configuration_name_and_metric_name(@configuration_content.name, @metric_name)
    @range = metric_configuration.ranges.find{|range| range.beginning == @beginning_id.to_f || @beginning_id =="-INF" }
  end

  def create_range
    @configuration_content = profile.articles.find(params[:id])
    @range = Kalibro::Range.new params[:range]
    metric_name = params[:metric_name]
    metric_configuration = Kalibro::MetricConfiguration.find_by_configuration_name_and_metric_name(@configuration_content.name, metric_name)   
    metric_configuration.add_range(@range)
    metric_configuration.save
  end
  
  def update_range
    configuration_content = profile.articles.find(params[:id])
    metric_name = params[:metric_name]
    beginning_id = params[:beginning_id]
    metric_configuration = Kalibro::MetricConfiguration.find_by_configuration_name_and_metric_name(configuration_content.name, metric_name)
    index = metric_configuration.ranges.index{ |range| range.beginning == beginning_id.to_f || beginning_id == "-INF" }
    metric_configuration.ranges[index] = Kalibro::Range.new params[:range]
    metric_configuration.save
  end
  
  def remove_range
    configuration_content = profile.articles.find(params[:id])
    metric_name = params[:metric_name]
    beginning_id = params[:beginning_id]
    metric_configuration = Kalibro::MetricConfiguration.find_by_configuration_name_and_metric_name(configuration_content.name, metric_name)
    metric_configuration.ranges.delete_if { |range| range.beginning == beginning_id.to_f || beginning_id == "-INF" }
    metric_configuration.save
    formatted_metric_name = metric_name.gsub(/\s/, '+')
    if metric_configuration.metric.class == Kalibro::CompoundMetric
      redirect_to "/myprofile/#{profile.identifier}/plugin/mezuro/edit_compound_metric_configuration?id=#{configuration_content.id}&metric_name=#{formatted_metric_name}"
    else
      redirect_to "/myprofile/#{profile.identifier}/plugin/mezuro/edit_metric_configuration?id=#{configuration_content.id}&metric_name=#{formatted_metric_name}"
    end
  end

end