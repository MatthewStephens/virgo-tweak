# This module gets added on to CatalogController, mainly to override
# Blacklight::SolrHelper methods like #solr_search_params

module BlacklightAdvancedSearch::ControllerOverride

  require_dependency 'vendor/plugins/blacklight_advanced_search/lib/blacklight_advanced_search/controller_override.rb'

  # the only reason I'm overriding this method is to add the check for @advanced_query.range_queries.length > 0
  def solr_search_params(extra_params = {})    
    # Call superclass implementation, ordinary solr_params
    solr_params = super(extra_params)

    # When we're in advanced controller, we're fetching the search
    # context, and don't want to include any of our own stuff.
    # This is a hacky hard-coded way to do it, but needed
    # because solr_search_params is hard-coded to use current req params,
    # not just passed in arg override.
    return solr_params if self.class == AdvancedController

    #Annoying thing where default behavior is to mix together
    #params from request and extra_params argument, so we
    #must do that too.
    req_params = params.merge(extra_params)
    
    # Now do we need to do fancy advanced stuff?
    if (req_params[:search_field] == BlacklightAdvancedSearch.config[:url_key] ||
      req_params[:f_inclusive])
      # Set this as a controller instance variable, not sure if some views/helpers depend on it. Better to leave it as a local variable
      # if not, more investigation later.       
      @advanced_query = BlacklightAdvancedSearch::QueryParser.new(req_params, BlacklightAdvancedSearch.config )
      
      solr_params = deep_safe_merge(solr_params, @advanced_query.to_solr )
      if @advanced_query.keyword_queries.length > 0 or @advanced_query.range_queries.length > 0
        # force :qt if set
        solr_params[:qt] = BlacklightAdvancedSearch.config[:qt]
        solr_params[:defType] = "lucene"
      end
      
    end

    return solr_params
  end
end