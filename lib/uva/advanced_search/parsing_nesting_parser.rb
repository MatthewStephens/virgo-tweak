module UVA::AdvancedSearch
  
  module ParsingNestingParser
    
    def self.included(base)
      base.send :include, BlacklightAdvancedSearch::ParsingNestingParser
      base.send :include, UVACustomizations
    end
  
    module UVACustomizations
  
      # overriding from plugin to include range_queries
      def process_query(params,config)
        queries = []
        keyword_queries.each do |field,query| 
          queries << ParsingNesting::Tree.parse(query).to_query( local_param_hash(field)  )            
        end
        range_queries.each do |key,ranges|
          queries << BlacklightAdvancedSearch::RangeQueryParser.parse(key,ranges)
        end
        queries.join( ' ' + keyword_op + ' ')
      end
      
    end

  end

end