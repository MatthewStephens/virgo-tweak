require 'spec_helper'
require 'rsolr'

describe MusicController do

  describe "featured documents" do
    it "should load featured documents" do
      mock_docs = [mock("SolrDocument", :id => 1, :has? => true, :has_image? => true), 
                   mock("SolrDocument", :id => 2, :has? => true, :has_image? => true),
                   mock("SolrDocument", :id => 3, :has? => true, :has_image? => false)]
      mock_response = mock("Response", :docs => mock_docs, :total => 3)
      controller.stubs(:get_search_results).returns([mock_response, mock_docs])
      get :index
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
      get :index
      first = assigns[:featured_documents][0].dup
      get :index
      second = assigns[:featured_documents][0].dup
      first.should_not == second
    end
  end
end