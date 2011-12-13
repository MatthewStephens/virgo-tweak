require 'lib/uva/advanced_search/range_query_parser'

module UVA::AdvancedSearch

  class QueryParser < BlacklightAdvancedSearch::QueryParser
  
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
    
    def to_solr
      @to_solr ||= begin
        {
          :q => process_query(params,config), 
          :fq => generate_solr_fq() 
        }
      end
    end    
    
    # overriding from plugin to include range_queries
    def process_query(params,config)
      queries = []
      keyword_queries.each do |field,query| 
        queries << ParsingNesting::Tree.parse(query).to_query( local_param_hash(field)  )            
      end
      range_queries.each do |key,ranges|
        queries << UVA::AdvancedSearch::RangeQueryParser.parse(key,ranges)
      end
      queries.join( ' ' + keyword_op + ' ')
    end
  
  end
  
end