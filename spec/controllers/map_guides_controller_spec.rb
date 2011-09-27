require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MapGuidesController do

  before(:each) do
    controller.stubs(:verify_map_user).returns(true)
  end

  describe "new" do
    it "should set up a new map guide, maps, and locations" do
      get :new, :map_id => '2'
      assigns[:map_guide].should_not be_nil
      assigns[:maps].should_not be_nil
      assigns[:locations].should_not be_nil
      response.should be_success
    end
    it "should use the new template" do
      get :new, :map_id => '2'
      response.should render_template(:new)
    end
  end

  describe "create" do
    before(:each) do
      @valid_map_attrs = { :map_id => '3', :call_number_range => 'P-PR', :location_id => '2'}
    end
    it "should save a valid map and redirect to maps path" do
      post :create, :map_guide => @valid_map_attrs
      flash[:notice].should == 'Entry successfully saved'
      response.should redirect_to maps_path
    end
    it "should render new if it doesn't save successfully" do
      MapGuide.stubs(:save).returns(false)
      post :create
      assigns[:map_guide].should_not be_nil
      assigns[:maps].should_not be_nil
      assigns[:locations].should_not be_nil
      response.should render_template(:new)
    end
  end
  
  describe "edit" do
    it "should set the map guide, maps, and locations" do
      @map_guide = MapGuide.create(:map_id => '3', :call_number_range => 'P-PR', :location_id => '2')
      get :edit, :id => @map_guide.id
      assigns[:map_guide].should_not be_nil
      assigns[:maps].should_not be_nil
      assigns[:locations].should_not be_nil
      response.should be_success
    end
  end
  
  describe "update" do
    before(:each) do
      @map_guide = MapGuide.create(:map_id => '3', :call_number_range => 'P-PR', :location_id => '2')
      @new_attributes = {:map_id => '3', :call_number_range => '-', :location_id => '2'}
    end
    it "should fetch the map guide" do
     put :update, :id => @map_guide.id, :map_guide => @new_attributes
     assigns[:map_guide].should_not be_nil
    end
    it "should update the attributes, set a notice, and redirect to maps path" do
      put :update, :id => @map_guide.id, :map_guide => @new_attributes
      flash[:notice].should ==  'Entry was successfully updated'
      response.should redirect_to maps_path
    end
  end
  
  describe "destroy" do
    it "should delete the map guide and redirect to maps path" do
      @map_guide = MapGuide.create(:map_id => '3', :call_number_range => 'P-PR', :location_id => '2')
      lambda {delete :destroy, :id => @map_guide.id}.should change(MapGuide, :count).by(-1)
      response.should redirect_to maps_path
    end
    
  end

end