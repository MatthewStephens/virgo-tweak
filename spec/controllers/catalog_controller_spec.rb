require 'spec_helper'
require 'rsolr'

describe CatalogController do
  
  describe "redirect needed" do    
    it "should redirect to the provided message if there is a RedirectNeeded exception" do
      controller.should_receive(:get_search_results).and_raise(UVA::RedirectNeeded.new("http://www.google.com"))
      get :index
      response.should redirect_to "http://www.google.com"
    end
  end
  
  describe "index action" do
    
    it "should get json response" do
      get :index, :format => 'json'
      response.should be_success
    end
    
    it "should set the portal in session" do
      get :index, :portal => 'music'
      session[:search][:portal].should == 'music'
    end
    
    it "should adjust for special collections search" do
      get :index, :special_collections => 'true'
      session[:special_collections].should == true
    end
    
    it "should turn off special collections search if requested" do
      get :index, :special_collections => 'false'
      session[:special_collections].should be_nil
    end
    
    describe "call number search" do
      it "should remove quotes after they have been added" do
        get :index, :q => 'MSS 123', :search_field => 'call_number'
        controller.params[:q].should == 'MSS 123'
      end
      it "should add the quotes back in if they were there to begin with" do
        get :index, :q => '"MSS 123"', :search_field => 'call_number'
        controller.params[:q].should == '"MSS 123"'
      end
    end
  
    describe "resolve sort" do
      it "should default to received for RSS" do
        get :index, :format => :rss
        session[:search][:sort].should == 'date_received_facet desc'
      end
      it "should allow for published sort for RSS" do
        get :index, :sort_key => 'published', :format => 'rss'
        session[:search][:sort].should == "year_multisort_i desc"
      end
      it "should allow for alternate sort for call number searches" do
        get :index, :search_field => 'call_number', :sort_key => 'published'
        session[:search][:sort].should == "year_multisort_i desc"
      end
      it "should sort by date published for digital collection facet searches" do
        get :index, :f => { "digital_collection_facet" => "blah"}
        session[:search][:sort].should == "year_multisort_i desc"
      end
      it "should allow for alternate sort for digital collection facet searches" do
        get :index, :f => { "digital_collection_facet" => "blah"}, :sort_key => 'received'
        session[:search][:sort].should == 'date_received_facet desc'
      end
      it "should sort by relevancy on digital collection facet if there is a keyword" do
        get :index, :f => { "digital_collection_facet" => "blah"}, :q => "sushi"
        session[:search][:sort].should == 'score desc, year_multisort_i desc'
      end
      it "should sort by relevancy for keyword searches" do
        get :index, :q => "sushi"
        session[:search][:sort].should == 'score desc, year_multisort_i desc'
      end
      it "should sort by the sort key" do
        get :index, :sort_key => 'published'
        session[:search][:sort].should == "year_multisort_i desc"
      end  
      it "should sort by date received if no options" do
        get :index
        session[:search][:sort].should == 'date_received_facet desc'
      end
    end
    
    describe "featured documents" do
      it "should load featured documents" do
        mock_docs = [mock("SolrDocument", :id => 1, :has? => true, :has_image? => true), 
                     mock("SolrDocument", :id => 2, :has? => true, :has_image? => true),
                     mock("SolrDocument", :id => 3, :has? => true, :has_image? => false)]
        mock_response = mock("Response", :docs => mock_docs, :total => 3)
        controller.stubs(:get_search_results).returns([mock_response, mock_docs])
        get :index, :portal => "music"
        assigns[:featured_documents].size.should == 2
      end
      it "should not load featured documents if :q is present" do
        get :index, :q => "foo"
        assigns[:featured_docuemnts].should be_nil
      end
      it "should not load featured documents if :f is present" do
        get :index, :f => { "format_facet" => "blah"}
        assigns[:featured_documents].should be_nil
      end
      it "should sort randomly" do
        pending("this isn't guaranteed to be random")
        mock_docs = [mock("SolrDocument", :id => 1, :has? => true, :has_image? => true), 
                     mock("SolrDocument", :id => 2, :has? => true, :has_image? => true),
                     mock("SolrDocument", :id => 3, :has? => true, :has_image? => true),
                     mock("SolrDocument", :id => 4, :has? => true, :has_image? => true),
                     mock("SolrDocument", :id => 5, :has? => true, :has_image? => true)
                     ]
        mock_response = mock("Response", :docs => mock_docs, :total => mock_docs.size)
        controller.stubs(:get_search_results).returns([mock_response, mock_docs])
        get :index, :portal => "music"
        first = assigns[:featured_documents][0].dup
        get :index, :portal => "music"
        second = assigns[:featured_documents][0].dup
        first.should_not == second
      end
    end
  
  end
  
  describe "show" do
    doc_id = "u3954069"
    it "should give a json response" do
      get :show, :id => doc_id, :format => 'json'
      response.should be_success        
    end
    it "should display an error if it is an invalid solr id" do
      get :show, :id => 'fake'
      flash[:notice].should == "Sorry, you seem to have encountered an error."
    end
  end
  
  describe "update" do
    doc_id = "u3954069"
    it "should adjust for bookmarks view" do
      put :update, :id => doc_id, :bookmarks_view => 'true'
      session[:search][:bookmarks_view].should be_true
    end
    
    it "should not be bookmarks view if it isn't asked for" do
      put :update, :id => doc_id
      session[:search][:bookmarks_view].should be_false
    end
  end
  
  describe "availability" do
    doc_id = "u3954069"
    it "should get the availability" do
      get :availability, :id => doc_id
      assigns[:document].availability.should_not be_nil
    end
    it "should render availability.html.erb" do
      get :availability, :id => doc_id
      response.should render_template(:availability)
    end
  end
  
  describe "image_load" do
    doc_id = "u3954069"
    it "should get document" do
      get :image_load, :id => doc_id
      assigns[:document].should_not be_nil
    end
    it "should render image_load.html.erb" do
      get :image_load, :id => doc_id
      response.should render_template(:image_load)
    end
    it "should set a lean query type" do
      get :image_load, :id => doc_id
      controller.params[:qt].should == :document_lean
    end
  end
  
  describe "citation" do
    doc_ids = ['u3954069', 'u4325778']
    it "should get documents" do
      get :citation, :id => doc_ids
      assigns[:documents].should_not be_nil
    end
    it "should render citations.html.erb" do
      get :citation, :id => doc_ids
      response.should render_template(:citation)
    end
  end
  
  describe "endnote" do
    doc_ids = ['u3954069', 'u4325778']
    it "should get documents" do
      get :endnote, :id => doc_ids
      assigns[:documents].should_not be_nil
    end    
  end

  describe "email" do
    doc_ids = ['u3954069', 'u4325778']
    it "should get documents" do
      get :email, :id => doc_ids
      assigns[:documents].should_not be_nil
    end  
  end
  
  describe "sms" do
    doc_ids = ['u3954069', 'u4325778']
    it "should get documents" do
      get :sms, :id => doc_ids
      assigns[:documents].should_not be_nil
    end  
  end
  
  describe "send email" do
    doc_ids = ['u3954069', 'u4325778']
    it "should redirect to the folder index if there are multiple documents" do
      controller.stubs(:verify_recaptcha).returns(true)
      post :send_email_record, :id => doc_ids, :style => 'email', :to => 'user@business.com'
      response.should redirect_to folder_index_path
    end
    it "should redirect to the show page if there is only one document" do
      controller.stubs(:verify_recaptcha).returns(true)
      post :send_email_record, :id => doc_ids[0], :style => 'email', :to => 'user@business.com'
      response.should redirect_to catalog_path(doc_ids[0])
    end
    it "should throw an error if recaptcha fails" do
      controller.stubs(:verify_recaptcha).returns(false)
      post :send_email_record, :id => doc_ids, :style => 'email', :to => 'user@business.com'
      flash[:error].should == "Text validation did not match."
    end
  end
    
  describe "firehose" do
    doc_id = "u3954069"
    before(:each) do
      record = mock("blah")
      record.stubs(:to_xml).returns("blah_as_xml")
      firehose = mock(Firehose::Availability)
      firehose.stubs(:to_xml).returns(record)
      Firehose::Availability.stubs(:find).returns(firehose)
    end
    it "should give an xml response" do
      get :firehose, :id => doc_id, :format => 'xml'
      response.should be_success
    end      
  end
  
  
end