# This module gets added on to CatalogController, mainly to override
# Blacklight::SolrHelper methods like #solr_search_params

module BlacklightAdvancedSearch::ControllerOverride

  require_dependency 'vendor/plugins/blacklight_advanced_search/lib/blacklight_advanced_search/controller_override.rb'

  # the only reason I'm overriding this method is to add the check for @advanced_query.range_queries.length > 0
  # this method should get added into the solr_search_params_logic
  # list, in a position AFTER normal query handling (:add_query_to_solr),
  # so it'll overwrite that if and only if it's an advanced search.
  # adds a 'q' and 'fq's based on advanced search form input. 
  def add_advanced_search_to_solr(solr_parameters, req_params = params)
    # If we've got the hint that we're doing an 'advanced' search, then
    # map that to solr #q, over-riding whatever some other logic may have set, yeah.
    # the hint right now is :search_field request param is set to a magic
    # key.     
    if (req_params[:search_field] == BlacklightAdvancedSearch.config[:url_key] ||
      req_params[:f_inclusive])
      # Set this as a controller instance variable, not sure if some views/helpers depend on it. Better to leave it as a local variable
      # if not, more investigation later.       
      @advanced_query = BlacklightAdvancedSearch::QueryParser.new(req_params, BlacklightAdvancedSearch.config )
      deep_merge!(solr_parameters, @advanced_query.to_solr )
      if @advanced_query.keyword_queries.length > 0 or @advanced_query.range_queries.length > 0
        # force :qt if set
        solr_parameters[:qt] = BlacklightAdvancedSearch.config[:qt] if BlacklightAdvancedSearch.config[:qt]
        solr_parameters[:defType] = "lucene"
      end
      
    end
  end

end