require 'spec_helper'

describe CallNumberRange do
  
  describe "call number parse" do
    it "should return two arrays, the first one of alphas, the second of number" do
      call_number = 'ABC123DEF456'
      parsed = CallNumberRange.call_number_parse(call_number)
      parsed.should == [['ABC', 'DEF'], ['123', '456']]
    end
  end
  
  describe "bounded?" do
    it "should be able to determine if a prefix is a lower bound for a call number" do
      CallNumberRange.bounded?('PRE', 'PRF', true).should be_true
      CallNumberRange.bounded?('PRE', 'PRE.1', true).should be_true
      CallNumberRange.bounded?('PRE123', 'PRE.1234', true).should be_true
    end
    it "should be able to determine if a prefix is not a lower bound for a call number" do
      CallNumberRange.bounded?('PRE', 'PRD', true).should be_false
      CallNumberRange.bounded?('PRE2', 'PRE.1', true).should be_false
      CallNumberRange.bounded?('PRE1234', 'PRE.122', true).should be_false
    end
    it "should be able to determine if a prefix is an upper bound for a call number" do
      CallNumberRange.bounded?('PRE2', 'PRE.1', false).should be_true
      CallNumberRange.bounded?('PRE11', "PRE.10", false).should be_true
      CallNumberRange.bounded?('PRF', 'PRE.1222', false).should be_true
    end
    it "should be able to determine if a prefix is not upper bound for a call number" do
      CallNumberRange.bounded?('PRE', 'PRF', false).should be_false
      CallNumberRange.bounded?('PRE1', 'PRE.2', false).should be_false
      CallNumberRange.bounded?('PRE11', 'PRE.2', false).should be_false
    end
  end
  
  describe "call number match" do
    it "should return an empty array if the map guides passed in is empty" do
      CallNumberRange.call_number_match('PRE.123', []).should be_empty
    end

    it "should return map guides where the call number is bounded by the map guide's call number range" do
      lib = Library.create(:name => "ALDERMAN")
      
      map = Map.create(:url => 'url', :description => 'desc', :library_id => lib.id)
      map2 = Map.create(:url => 'url2', :description => 'desc2', :library_id => lib.id)
      
      guide = CallNumberRange.new(:map_id => map.id, :call_number_range => 'AB - DF')
      guide2 = CallNumberRange.new(:map_id => map2.id, :call_number_range => 'Y - Z')
      
      map.call_number_ranges << guide
      map2.call_number_ranges << guide2
      
      CallNumberRange.call_number_match('CD.123', [map, map2]).should == [map]
    end
  end
  


end