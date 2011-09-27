# Maps users is for maintaining the list of people who are allowed to administer maps.
class MapsUsersController < ApplicationController
  
  before_filter :verify_map_user
  
  # list the map users
  def index
    @maps_users = MapsUser.find(:all)
  end
  
  # start a new map user
  def new
    @maps_user = MapsUser.new
  end
  
  # create a new map user
  def create
    @maps_user = MapsUser.new(params[:maps_user])
    respond_to do |format|
      if @maps_user.save
        flash[:notice] = 'Maps user succesfully created'
        format.html { redirect_to(maps_users_path) }
      else
        format.html { render :action => 'new' }
      end
    end
  end
  
  # delete a map user
  def destroy
     @maps_user = MapsUser.find(params[:id])
     @maps_user.destroy
     respond_to do |format|
       format.html { redirect_to(maps_users_url) }
     end
   end

end