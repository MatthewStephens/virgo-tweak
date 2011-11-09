class CallNumberRangesController < ApplicationController
  
  before_filter :verify_map_user
  
  # entry point for making a new call number range
  def new
    @call_number_range = CallNumberRange.new(:map_id => params[:map_id])
  end
  
  # creates a call nuumber range
  def create
    @call_number_range = CallNumberRange.new(:call_number_range => params[:call_number_range], :map_id => params[:map_id])
    respond_to do |format|
      if @call_number_range.save
        flash[:notice] = 'Entry successfully saved'
        format.html { redirect_to maps_path }
      else
        format.html { render :action => 'new' }
      end
    end
  end
  
  # delete a call number range
  def destroy
    @call_number_range = CallNumberRange.find(params[:id])
    @call_number_range.destroy
    respond_to do |format|
      format.html { redirect_to(maps_path) }
    end
  end
  
end