# This module gets added on to CatalogController, mainly to override
# Blacklight::SolrHelper methods like #solr_search_params

require 'lib/uva/advanced_search/advanced_query_parser'

module UVA::AdvancedSearch

  module Controller

    def self.included(base)
      base.send :include, BlacklightAdvancedSearch::Controller
      base.send :include, UVACustomizations
    end 
    
    module UVACustomizations

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
        if ( (req_params[:search_field] == self.blacklight_config.advanced_search[:url_key]) ||
                  req_params[:f_inclusive] )
          # Set this as a controller instance variable, not sure if some views/helpers depend on it. Better to leave it as a local variable
          # if not, more investigation later.       
          @advanced_query = UVA::AdvancedSearch::QueryParser.new(req_params, self.blacklight_config )
          BlacklightAdvancedSearch.deep_merge!(solr_parameters, @advanced_query.to_solr )
          if @advanced_query.keyword_queries.length > 0 or @advanced_query.range_queries.length > 0
            # force :qt if set
            solr_parameters[:qt] = self.blacklight_config.advanced_search[:qt]
            solr_parameters[:defType] = "lucene"
          end
        end
      end
      
    end
    
  end

end