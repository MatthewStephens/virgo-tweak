module UVA::AdvancedSearch
  
  module RangeQueryParser
    
    def self.parse(key, ranges)
      query = ""
      count = ranges.length
      field = CatalogController.blacklight_config.search_fields[key]

      return if field.blank?
      return unless count.between?(1, 2)
      if count == 2
        #   _query_:"{!lucene}year_multisort_i:[1800 TO 1860]"
        query =  "_query_:\"{!lucene}#{field.solr_field}:[#{ranges[0]} TO #{ranges[1]}]\""
      elsif count == 1
        # _query_:"{!lucene}year_multisort_i:1800"
        query = "_query_:\"{!lucene}#{field.solr_field}:#{ranges[0]}\""
      end
      query
    end
    
  end
  
end