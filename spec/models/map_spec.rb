require 'spec_helper'

describe Map do
  it "should be allowed to have map guides" do
    map = Map.create(:url=>'foo', :description=>'bar', :library_id => 'lib2')
    location = Location.create
    call_number_ranges = [
        CallNumberRange.new(:location => location, :map => map, :call_number_range => '-'),
        CallNumberRange.new(:location => location, :map => map, :call_number_range => '-'),
        CallNumberRange.new(:location => location, :map => map, :call_number_range => '-')
    ]
    map.call_number_ranges = call_number_ranges
    map.should be_valid  
  end
  it "should destroy its map guides when it is destroyed" do    
    map = Map.create(:url=>'foo', :description=>'bar', :library_id => 'lib2')
    location = Location.create
    call_number_range = CallNumberRange.create(:location => location, :map => map, :call_number_range => '-')
    map.call_number_ranges = [call_number_range]
    lambda {map.destroy}.should change(CallNumberRange, :count).by(-1)
  end
  it "is valid with valid attributes" do
    Map.new(:url => 'foo', :description => 'bar', :library_id => 'lib2').should be_valid
  end
  it "is not valid without a url" do
    map = Map.new(:url => nil, :description => 'bar', :library_id => 'lib2')
    map.should_not be_valid
  end
  it "is not valid without a description" do
    map = Map.new(:url => 'foo', :description => nil, :library_id => 'lib2')
    map.should_not be_valid
  end
  it "is not valid without a library_id" do
    map = Map.new(:url => nil, :description => 'bar', :library_id => nil)
    map.should_not be_valid
  end
  
  describe "find best map" do
    it "should return the first of the matched guides" do
      lib = Library.new(:name => 'ALDERMAN')
      map = Map.new(:url => 'foo', :description => 'blah', :library_id => lib.id)
      map2 = Map.new(:url => 'foo2', :description => 'blah2', :library_id => lib.id)  
      holding = mock("Holding")
      holding.stubs(:library).returns(lib)
      CallNumberRange.stubs(:location_and_call_number_match).returns([map, map2])
      Map.find_best_map(holding, 'XYZ.123').should == map
    end
  end
  
end