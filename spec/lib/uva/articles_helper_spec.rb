require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe UVA::ArticlesHelper do
  
  class FakeArticlesHelper
    include UVA::ArticlesHelper
  end
  
  describe "article requests" do
    
    before(:each) do
      @helper = FakeArticlesHelper.new
    end
  
    describe "build_articles_url" do
      it "should build the url" do
        params = { :sort_key => "articles_date",
                   :publication_date => "2000",
                   :search_field => "advanced",
                   :controller => "articles",
                   :f => { "creationdate" => "2000" }, 
                   :per_page => "50",
                   :f => { "type" => "articles" },
                   :q => "smith" 
                }
        url = @helper.build_articles_url(params)
        url.should == "http://primo4.hosted.exlibrisgroup.com:1701/PrimoWebServices/xservice/search/brief?institution=UVA&onCampus=true&query=any,contains,smith&query=facet_creationdate,exact,[2000 TO 2000]&query=facet_type,exact,articles&indx=1&bulkSize=50&sortField=scdate&loc=adaptor,primo_central_multiple_fe"
      end
    end
  
    describe "build_article_url" do
      it "should construct the request url" do
        @helper.build_article_url("test_id").should == "http://primo4.hosted.exlibrisgroup.com:1701/PrimoWebServices/xservice/search/brief?institution=UVA&onCampus=true&query=rid,exact,test_id&loc=adaptor,primo_central_multiple_fe"
      end
    end
    
    describe "get_article_search_results" do
      it "should get articles" do
        params = { :q => "smith",  }
        response, docs = @helper.get_article_search_results(params)
        response.should_not be_nil
        docs.should_not be_nil
      end
    end
  
    describe "get_article_by_id" do
      it "should get a response" do
        response, response.docs = @helper.get_article_by_id("crossref10.1021/ed060pA338")
        response.should_not be_nil
        response.docs.should_not be_nil
      end
    end
  
    describe "get_articles_by_ids" do
      it "should get articles" do
        articles = @helper.get_articles_by_ids(["crossref10.1021/ed053p182", "crossref10.1021/ed060pA338"])
        articles.should_not be_nil
        articles.size.should == 2
      end
    end
  
    describe "scrubbed_query" do
      it "should scrub out puctuation and replace with spaces" do
        query = "Hi! 'Mr. Bozo', how are you?"
        @helper.scrubbed_query(query).should == "Hi   Mr  Bozo   how are you "
      end
    end
    
    describe "get_query" do
      it "should get the query from the params" do
        params = { :q => "test" }
        @helper.get_query(params).should == "&query=any,contains,test"
      end
      it "should return an empty string if there is no :q in the params" do
        params = {}
        @helper.get_query(params).should == ""
      end
    end
    
    describe "get_advanced_search_queries" do
      it "should handle range queries" do
        params = { :publication_date => "2000 - 2005", :controller => "articles" }
        @helper.get_advanced_search_queries(params).should == ["&query=facet_creationdate,exact,[2000 TO 2005]"]
      end
      it "should handle range queries with only one part defined" do
        params = { :publication_date => "2000", :controller => "articles" }
        @helper.get_advanced_search_queries(params).should == ["&query=facet_creationdate,exact,[2000 TO 2000]"]
      end
      it "should handle non-range queries" do
        params = { :author => 'Jones', :controller => "articles"}
        @helper.get_advanced_search_queries(params).should == ["&query=creator,contains,Jones"]
      end
    end
  
    describe "get_facets" do
      it "should get simple facets" do
        params = { :f => {"rtype" => ["articles"] } }
        @helper.get_facets(params).should == ["&query=facet_rtype,exact,articles"]
      end
      it "should get creationdate" do
        params = { :f => {"creationdate" => ["2000"] } }
        @helper.get_facets(params).should == ["&query=facet_creationdate,exact,[2000 TO 2000]"]
      end
    end
  
    describe "get_paging" do
      it "should set the paging" do
        params = { :per_page => 50, :page => 3 }
        @helper.get_paging(params).should == "&indx=101&bulkSize=50"
      end
    end
    
    describe "get_sort" do
      it "should return a blank string if no sort specified" do
        params = {}
        @helper.get_sort(params).should == ""
      end
      it "should set the sorting if it is specified" do
        params = { :sort_key => 'articles_date' }
        @helper.get_sort(params).should == "&sortField=scdate"
      end
    end
  
  end
  
end