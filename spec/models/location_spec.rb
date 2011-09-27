require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Location do
  
  it "should be able to have map guides" do
    location = Location.create
    map = Map.create(:url=>'foo', :description=>'bar')
    map_guides = [
      MapGuide.new(:location => location, :map => map, :call_number_range => '-'),
      MapGuide.new(:location => location, :map => map, :call_number_range => '-'),
      MapGuide.new(:location => location, :map => map, :call_number_range => '-')
    ]
    location.map_guides = map_guides
    location.should be_valid
  end
  
end