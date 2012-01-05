require 'spec_helper'

describe MapsUsersController do
  before(:each) do
    user = User.create(:login => 'mst3k')
    controller.stubs(:current_user).returns user
    maps_user = MapsUser.create(:id => user.id)
    MapsUser.stubs(:find_by_computing_id).returns maps_user
  end
  
  describe "index action" do
    describe "index action" do
      it "should be successful" do
        get :index
        response.should be_success
      end
      it "should render index template" do
        get :index
        response.should render_template(:index)
      end
      it "should assign a maps users variable" do
        get :index
        assigns[:maps_users].should_not be_nil
      end
    end
  end
  
  describe "destroy action" do
    it "should delete the maps user" do
      @maps_user = MapsUser.create(:computing_id => "mst3k")
      lambda {delete :destroy, :id => @maps_user.id}.should change(MapsUser, :count).by(-1)
    end
  end
  
  describe "create action" do
    it "should create a maps user" do
      post :create
      assigns[:maps_user].should_not be_nil
    end
    it "should save successfully" do
      post :create, :maps_user=>{:computing_id => "mst3k"}
      flash[:notice].should == 'Maps user succesfully created'
      response.should redirect_to maps_users_path
    end
    it "should redirect to new maps user if it didn't save correctly" do
      @maps_user = mock("MapsUser")
      MapsUser.stubs(:new).returns(@maps_user)
      @maps_user.stubs(:save).returns(false)
      post :create
      response.should render_template(:new)
    end
  end
  

  

  
end