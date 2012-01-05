require 'spec_helper'

describe SpecialCollectionsRequest do

  it "is valid with valid attributes" do
    SpecialCollectionsRequest.new(:user_id => 'foo').should be_valid
  end
  it "is not valid without a user_id" do
    SpecialCollectionsRequest.new(:user_id => nil).should_not be_valid
  end
  it "should be allowed to have special collections request items" do
    item1 = SpecialCollectionsRequestItem.new
    item2 = SpecialCollectionsRequestItem.new
    request = SpecialCollectionsRequest.new(:user_id => 'foo')
    request.special_collections_request_items = [item1, item2]
    request.special_collections_request_items.length.should == 2
  end
  it "should delete the request items when it is deleted" do
    item1 = SpecialCollectionsRequestItem.new
    item2 = SpecialCollectionsRequestItem.new
    request = SpecialCollectionsRequest.create(:user_id => 'foo', :special_collections_request_items => [item1, item2])
    lambda { SpecialCollectionsRequest.destroy(request.id) }.should change(SpecialCollectionsRequestItem, :count).by(-2)
  end
  it "should have processed_at be nil if it has never been updated" do
    request = SpecialCollectionsRequest.create(:user_id => 'foo')
    request.processed_at.should be_nil
  end
  it "should set processed_at when it is updated" do
    request = SpecialCollectionsRequest.create(:user_id => 'foo')
    request.user_id = "bar"
    request.save
    request.processed_at.should_not be_nil
  end
  
  describe "build" do

    it "should not change the request if locations_with_call_numbers is nil or blank" do
      request = SpecialCollectionsRequest.create(:user_id => 'foo')
      request.build(nil)
      request.special_collections_request_items.should be_empty
      request.build([])
      request.special_collections_request_items.should be_empty
    end
    
    it "should build an item for each call number" do
      request = SpecialCollectionsRequest.create(:user_id => 'foo')
      request.build({"SC-STKS"=>{"X030761746"=>["PS3623 .R539 S48 2010"]}, 
                     "SC-BARR-X"=>{"X004958786"=>["MSS 6251 -- 6251-bn"], "X004958758"=>["MSS 6251 -- 6251-bn Box 2"]} })
      request.special_collections_request_items.length.should == 3
    end
    
    it "should build a properly mapped item" do
      request = SpecialCollectionsRequest.create(:user_id => 'foo')
      request.build({"SC-STKS"=>{"X030761746"=>["PS3623 .R539 S48 2010"]}})
      request.special_collections_request_items[0].location.should == "SC-STKS"
      request.special_collections_request_items[0].call_number.should == "PS3623 .R539 S48 2010"
      request.special_collections_request_items[0].barcode.should == "X030761746"
    end
  end

end