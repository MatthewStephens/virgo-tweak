require 'happymapper'
require 'net/http'
require 'net/https'
require 'sanitize'

module UVA
  
  module Ebsco
    
    class Item
      include HappyMapper
      tag 'AvailableFacetValue'
      element :value, String, :tag => "Value"
      element :hits, Integer, :tag => "Count"
    end
    
    class Facet
      include HappyMapper
      tag 'AvailableFacet'
      element :name, String, :tag => "Id"
      has_many :items, Item, :tag => "AvailableFacetValue", :deep => "true"
    end  
      
    class Link
      attr_accessor :fulltext_url
    end
        
    class Display
      attr_accessor :title
      attr_accessor :creator
      attr_accessor :is_part_of
      attr_accessor :identifier
    end
    
    class DisplayElement
      include HappyMapper
      tag 'Item'
      element :key, String, :tag => "Label"
      element :value, String, :tag => "Data"
    end
    
    class Document
      include HappyMapper
      tag 'Record'
      has_many :display_elements, DisplayElement, :tag => "Item", :deep => "true"
      element :link, String, :tag => "PLink"
      attr_accessor :display, :links
      def map_to_display
        @display = Display.new
        @display_elements.each do |element|
          @display.title = element.value if element.key == "Title"
          @display.creator = search_link(element.value) if element.key == "Authors"
          @display.is_part_of = Sanitize.clean(element.value) if element.key == "Source"
        end
        link = Link.new
        link.fulltext_url = @link
        @links = [link]
      end
      def doc_type
        return :article
      end    
      def value_for(field)
        if Document.method_defined?(field.to_sym)
          m = Document.instance_method(field.to_sym)
          return m.bind(self).call
        else
          Document.instance_variable_get(field_to_sym)
        end
      end
      def [](field)
        return value_for(field)
      end  
      def search_link(string)
        return string unless m = string.match("<searchLink")
        matches = string.scan(/<searchLink.*?<\/searchLink>/)
        matches = matches.collect {|match| Sanitize.clean(match)}
        matches.size > 1 ? join = "; \n" : join = ""
        matches.join(join)
      end
    end
    
    class Response
      include HappyMapper
      tag 'SearchResult'
      
      attr_accessor :per_page
      attr_accessor :page
      
      element :total_hits, String, :tag => "TotalHits", :deep => "true"
      has_many :docs, Document, :tag => "Record", :deep => "true"
      has_many :facets, Facet, :tag => "AvailableFacet", :deep => "true"
      
      # for kaminari
      def total
        @total_hits.to_i
      end
      
      # for kaminari
      def start
        @page >= 2 ? page = @page - 1 : page = @page
        (@per_page * page)
      end
      
      # for kaminari
      def rows
        @per_page
      end
      
      def self.per_page_amount(extra_controller_params)
        p = extra_controller_params[:per_page].to_i rescue 0
        p = 20 if p == 0
        p
      end
      
      def self.page_number_amount(extra_controller_params={})
        p = extra_controller_params[:page].to_i rescue 0
        p
      end
      
      def self.custom_parse(content, extra_controller_params)
        # HappyMapper parsing
        response = Response.parse(content, :single=>true)
        response.per_page = Response.per_page_amount(extra_controller_params)
        response.page = Response.page_number_amount(extra_controller_params)
        response.docs.each do |doc|
          doc.map_to_display
        end
        response  
      end
      
    end
   
    # methods for making EBSCO key-value pairs for building a search request URL
    class ParamParts
      # extract params[:q]
      def self.query(extra_controller_params={})
        return "" if extra_controller_params[:q].blank?
        query = extra_controller_params[:q]
        return "query-1=AND,#{query}"
      end
    
      # EBSCO's filters for fulltext-only
      # also, do a fulltext search
      def self.fulltext(extra_controller_params={})
        return "limiter=FT:y&expander=fulltext"
      end
    
      # set the number of results per page
      def self.per_page(extra_controller_params={})
        return "resultsperpage=#{Response.per_page_amount(extra_controller_params)}"
      end
    
      # set which page to get
      def self.page(extra_controller_params={})
        return "pagenumber=#{Response.page_number_amount(extra_controller_params)}"
      end    
    
      # turn off highlighting
      def self.remove_highlighting(extra_controller_params={})
        return "highlight=n"
      end
      
      # add facets
      def self.facets(extra_controller_params={})
        facets = []
        if extra_controller_params[:f]
          i = 1      
          extra_controller_params[:f].each_pair do |facet_field, value_list|
            value_list.each do |value|
              facets << "facetfilter=1,#{facet_field}:#{value}"
            end
          end
        end
        return facets.join("&")
      end
      
      # get sort
      def self.sort(extra_controller_params={})
        if extra_controller_params[:format] == "rss"
          extra_controller_params[:sort_key] = 'date'
        end
        return "" if extra_controller_params[:sort_key].blank?
        match = ArticlesController.blacklight_config.sort_fields.select { |key, value| value.sort_key == extra_controller_params[:sort_key] }
        sort = match[0][0] rescue ''
        return "sort=#{sort}"
      end
      
      # extract populated advanced search fields and make URL pieces
      # RANGE QUERIES DO NOT WORK YET
      def self.advanced_queries(extra_controller_params={})
        queries = []
        fields = ArticlesController.blacklight_config.search_fields
        i = 2
        fields.each do |field_def|
          key = field_def[0].to_sym
          ebsco_key = field_def[1][:ebsco_key]
          if field_def[1][:range]
            raw_value = extra_controller_params[key]
            if ! raw_value.blank?          
              if raw_value =~ /-/
                value = raw_value.sub("-", "/")
              else
                value = "#{raw_value}/"
              end
              queries << "#{ebsco_key}:#{value}"
            end   
          else  
            value = extra_controller_params[key]
            unless value.blank?
              queries << "query-#{i}=AND,#{ebsco_key}:#{value}"
              i+=1
            end
          end
        end
        return queries.join("&")
      end
      
      
    end 
    
    # EBSCO searches require an auth token
    def get_auth_token
      http = Net::HTTP.new(EBSCO_REST_HOST, 443)
      http.use_ssl = true
      path = "/authservice/rest/uidauth"

      data = "
      {
        \"UserId\":\"#{EBSCO_USERNAME}\",
        \"Password\":\"#{EBSCO_PASSWORD}\"
      }
      "
      headers = {'Content-Type' => 'application/json', 'Accept' => 'application/json'}
      
      resp, data = http.post(path, data, headers)
      parsed = JSON.parse(data)
      parsed["AuthToken"]
    end
    
    # EBSCO searches require a session token
    def get_session_token(auth_token)
      http = Net::HTTP.new(EBSCO_REST_HOST)
      path = "/edsapi/rest/createsession?profile=#{EBSCO_USERNAME}"
      headers = {'x-authenticationToken' => auth_token, 'Accept' => 'application/json'}
      
      resp, data = http.request_get(path, headers)
      parsed = JSON.parse(data)
      parsed["SessionToken"]
    end
   
    
    def build_articles_search(extra_controller_params={})
      params = "?"
      params += ParamParts.query(extra_controller_params)
      params += "&" + ParamParts.fulltext(extra_controller_params)
      params += "&" + ParamParts.per_page(extra_controller_params)
      params += "&" + ParamParts.page(extra_controller_params)
      params += "&" + ParamParts.remove_highlighting(extra_controller_params)
      params += "&" + ParamParts.sort(extra_controller_params)
      params += "&" + ParamParts.facets(extra_controller_params)
      params += "&" + ParamParts.advanced_queries(extra_controller_params)
      URI.encode(params)
    end
    
    def get_article_search_results(extra_controller_params={})
      http = Net::HTTP.new(EBSCO_REST_HOST)
      path = "/edsapi/rest/search#{build_articles_search(extra_controller_params)}"
      Rails.logger.info("EBSCO Request URL: #{path.inspect}")
      auth_token = get_auth_token
      session_token = get_session_token(auth_token)
      headers = {'x-authenticationToken' => auth_token, 'x-sessionToken' => session_token, 'Accept' => 'application/xml'}
      
      http_response, data = http.request_get(path, headers)
            
      article_response = Response.custom_parse(data, extra_controller_params)
            
      return [article_response, article_response.docs]
      
    end
    
  end
  
end