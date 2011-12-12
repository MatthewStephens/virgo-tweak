## 
# This example config file is set up to work using the Solr request handler
# called "advanced" in the example Blacklight solrconfig.xml:
# http://github.com/projectblacklight/blacklight-jetty/blob/master/solr/conf/solrconfig.xml
#
# NOTE WELL: Using a seperate request handler is just one option, in most cases
# it's simpler to use your default solr request handler set in Blacklight itself,
# in which case you can delete/comment out this entire file!
# See README. 

BlacklightAdvancedSearch.config.merge!(
  # :search_field => "advanced", # name of key in Blacklight URL, no reason to change usually.
  
  # Set advanced_parse_q to true to allow AND/OR/NOT in your basic/simple
  # Blacklight search, parsed by Advanced Search Plugin. 
  #:advanced_parse_q => true, 
  
  :qt => "search" # name of Solr request handler, leave unset to use the same one as your Blacklight.config[:default_qt]
  
)


  # You don't need to specify search_fields, if you leave :qt unspecified
  # above, and have search field config in Blacklight already using that
  # same qt, the plugin will simply use them. But if you'd like to use a
  # different solr qt request handler, or have another reason for wanting
  # to manually specify search fields, you can. Uses the hash format
  # specified in Blacklight::SearchFields

  BlacklightAdvancedSearch.config[:search_fields] = search_fields = []
  search_fields << {
    :key =>  'author',
    :solr_local_parameters => {
      :pf => "$pf_author",
      :qf => "$qf_author"
    }
  }
  
  search_fields << {
    :display_label => 'Title or Series',
    :key =>  'title',
    :solr_local_parameters => {
      :pf => "$pf_title",
      :qf => "$qf_title"
    }
  }
  
  search_fields << {
    :key =>  'journal',
    :solr_local_parameters => {
      :pf => "$pf_journal_title",
      :qf => "$qf_journal_title"
    }
  }
  
  search_fields << {
    :key =>  'subject',
    :solr_local_parameters => {
      :pf => "$pf_subject",
      :qf => "$qf_subject"
    }
  }

  search_fields << {
    :key =>  'keyword',
    :solr_local_parameters => {
      :pf => "$pf_keyword",
      :qf => "$qf_keyword"
    }
  }

  search_fields << {
    :key =>  'call_number',
    :solr_local_parameters => {
      :pf => "$pf_call_number",
      :qf => "$qf_call_number"
    }
  }
  search_fields << {
    :display_label => 'Publisher/Place of Publication',
    :key =>  'published',
    :solr_local_parameters => {
      :pf => "$pf_published",
      :qf => "$qf_published"
    }
  }
  search_fields << {
    :display_label => 'Year Published',
    :key => 'publication_date',
    :field => 'year_multisort_i',
    :range => 'true'
  }

  BlacklightAdvancedSearch.config[:article_search_fields] = search_fields = []
  search_fields << {
    :key => 'keyword',
    :primo_key => 'any',
    :display_label => 'Keyword'
  }
  search_fields << {
     :key => 'author',
     :primo_key =>  'creator',
     :display_label => 'Author'
   }
   search_fields << {
     :key => 'title',
     :primo_key =>  'title',
     :display_label => 'Title'
   }
   search_fields << {
     :key => 'journal',
     :primo_key =>  'jtitle',
     :display_label => 'Journal Title'
   }
   search_fields << {
     :key => 'publication_date',
     :primo_key => 'creationdate',
     :display_label => 'Year Published',
     :range => 'true'
   }
  
  

##
# The advanced search form displays facets as a limit option.
# By default it will use whatever facets, if any, are returned
# by the Solr qt request handler in use. However, you can use
# this config option to have it request other facet params than
# default in the Solr request handler, in desired.

# BlacklightAdvancedSearch.config[:form_solr_parameters] = {
  # "facet.field" => [
    # "format",
    # "lc_1letter_facet",
    # "language_facet"    
  # ],
  # "facet.limit" => -1,  # all facet values
  # "facet.sort" => "index"  # sort by index value (alphabetically, more or less)
# }
