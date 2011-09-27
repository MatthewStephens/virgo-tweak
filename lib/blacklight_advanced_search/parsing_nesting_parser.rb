module BlacklightAdvancedSearch::ParsingNestingParser

  require_dependency 'vendor/plugins/blacklight_advanced_search/lib/blacklight_advanced_search/parsing_nesting_parser.rb'
  
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