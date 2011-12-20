require 'spec_helper'

describe UserSessionsController do
  
  describe "new action" do
    it "should create a demo account if no user id is specified in the environment" do
      get :new
      session[:login].should == "demo_0"
      assigns[:user_session].should_not be_nil
    end
    it "should create an account based on the user id from the environment" do
      request.env['REMOTE_USER'] = "mst3k"
      get :new
      session[:login].should == "mst3k"
      assigns[:user_session].should_not be_nil
    end
    it "should use the login that is in session" do
      user = User.create(:login => "mst3k", :email => "mst3k@virginia.edu", :password => "password", :password_confirmation => "password")
      session[:login] = "mst3k"
      get :new
      session[:login].should == "mst3k"
      assigns[:user_session].should_not be_nil
    end
    it "should redirect to http from https" do
      get :new, :protocol => 'https'
      response.should redirect_to root_url(:protocol => 'http')
    end
    it "should redirect to maps url if specified" do
      get :new, :redirect => 'maps'
      response.should redirect_to maps_url
    end
    it "should redirect to special collections request url if specified" do
      get :new, :redirect => 'special_collections_user', :id => 'u850'
      response.should redirect_to new_special_collections_request_url(:id => 'u850', :qt => 'document')
    end
    it "should redirect to special collections admin if specified" do
      get :new, :redirect => 'special_collections_admin'
      response.should redirect_to special_collections_requests_url
    end
    it "should redirect to root url if no redirect string is supplied" do
      get :new
      response.should redirect_to root_url
    end
  end
  
  describe "destroy action" do
    it "should empty the session" do
      session[:login] = "mst3k"
      delete :destroy
      session.should be_empty
    end
    it "should keep special collections setting if specified" do
      session[:special_collections] = true
      delete :destroy
      session[:special_collections].should be_true
    end
    it "should redirect to http from https" do
      delete :destroy, :protocol => 'https'
      response.should redirect_to logged_out_url(:protocol => 'http')
    end

    describe "logged out action" do
      it "should use logged out template" do
        get :logged_out
        response.should render_template :logged_out
      end
    end

  end
  
end