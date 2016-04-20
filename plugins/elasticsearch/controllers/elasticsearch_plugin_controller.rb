class ElasticsearchPluginController < ApplicationController

  no_design_blocks
 
  def search
    @results = []

    @checkbox = {:articles => params[:articles].present?,
                 :communities => params[:communities].present?,
                 :people => params[:people].present?
                } 

    @results += Article.__elasticsearch__.search('{}').records.to_a if params[:articles]
    @results += Community.__elasticsearch__.search('{}').records.to_a if params[:communities]
    @results += Person.__elasticsearch__.search('{}').records.to_a if params[:people]
  end

end
