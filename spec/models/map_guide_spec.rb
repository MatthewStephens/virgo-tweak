require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MapGuide do
  
  describe "adjust call number range" do
    it "should make a blank call number range be a dash" do
      map_guide = MapGuide.new(:call_number_range => '')
      map_guide.adjust_call_number_range
      map_guide.call_number_range.should == '-'
    end
    it "should not alter a non-blank call number range" do
      map_guide = MapGuide.new(:call_number_range => 'xxx')
      map_guide.adjust_call_number_range
      map_guide.call_number_range.should == 'xxx'
    end
    it "should adjust call number before saving" do
      location = Location.create
      map = Map.create(:url => 'foo', :description => "test")
      map_guide = MapGuide.new(:location => location, :map => map, :call_number_range => '')
      map_guide.save
      map_guide.call_number_range.should == '-'
    end
  end
  
  describe "call number parse" do
    it "should return two arrays, the first one of alphas, the second of number" do
      call_number = 'ABC123DEF456'
      parsed = MapGuide.call_number_parse(call_number)
      parsed.should == [['ABC', 'DEF'], ['123', '456']]
    end
  end
  
  describe "bounded?" do
    it "should be able to determine if a prefix is a lower bound for a call number" do
      MapGuide.bounded?('PRE', 'PRF', true).should be_true
      MapGuide.bounded?('PRE', 'PRE.1', true).should be_true
      MapGuide.bounded?('PRE123', 'PRE.1234', true).should be_true
    end
    it "should be able to determine if a prefix is not a lower bound for a call number" do
      MapGuide.bounded?('PRE', 'PRD', true).should be_false
      MapGuide.bounded?('PRE2', 'PRE.1', true).should be_false
      MapGuide.bounded?('PRE1234', 'PRE.122', true).should be_false
    end
    it "should be able to determine if a prefix is an upper bound for a call number" do
      MapGuide.bounded?('PRE2', 'PRE.1', false).should be_true
      MapGuide.bounded?('PRE11', "PRE.10", false).should be_true
      MapGuide.bounded?('PRF', 'PRE.1222', false).should be_true
    end
    it "should be able to determine if a prefix is not upper bound for a call number" do
      MapGuide.bounded?('PRE', 'PRF', false).should be_false
      MapGuide.bounded?('PRE1', 'PRE.2', false).should be_false
      MapGuide.bounded?('PRE11', 'PRE.2', false).should be_false
    end
  end
  
  describe "call number match" do
    it "should return an empty array if the map guides passed in is empty" do
      MapGuide.call_number_match('PRE.123', []).should be_empty
    end
    it "should return if the call number range doesn't contain a '-'" do
      guide_with_invalid_range = MapGuide.new(:map_id => '1', :call_number_range => 'foo')
      MapGuide.call_number_match('PRE.123', [guide_with_invalid_range]).should be_empty
    end
    it "should return map guides where the call number is bounded by the map guide's call number range" do
      guide = MapGuide.new(:map_id => '1', :call_number_range => 'AB - DF')
      guide2 = MapGuide.new(:map_id => '2', :call_number_range => 'Y - Z')
      MapGuide.call_number_match('CD.123', [guide]).should == [guide]
    end
  end
  
  describe "find best map" do
    it "should return nil if the call number is nil" do
      MapGuide.find_best_map('ALD', nil).should be_nil
    end
    it "should return the first of the matched guides" do
      guide1 = MapGuide.new(:map_id => '1', :call_number_range => 'a-z')
      guide2 = MapGuide.new(:map_id => '2', :call_number_range => 'a-z')
      MapGuide.stubs(:find).returns([guide1, guide2])
      MapGuide.find_best_map('ALD', 'XYZ.123').should == guide1
    end
  end

end