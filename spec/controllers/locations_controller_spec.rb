require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LocationsController do
  describe "index" do
    it "should be successful" do
      get :index
      response.should be_success
    end
    it "should render index template" do
      get :index
      response.should render_template(:index)
    end
    it "should set the locations" do
      get :index
      assigns[:locations].should_not be_nil
    end
  end
end