require 'spec_helper'

describe MapsController do
  before(:each) do
    user = User.create(:login => 'mst3k')
    controller.stubs(:current_user).returns user
    maps_user = MapsUser.create(:id => user.id)
    MapsUser.stubs(:find_by_computing_id).returns maps_user
  end
  
  describe "index action" do
    it "should be successful" do
      get :index
      response.should be_success
    end
    it "should render index template" do
      get :index
      response.should render_template(:index)
    end
    it "should assign a maps variable" do
      get :index
      assigns[:maps].should_not be_nil
    end
  end
  
  describe "destroy action" do
    it "should delete the map" do
      @map = Map.create(:url => "http://mymap.com", :description => "test map", :library_id => "ald")
      lambda {delete :destroy, :id => @map.id}.should change(Map, :count).by(-1)
    end
  end
  
  describe "new action" do
    it "should set a new map" do
      get :new
      assigns[:map].should_not be_nil
    end
  end
  
  describe "create action" do
    it "should create a map object" do
      post :create
      assigns[:map].should_not be_nil
    end
    it "should save successfully" do
      post :create, :map=>{:url=>"http://www.mymap.com", :description=>"test map", :library_id => "ald"}
      flash[:notice].should == 'Map succesfully created'
      response.should redirect_to maps_path
    end
    it "should redirect to new map if it didn't save correctly" do
      post :create
      response.should render_template(:new)
    end
  end
  
  describe "edit action" do
    before(:each) do
      Map.stubs(:find).returns(mock("Map"))
    end
    it "should fetch the map" do
      get :edit, :id => 1
      assigns[:map].should_not be_nil
    end
    it "should use the edit template" do
      get :edit, :id => 1
      response.should render_template(:edit)
    end
  end
  
  describe "update action" do
    before(:each) do
      @map = Map.create(:url => "http://mymap.com", :description => "test map", :library_id => "ald")
      Map.stubs(:find).returns(@map)
    end
    it "should fetch the map" do
      put :update, :id => 1
      assigns[:map].should_not be_nil
    end
    it "should redirect to maps path with notice upon successful update" do
      put :update, :id => 1
      flash[:notice].should == 'Map was successfully updated'
      response.should redirect_to(maps_path)
    end
    it "should render edit action if update not successful" do
      @map.stubs(:valid?).returns(false)
      put :update, :id => 1
      response.should render_template(:edit)
    end
  end
  

  

end