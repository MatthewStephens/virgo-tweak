require 'spec_helper'

describe Search do
  
  describe "delete_old_searches" do
    it "should throw an ArgumentError if days_old is not a number" do
      lambda { Search.delete_old_searches("blah") }.should raise_error(ArgumentError)
    end
    it "should throw an ArgumentError if days_old is equal to 0" do
      lambda { Search.delete_old_searches(0) }.should raise_error(ArgumentError)
    end
    it "should throw an ArgumentError if days_old is less than 0" do
      lambda { Search.delete_old_searches(-1) }.should raise_error(ArgumentError)
    end
    it "should destroy searches with no user_id that are older than X days" do
      Search.destroy_all
      days_old = 7
      unsaved_search_today = Search.create(:user_id => nil, :created_at => Time.now)
      unsaved_search_past = Search.create(:user_id => nil, :created_at => Time.now - (days_old + 1).days)
      saved_search_today = Search.create(:user_id => 1, :created_at => Time.now)
      saved_search_past = Search.create(:user_id => 1, :created_at => (Time.now - (days_old + 1).days))
      lambda do
        Search.delete_old_searches(days_old)
      end.should change(Search, :count).by(-1)
    end
    
  end
  
end
