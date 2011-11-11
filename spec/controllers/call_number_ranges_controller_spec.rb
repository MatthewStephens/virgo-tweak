require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CallNumberRangesController do

  before(:each) do
    controller.stubs(:verify_map_user).returns(true)
  end


  describe "create" do
    before(:each) do
      @valid_map_attrs = { :map_id => '3', :call_number_range => 'P-PR', :location => 'ALDERMAN'}
    end
    it "should save a valid map and redirect to maps path" do
      post :create,  @valid_map_attrs
      flash[:notice].should == 'Entry successfully saved'
      response.should redirect_to maps_path
    end
  end
  
  
  describe "destroy" do
    it "should delete the call number ange and redirect to maps path" do
      @call_number_range = CallNumberRange.create(:map_id => '3', :call_number_range => 'P-PR', :location => 'CLEMONS')
      lambda {delete :destroy, :id => @call_number_range.id}.should change(CallNumberRange, :count).by(-1)
      response.should redirect_to maps_path
    end
    
  end

end