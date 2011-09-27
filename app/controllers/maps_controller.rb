# A map is just a description and URL for a map.
# Maps controller is only used by map administrators for creating map guides.
class MapsController < ApplicationController
  
  before_filter :verify_map_user
  
  # list all of the maps
  def index
    @maps = Map.find(:all)
  end
  
  # start a new map
  def new
    @map = Map.new
  end
  
  # create a map
  def create
    @map = Map.new(params[:map])
    respond_to do |format|
      if @map.save
        flash[:notice] = 'Map succesfully created'
        format.html { redirect_to(maps_path) }
      else
        format.html { render :action => 'new' }
      end
    end
  end
  
  # edit a map
  def edit
    @map = Map.find(params[:id])
  end    
  
  # update a map
  def update
    @map = Map.find(params[:id])
    respond_to do |format|
      if @map.update_attributes(params[:map])
        flash[:notice] = 'Map was successfully updated'
        format.html { redirect_to(maps_path) }
      else
        format.html { render :action => 'edit' }
      end
    end
  end
  
  # delete a map
  def destroy
    @map = Map.find(params[:id])
    @map.destroy
    respond_to do |format|
      format.html { redirect_to(maps_url) }
    end
  end
end