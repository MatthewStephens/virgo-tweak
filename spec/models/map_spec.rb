require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Map do
  it "should be allowed to have map guides" do
    map = Map.create(:url=>'foo', :description=>'bar')
    location = Location.create
    map_guides = [
        MapGuide.new(:location => location, :map => map, :call_number_range => '-'),
        MapGuide.new(:location => location, :map => map, :call_number_range => '-'),
        MapGuide.new(:location => location, :map => map, :call_number_range => '-')
    ]
    map.map_guides = map_guides
    map.should be_valid  
  end
  it "should destroy its map guides when it is destroyed" do    
    map = Map.create(:url=>'foo', :description=>'bar')
    location = Location.create
    map_guide = MapGuide.create(:location => location, :map => map, :call_number_range => '-')
    map.map_guides = [map_guide]
    lambda {map.destroy}.should change(MapGuide, :count).by(-1)
  end
  it "is valid with valid attributes" do
    Map.new(:url => 'foo', :description => 'bar').should be_valid
  end
  it "is not valid without a url" do
    map = Map.new(:url => nil, :description => 'bar')
    map.should_not be_valid
  end
  it "is not valid without a description" do
    map = Map.new(:url => 'foo', :description => nil)
    map.should_not be_valid
  end

  
end