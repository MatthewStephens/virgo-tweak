# A map guide is an association between a map with a call number range and/or location.
# The map guides controller is for map administrators to maintain the map guides data.
class MapGuidesController < ApplicationController
  
  before_filter :verify_map_user
  
  # entry point for making a new map guide
  def new
    @map_guide = MapGuide.new(:map_id => params[:map_id])
    @maps = Map.find(:all, :order => :description)
    @locations = Location.find(:all, :order => :code)
  end
  
  # creates a map guide
  def create
    @map_guide = MapGuide.new(params[:map_guide])
    respond_to do |format|
      if @map_guide.save
        flash[:notice] = 'Entry successfully saved'
        format.html { redirect_to maps_path }
      else
        @maps = Map.find(:all, :order => :description)
        @locations = Location.find(:all, :order => :code)
        format.html { render :action => 'new' }
      end
    end
  end

  # edit a map guide
  def edit
    @map_guide = MapGuide.find(params[:id])
    @maps = Map.find(:all, :order => :description)
    @locations = Location.find(:all, :order => :code)
  end
  
  # update a map guide
  def update
    @map_guide = MapGuide.find(params[:id])
    respond_to do |format|
      if @map_guide.update_attributes(params[:map_guide])
        flash[:notice] = 'Entry was successfully updated'
        format.html { redirect_to(maps_path) }
      else
        format.html { render :action => 'edit' }
      end
    end
  end
  
  # delete a map guide
  def destroy
    @map_guide = MapGuide.find(params[:id])
    @map_guide.destroy
    respond_to do |format|
      format.html { redirect_to(maps_path) }
    end
  end
  
end