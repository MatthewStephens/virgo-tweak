require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FeedbackController do

  it "should not produce an error if recaptcha is valid" do
    controller.stubs(:verify_recaptcha).returns(true)
    post :show, :name => "Joe", :email => "joe@user.com", :message => "blah"
    assigns[:errors].should be_empty
  end
  
  it "should produce an error if recaptcha is not valid" do
    controller.stubs(:verify_recaptcha).returns(false)
    post :show, :name => "Joe", :email => "joe@user.com", :message => "blah"
    assigns[:errors].size.should == 1
    assigns[:errors][0].should == "Text validation did not match"
  end

end