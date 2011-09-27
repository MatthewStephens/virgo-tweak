# Locations controller is only relevant for maps administrators.
class LocationsController < ApplicationController
    # lists all of the available locations to base a map on
    def index
      @locations = Location.find(:all, :order => :code)
    end
end