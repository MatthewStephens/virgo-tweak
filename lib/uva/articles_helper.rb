require 'happymapper'

module UVA::ArticlesHelper
  
  class Item
    include HappyMapper
    register_namespace 'sear', 'http://www.exlibrisgroup.com/xsd/jaguar/search'
    register_namespace 'prim', 'http://www.exlibrisgroup.com/xsd/primo/primo_nm_bib'
    tag 'FACET_VALUES'
    namespace 'sear'
    attribute :hits, Integer, :tag => "VALUE"
    attribute :value, String, :tag => "KEY"
    def display_value(facet_name)
      if facet_name == 'tlevel'
        return @value.gsub(/_/, " ").capitalize
      end
      if facet_name == 'lang' and LANGUAGES.has_key?(@value.downcase)
        return LANGUAGES[@value.downcase]
      end
      return @value
    end
  end
    
  class Facet
    include HappyMapper
    register_namespace 'sear', 'http://www.exlibrisgroup.com/xsd/jaguar/search'
    register_namespace 'prim', 'http://www.exlibrisgroup.com/xsd/primo/primo_nm_bib'
    tag 'FACET'
    namespace 'sear'
    attribute :hits, Integer, :tag => "COUNT"
    attribute :name, String, :tag => "NAME"
    has_many :items, Item, :namespace => "sear", :tag => "FACET_VALUES"
  end

  class Search
    include HappyMapper
    register_namespace 'sear', 'http://www.exlibrisgroup.com/xsd/jaguar/search'
    register_namespace 'prim', 'http://www.exlibrisgroup.com/xsd/primo/primo_nm_bib'
    tag 'search'
    namespace 'prim'
    element :creation_date, String, :tag => "creationdate"
    element :id, String, :tag => "recordid"
  end
  
  class Display
    include HappyMapper
    register_namespace 'sear', 'http://www.exlibrisgroup.com/xsd/jaguar/search'
    register_namespace 'prim', 'http://www.exlibrisgroup.com/xsd/primo/primo_nm_bib'
    tag 'display'
    namespace 'prim'
    element :creator, String
    element :identifier, String
    element :is_part_of, String, :tag => "ispartof"
    element :language, String
    element :lds50, String
    element :source, String
    element :subject, String
    element :title, String
    element :type, String
    element :version, String
    def identifier
      @identifier.gsub(/<\/?b>/, "")
    end
  end
  
  class GetIt
    include HappyMapper
    register_namespace 'sear', 'http://www.exlibrisgroup.com/xsd/jaguar/search'
    register_namespace 'prim', 'http://www.exlibrisgroup.com/xsd/primo/primo_nm_bib'
    tag 'GETIT'
    namespace 'sear'
    attribute :get_it_1, String, :tag => "GetIt1"
    attribute :get_it_2, String, :tag => "GetIt2"
    attribute :delivery_category, String, :tag => "deliveryCategory"
  end
  
  class Link
    include HappyMapper
    register_namespace 'sear', 'http://www.exlibrisgroup.com/xsd/jaguar/search'
    register_namespace 'prim', 'http://www.exlibrisgroup.com/xsd/primo/primo_nm_bib'
    tag 'LINKS'
    namespace 'sear'
    element :url, String, :tag => "openurl"
    element :back_link, String, :tag => "backlink"
    element :thumbnail, String
    element :fulltext_url, String, :tag => "openurlfulltext"
  end
  
  class Document
    include HappyMapper
    register_namespace 'sear', 'http://www.exlibrisgroup.com/xsd/jaguar/search'
    register_namespace 'prim', 'http://www.exlibrisgroup.com/xsd/primo/primo_nm_bib'
    tag 'DOC'
    namespace 'sear'
    has_one :display, Display, :tag => "display", :deep => "true"
    has_one :search, Search, :tag => "search", :deep => "true"
    has_many :links, Link, :tag => "LINKS"
    has_many :get_its, GetIt, :tag => "GETIT"
    def doc_type
      return :article
    end
    def id
      return @search.id
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
  end
  
  class Counts
    include HappyMapper
    register_namespace 'sear', 'http://www.exlibrisgroup.com/xsd/jaguar/search'
    register_namespace 'prim', 'http://www.exlibrisgroup.com/xsd/primo/primo_nm_bib'
    tag 'DOCSET'
    namespace 'sear'
    attribute :hits, Integer, :tag => "TOTALHITS"
    attribute :first_hit, Integer, :tag => "FIRSTHIT"
    attribute :last_hit, Integer, :tag => "LASTHIT"
  end
  
  class Response
    # a bit of grodiness to make these responses resemble solr responses
    attr_accessor :current_page # WillPaginate hook
    attr_accessor :per_page, :response, :params
    
    include HappyMapper
    register_namespace 'sear', 'http://www.exlibrisgroup.com/xsd/jaguar/search'
    register_namespace 'prim', 'http://www.exlibrisgroup.com/xsd/primo/primo_nm_bib'
    tag 'JAGROOT'
    namespace 'sear'
    has_many :facets, Facet, :tag => "FACET", :deep => "true"
    has_many :docs, Document, :tag => "DOC", :deep => "true"
    has_one :counts, Counts, :tag => "DOCSET", :deep => "true"
    
    def total
      @counts.hits rescue 0
    end
    # WillPaginate hook
    def total_pages
      ret = ((total / per_page).ceil + 1) rescue 1
      ret
    end
    # WillPaginate hook
    def previous_page
      current_page > 1 ? current_page - 1 : 1
    end
    # WillPaginate hook
    def next_page
      current_page == total_pages ? total_pages : current_page + 1
    end
    
    # what page we are on
    def self.page(extra_controller_params={})
      p = extra_controller_params[:page].to_i
      p = 1 if p == 0
      p
    end
    
    # how many per page
    def self.per_page(extra_controller_params={})
      p = extra_controller_params[:per_page].to_i
      p = 20 if p == 0
      p
    end
    
    def self.custom_parse(content, extra_controller_params)
      # HappyMapper parsing
      response = Response.parse(content, :single=>true)
      # local customizations
      # these are better set from the input params than from the output
      response.current_page = Response.page(extra_controller_params)
      response.per_page = Response.per_page(extra_controller_params)
      # hacking this object to look like solr responses
      response.response = {'numFound' => response.total}
      first_hit = response.counts.first_hit rescue 1
      start_num = first_hit - 1
      start_num = 0 if start_num < 0
      response.params = {:start => start_num}
      response
    end
  end
  
  # if it begins and ends with quotes, make it exact
  def scope(query)
    #query =~ /^[\",\'].+[\",\']$/ ? "exact" : "contains"
    # will revisit
    query =~ /^[\",\'].+[\",\']$/ ? "contains" : "contains"
  end
  
  # throw out quotes, commas, colons, exclamation points, periods, semi-colons, question marks
  def scrubbed_query(query)
    query.gsub(/[\",\',\,,:,!,\.,;,\?]/, " ")
  end
  
  # extract params[:q] and make URL piece
  def get_query(extra_controller_params={})
    return "" if extra_controller_params[:q].blank?
    query = extra_controller_params[:q]
    return "&query=any,#{scope(query)},#{scrubbed_query(query)}"
  end
  
  # extract populated advanced search fields and make URL pieces
  def get_advanced_search_queries(extra_controller_params={})
    queries = []
    BlacklightAdvancedSearch.search_field_list(extra_controller_params).each do |field_def|
      key = field_def[:key].to_sym
      primo_key = field_def[:primo_key]
      if field_def[:range]
        raw_value = extra_controller_params[key]
        if ! raw_value.blank?          
          if raw_value =~ /-/
            value = raw_value.sub("-", "TO")
          else
            value = "#{raw_value} TO #{raw_value}"
          end
          queries << "&query=facet_#{primo_key},exact,[#{value}]"
        end   
      else  
        value = extra_controller_params[key]
        unless value.blank?
          queries << "&query=#{primo_key},#{scope(value)},#{scrubbed_query(value)}"
        end
      end
    end
    queries
  end
  
  # extract params[:f] and make URL pieces
  def get_facets(extra_controller_params={})
    facets = []
    if extra_controller_params[:f]      
      extra_controller_params[:f].each_pair do |facet_field, value_list|
        value_list.each do |value|
          value = scrubbed_query(value)
          value = "[#{value} TO #{value}]" if facet_field == 'creationdate'
          facets << "&query=facet_#{facet_field},exact,#{value}"
        end
      end
    end
    facets
  end
  
  # extract start index and per page and make URL piece
  def get_paging(extra_controller_params={})
    my_per_page = Response.per_page(extra_controller_params)
    my_page = Response.page(extra_controller_params) - 1
    start_index = (my_page * my_per_page) + 1
    return "&indx=#{start_index}&bulkSize=#{my_per_page}"
  end
  
  # extract sort and make URL piece
  def get_sort(extra_controller_params={})
    if extra_controller_params[:format] == "rss"
      extra_controller_params[:sort_key] = 'articles_date'
    end
    return "" if extra_controller_params[:sort_key].blank?
    sort = Blacklight.config[:articles_sort_fields][extra_controller_params[:sort_key]][1] rescue ''
    return "&sortField=#{sort}" 
  end
  
  def get_scope(extra_controller_params={})
    "&loc=adaptor,primo_central_multiple_fe"
  end
  
  def build_articles_url(extra_controller_params={})
    url = PRIMO_URL
    url += get_query(extra_controller_params)
    get_advanced_search_queries(extra_controller_params).each do |q|
      url += q
    end
   
    # make it be just articles
    # url += "&query=facet_pfilter,exact,articles"

    get_facets(extra_controller_params).each do |f|
      url += f
    end
    url += get_paging(extra_controller_params)
    url += get_sort(extra_controller_params)
    url += get_scope(extra_controller_params)
    RAILS_DEFAULT_LOGGER.info("primo request url: #{url}")
    url
  end
  
  def build_article_url(article_id, extra_controller_params={})
    url = PRIMO_URL
    url += "&query=rid,exact,#{article_id}"
    url += get_scope(extra_controller_params)
    RAILS_DEFAULT_LOGGER.info("primo request url: #{url}")
    url
  end
  
  # looks up a specific article using the article identifier in "rid"
  def get_article_by_id(article_id, extra_controller_params={})
    url = build_article_url(article_id, extra_controller_params)
    uri = URI.parse(URI.encode(url))
    content = uri.read
    response = Response.custom_parse(content, extra_controller_params)
    return [response, response.docs]
  end
  
  # gets specific articles using the article identifier in "rid"
  def get_articles_by_ids(article_ids=[])
    return [] if article_ids.blank?
    articles = []
    article_ids.each do |article_id|
      response, documents = get_article_by_id(article_id)
      articles << documents.first
    end
    articles
  end
  
  def get_article_search_results(extra_controller_params={})
    RAILS_DEFAULT_LOGGER.info("primo encoded is #{URI.encode(build_articles_url(extra_controller_params)).inspect}")
    uri = URI.parse(URI.encode(build_articles_url(extra_controller_params)))
    content = uri.read
    response = Response.custom_parse(content, extra_controller_params)
    return [response, response.docs]
  end
end