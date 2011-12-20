require 'spec_helper'

describe ApplicationController do
  
  controller do
    before_filter :verify_map_user
    def index
      render :text => "blahblahblah"
    end
  end  
  
  describe "verify_map_user" do
    
    it "should set a flash error and redirect to root path if the current user is nil" do
      controller.stubs(:current_user).returns nil
      get :index
      flash[:error].should == 'You must be logged in to manage maps. <a href="/login?redirect=maps">Log in</a>'
      response.should redirect_to('/')
    end
    
    it "should set a flash error and redirect to root path if the user is not a maps user" do
      user = User.create(:login => 'not_map_user')
      controller.stubs(:current_user).returns user
      MapsUser.stubs(:find_by_computing_id).returns(nil)
      get :index
      flash[:error].should == 'You are not authorized to manage maps.'
      response.should redirect_to('/')
    end
    
    it "should not produce an error if it is a valid maps user" do
      user = User.create(:login => 'mst3k')
      controller.stubs(:current_user).returns user
      maps_user = mock("MapsUser")
      MapsUser.stubs(:find_by_computing_id).returns maps_user
      get :index
      flash[:error].should be_nil
    end  
    
  end
  
end