class ReservesController < ApplicationController

  include Firehose::Reserves
  include UVA::SolrHelperOverride
  
  def index
    if params[:computing_id]
      @reserves = get_reserves(params[:computing_id])
      flash[:error] = "No reserves found for #{params[:computing_id]}" if @reserves.courses.count == 0
    end
  end
  
  def course
    @reserves = get_reserves_for_course(params[:computing_id], params[:key])
    ids = []
    @reserves.courses.each do |course|
      course.reserves.each do |reserve|
        ids << "u#{reserve.catalog_item.key}"
      end
    end
    @response, @document_list = get_solr_response_for_field_values("id", ids)
  end
  
end