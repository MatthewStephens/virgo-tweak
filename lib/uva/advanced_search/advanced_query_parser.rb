module UVA::AdvancedSearch

  class QueryParser
  
    def self.included(base)
      base.send :include, BlacklightAdvancedSearch::QueryParser
      base.send :include, UVACustomizations
    end
    
    module UVACustomizations
   
      def range_queries
        unless(@range_queries)
          @range_queries = {}
          return @range_queries unless @params[:search_field] == BlacklightAdvancedSearch.config[:url_key]
          Blacklight.config[:extra_search_fields].each do | field_def |
            next if !field_def[:range]          
            key = field_def[:key]
            key_start = "#{key}_start"
            key_end = "#{key}_end"          
          
            if ! @params[ key_start.to_sym ].blank?
              ranges = []
              ranges << @params[ key_start.to_sym ]
              ranges << @params[key_end.to_sym] unless @params[key_end.to_sym].blank?
              @range_queries[ key ] = ranges
            end
          end
        end
        return @range_queries
      
      end
      
    end
    
  end
  
end