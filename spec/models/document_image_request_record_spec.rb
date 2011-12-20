require 'spec_helper'

describe DocumentImageRequestRecord do
  
  describe "delete_old_requests" do
    it "should throw an ArgumentError if days_old is not a number" do
      lambda { DocumentImageRequestRecord.delete_old_requests("blah") }.should raise_error(ArgumentError)
    end
    it "should throw an ArgumentError if days_old is equal to 0" do
      lambda { DocumentImageRequestRecord.delete_old_requests(0) }.should raise_error(ArgumentError)
    end
    it "should throw an ArgumentError if days_old is less than 0" do
      lambda { DocumentImageRequestRecord.delete_old_requests(-1) }.should raise_error(ArgumentError)
    end
    it "should destroy requests older than X days" do
      DocumentImageRequestRecord.destroy_all
      days_old = 7
      request_today = DocumentImageRequestRecord.create(:document_id => 'u2', :requested_at => Date.today)
      request_past = DocumentImageRequestRecord.create(:document_id => 'u3', :requested_at => Date.today - (days_old + 1).days)
      lambda do
        DocumentImageRequestRecord.delete_old_requests(days_old)
      end.should change(DocumentImageRequestRecord, :count).by(-1)
    end
    
  end
  
end
