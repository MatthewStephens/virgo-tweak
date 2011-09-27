require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

# to do - remove dependencies on document (:id => "u4967160"), "u850", and user id "mpc3c"

describe SpecialCollectionsRequestsController do

  def login_user
    user = User.create(:login => "mpc3c", :email => "mpc3c@virginia.edu", :password => "password", :password_confirmation => "password")
    controller.stubs(:current_user).returns user
  end
  
  def authorize_admin
    login_user
    SpecialCollectionsUser.stubs(:find_by_computing_id).returns(true)
  end
  
  def dont_authorize_admin
    login_user
    SpecialCollectionsUser.stubs(:find_by_computing_id).returns(false)
  end
    
  describe "start action" do
    it "should bypass login if there is a current user" do
      login_user
      get :start, :id => "123"
      response.should redirect_to new_special_collections_request_path(:id => "123")
    end
    it "should create a request object" do
      get :start, :id => "123"
      assigns[:special_collections_request].should_not be_nil
    end
    it "should render the start template" do
      get :start, :id => "123"
      response.should render_template(:start)
    end
  end
  
  describe "non_uva action" do
    it "should create a request object" do
      get :non_uva, :id => "123"
      assigns[:special_collections_request].should_not be_nil
    end
    it "should render the non_uva template" do
      get :non_uva, :id => "123"
      response.should render_template(:non_uva)
    end
  end
  
  describe "new action" do
    describe "verify_user" do
      it "should set the user id from the current_user" do
        login_user
        get :new, :id => "u4967160"
        assigns[:special_collections_request].user_id.should == 'mpc3c'
      end
      it "should set the user id from a non-uva login" do
        controller.stubs(:uva_id?).returns(false)
        get :new, :id => "u4967160", :user_id => "blahblah"
        assigns[:special_collections_request].user_id.should == "blahblah"
      end
    end
    describe "uva_id" do
      it "should throw an error if a user supplies an id that is a U.Va. id" do
        pending("figure out how to stub the ldap call, since it fails some percentage of the time")
        get :new, :id => "u4967160", :user_id => "mpc3c"
        flash[:error].should == 'UVa members should use NetBadge to authenticate'
        response.should redirect_to start_special_collections_request_path(:id => "u4967160")
      end
    end
    describe "check login" do
      it "should check that there is a login" do
        get :new, :id => "u4967160"
        flash[:error].should == 'You must establish your identify before making a request.'
        response.should redirect_to start_special_collections_request_path(:id => "u4967160")
      end
    end
    describe "patron lookup" do
      it "should throw an error if there is no patron information" do
        controller.stubs(:uva_id?).returns(false)
        patron = mock_model(UVA::Patron)
        patron.stubs(:by_uid).returns("")
        UVA::Patron.stubs(:new).returns(patron)
        get :new, :id => "u4967160", :user_id => "blahblah"
        flash[:error].should == "Unable to locate your patron record.  Please verify your login information and try again."
        response.should redirect_to start_special_collections_request_path(:id => "u4967160")
      end
      it "should look up patron information" do
        login_user
        patron = mock_model(UVA::Patron)
        patron.stubs(:by_uid).returns("Pickral, Mary")
        UVA::Patron.stubs(:new).returns(patron)
        get :new, :id => "u4967160"
        assigns[:special_collections_request].name.should == "Pickral, Mary"
      end
      it "should fake looking up patron information for a demo account" do
        controller.stubs(:uva_id?).returns(false)
        get :new, :id => "u4967160", :user_id => "demo_1"
        assigns[:special_collections_request].name.should == "demo_1"   
      end
    end
    it "should create a request object" do
      login_user
      get :new, :id => "u4967160"
      assigns[:special_collections_request].should_not be_nil
    end
    it "should set a document with availability" do
      login_user
      get :new, :id => "u4967160"
      assigns[:special_collections_request].document.should_not be_nil
      assigns[:special_collections_request].document.availability.should_not be_nil
    end
    it "should render the new template" do
      login_user
      get :new, :id => "u4967160"
      response.should render_template(:new)
    end
  end
  
  describe "create action" do
    it "should throw an error if there are no requests" do
      pending("figure out how to mock request params")
      #login_user
      #post :create
      #flash[:error].should == 'You must select at least one item'
      #response.should redirect_to new_special_collections_request_path
    end
    it "should save" do
      pending("figure out how to mock request params")
      #@valid_attrs = { :location_plus_call_number => 'A 1863 .C59 C56 Feb.5'}
    end
  end
  
  describe "index action" do
    describe "verify admin" do
      it "should throw an error if there is no current user" do
        get :index
        flash[:error].should == "Please log in to manage Special Collections Requests. <a href='/login?redirect=special_collections_admin'>Login</a>"
        response.should redirect_to catalog_index_path
      end
      it "should allow an admin in" do
        authorize_admin
        get :index
        response.should be_success
      end
      it "should not allow non-admins in" do
        dont_authorize_admin
        get :index
        flash[:error].should == "You are not authorized to manage Special Collections Requests."
        response.should redirect_to catalog_index_path
      end
    end
    it "should render index template" do
      authorize_admin
      get :index
      response.should render_template(:index)
    end
  end
  
  describe "edit action" do
    before(:each) do
      @special_collections_request = SpecialCollectionsRequest.create(:document_id => "u850", :user_id => 'mpc3c')
    end
    it "should set the document, availability, and location notes" do
      authorize_admin
      get :edit, :id => @special_collections_request.id
      assigns[:special_collections_request].document.should_not be_nil
      assigns[:special_collections_request].document.availability.should_not be_nil
      assigns[:location_notes].should_not be_nil
    end
    it "should render update template" do
      authorize_admin
      get :edit, :id => @special_collections_request.id
      response.should render_template(:edit)
    end
  end
  
  describe "update action" do
    it "should save the attributes" do
      pending("figure out how to mock params")
    end
  end
  
  describe "show action" do
    before(:each) do
      authorize_admin
      @special_collections_request = SpecialCollectionsRequest.create(:document_id => "u850", :user_id => 'mpc3c')
      @item = SpecialCollectionsRequestItem.create(:special_collections_request_id => @special_collections_request.id)      
    end
    it "should build the request" do
      get :show, :id => @special_collections_request.id, :format => :pdf
      assigns[:special_collections_request].should_not be_nil
    end
    it "should set a response, document, and date" do
      get :show, :id => @special_collections_request.id, :format => :pdf
      assigns[:response].should_not be_nil
      assigns[:document].should_not be_nil
      assigns[:date].should_not be_nil
    end
    
  end
end