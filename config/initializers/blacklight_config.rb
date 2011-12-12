# You can configure Blacklight from here. 
#   
#   Blacklight.configure(:environment) do |config| end
#   
# :shared (or leave it blank) is used by all environments. 
# You can override a shared key by using that key in a particular
# environment's configuration.
# 
# If you have no configuration beyond :shared for an environment, you
# do not need to call configure() for that envirnoment.
# 
# For specific environments:
# 
#   Blacklight.configure(:test) {}
#   Blacklight.configure(:development) {}
#   Blacklight.configure(:production) {}
# 

Blacklight.configure(:shared) do |config|
        
  ##############################
      
  config[:default_solr_params] = {
    :qt => "search",
    :per_page => 20
  }

  # solr field values given special treatment in the show (single result) view
  config[:show] = {
    :html_title => "title_display",
    :heading => "title_display",
    :display_type => "format"
  }

  # solr fld values given special treatment in the index (search results) view
  config[:index] = {
    :show_link => "title_display",
    :display_type => "format"
  }

  # solr fields that will be treated as facets by the blacklight application
  #   The ordering of the field names is the order of the display 
  # If any new facets are added here, they will need to be added to solrconfig.xml as a facet.field
  
  config[:facet] = {
    :home_field_names => (facet_fields = [
      "library_facet",
      "format_facet",
      "call_number_facet",
      "digital_collection_facet"
    ]),
    
    :advanced_field_names => (facet_fields = [
      "library_facet",
      "format_facet",
      "call_number_broad_facet",
      "digital_collection_facet"
    ]),
    
    :field_names =>  (facet_fields = [
      "library_facet",
      "format_facet",
      "published_date_facet",
      "author_facet",
      "subject_facet",
      "language_facet",
      "call_number_facet",
      "region_facet",
      "digital_collection_facet",
      "source_facet",
      "series_title_facet"
    ]),
    :labels => {
      "library_facet"            => "Library",
      "format_facet"             => "Format",
      "published_date_facet"     => "Publication Era",
      "author_facet"             => "Author",
      "subject_facet"            => "Subject",
      "language_facet"           => "Language",
      "call_number_facet"        => "Call Number",
      "region_facet"             => "Geographic Location",
      "digital_collection_facet" => "Digital Collection",
      "source_facet"             => "Source",
      "series_title_facet"       => "Series Title",
      "call_number_broad_facet"  => "Call Number"
    },
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    :limits => {  }
  }
  
  config[:facet_articles] = {
    :home_field_names => (facet_fields = [
      "creator",
      "topic",
      "creationdate",
      "rtype",
      "lang",
      "jtitle",
      "tlevel"
    ]),
    :field_names => (facet_fields = [
      "tlevel",
      "creationdate",
      "topic",            
      "rtype",
      "jtitle",
      "creator",
      "lang"
    ]),
    :labels => {
      "tlevel" => "Designation",
      "creationdate" => "Year", 
      "topic" => "Subject",
      "rtype" => "Format", 
      "jtitle" => "Journal",            
      "creator" => "Author",
      "lang" => "Language"
    }
  }

  config[:facet_music] = {
    :home_field_names => (facet_fields = [
      "library_facet",
      "format_facet",
      "recordings_and_scores_facet",
      "recording_format_facet",
      "instrument_facet",
      "music_composition_era_facet",
      "language_facet",
      "source_facet",
     ]),
     :field_names => (facet_fields = [
       "library_facet",
       "format_facet",
       "recordings_and_scores_facet",
       "recording_format_facet",
       "instrument_facet",
       "music_composition_era_facet",
       "author_facet",
       "language_facet",
       "source_facet",
       "region_facet",
       "subject_facet"    
       ]),
     :labels => {
       "library_facet" => "Library",
       "format_facet" => "Format",
       "recordings_and_scores_facet" => "Recordings and scores",
       "recording_format_facet" => "Recording format",
       "instrument_facet" => "Instrument",
       "music_composition_era_facet" => "Composition era",
       "author_facet" => "Author",
       "language_facet" => "Language",
       "source_facet" => "Source",
       "region_facet" => "Region",
       "subject_facet" => "Subject"
       },
       :limit => 6
   }
   
   config[:facet_video] = {
      :field_names => (facet_fields = [
        "library_facet",
        "format_facet",
        "subject_facet",
        "language_facet",
        "series_title_facet"   
        ]),
      :labels => {
        "library_facet" => "Library",
        "format_facet" => "Format",
        "subject_facet" => "Subject",
        "language_facet" => "Language",
        "series_title_facet" => "Series Title"
        },
        :limit => 6
    }

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config[:default_solr_params] ||= {}
#    config[:default_solr_params][:"facet.field"] = facet_fields


  # solr fields to be displayed in the index (search results) view
  #   The ordering of the field names is the order of the display 
  config[:index_fields] = {
    :field_names => [
      "title_display",
      "author_display",
      "format_facet",
      "language_facet",
      "published_date_display",
      "location_facet"
    ],
    :labels => {
      "title_display"        => "Title:",
      "author_display"       => "Author:",
      "format_facet"   => "Format:",
      "language_facet" => "Language:",
      "published_date_display"    => "Published:",
      "location_facet"  =>  "Location:"
    }
  }

  # solr fields to be displayed in the show (single result) view
  #   The ordering of the field names is the order of the display 
  config[:show_fields] = {
    :field_names => [
      "year_facet",
      "author_display",
      "digital_collection_facet",
      "media_resouce_id_display",
      "title_display",
      "subtitle_display",
      "format_facet",
      "language_facet",
      "note_display",
      "published_date_display",
      "isbn_display"
    ],
    :labels => {
      "year_facet"  =>  "Date:",
      "author_display"        => "Creator:",
      "digital_collection_facet"  => "Collection:",
      "media_resource_id_display" =>  "Type:",
      "title_display"         => "Title:",
      "subtitle_display"     => "Subtitle:",
      "format_facet"    => "Format:",
      "language_facet"  => "Language:",
      "note_display"    => "Note:",
      "published_date_display"     => "Published:",
      "isbn_display"          => "ISBN:"      
    }
  }

  # "fielded" search select (pulldown)
  # label in pulldown is followed by the name of a SOLR request handler as 
  # defined in solr/conf/solrconfig.xml
  config[:search_fields] ||= []
  config[:search_fields] << {
    :display_label => 'Keywords', 
    :key => 'keyword', 
    :qt => 'search'
  }
  config[:search_fields] << {
    :display_label => 'Author', 
    :key => 'author',
    :qt => 'search',
    :solr_local_parameters => {
      :qf => "$qf_author",
      :pf => "$pf_author"
    }
  }
  config[:search_fields] << {
    :display_label => 'Title', 
    :key => 'title',
    :qt => 'search',
    :solr_local_parameters => {
      :qf => "$qf_title",
      :pf => "$pf_title"
    }
  }
  config[:search_fields] << {
    :display_label => 'Journal Title', 
    :qt => 'search', 
    :key => 'journal',
    :solr_local_parameters => {
      :qf => "$qf_journal_title",
      :pf => "$pf_journal_title"
    }
  }
  config[:search_fields] << {
    :display_label => 'Subject', 
    :key => 'subject',
    :qt => 'search',
    :solr_local_parameters => {
      :qf => "$qf_subject",
      :pf => "$pf_subject"
    }
  }
  config[:search_fields] << {
    :display_label => 'Call Number', 
    :key => 'call_number',
    :qt => 'search',
    :solr_local_parameters => {
      :qf => "$qf_call_number",
      :pf => "$pf_call_number"
    }
  }
  
  
  config[:music_search_fields] ||= []
  config[:music_search_fields] << {
    :display_label => 'Keywords', 
    :key => 'music_search',
    :qt => 'search',
    :solr_local_parameters => {
      :qf => "$qf_music",
      :pf => "$pf_music"
    }
  }
  config[:music_search_fields] << {
    :display_label => 'Author', 
    :key => 'music_author',
    :qt => 'search',    
    :solr_local_parameters => {
      :qf => "$qf_author",
      :pf => "$pf_author"
    }
  }
  config[:music_search_fields] << {
    :display_label => 'Title',
    :key => 'music_title',
    :qt => 'search',    
    :solr_local_parameters => {
      :qf => "$qf_title",
      :pf => "$pf_title"
    }
  }
  config[:music_search_fields] << {
    :display_label => 'Journal Title', 
    :qt => 'search', 
    :key => 'music_journal',
    :solr_local_parameters => {
      :qf => "$qf_journal_title",
      :pf => "$pf_journal_title"
    }
  }
  config[:music_search_fields] << {
    :display_label => 'Subject', 
    :key => 'music_subject',
    :qt => 'search',    
    :solr_local_parameters => {
      :qf => "$qf_subject",
      :pf => "$pf_subject"
    }
  }
  config[:music_search_fields] << {
    :display_label => 'Call Number', 
    :key => 'music_call_number',
    :qt => 'search',    
    :solr_local_parameters => {
      :qf => "$qf_call_number",
      :pf => "$pf_call_number"
    }
  }
  
  config[:video_search_fields] ||= []
  config[:video_search_fields] << {
    :display_label => 'Keywords', 
    :key => 'video_search',
    :qt => 'search',    
  }
  config[:video_search_fields] << {
    :display_label => 'Title', 
    :key => 'video_title',
    :qt => 'search',    
    :solr_local_parameters => {
      :qf => "$qf_title",
      :pf => "$pf_title"
    }
  }
  config[:video_search_fields] << {
    :display_label => 'Subject', 
    :key => 'video_subject',
    :qt => 'search',
    :solr_local_parameters => {
      :qf => "$qf_subject",
      :pf => "$pf_subject"
    }
  }
  config[:video_search_fields] << {
    :display_label => 'Call Number', 
    :key => 'video_call_number',
    :qt => 'search',    
    :solr_local_parameters => {
      :qf => "$qf_call_number",
      :pf => "$pf_call_number"
    }
  }
  
  config[:extra_search_fields] ||= []
  config[:extra_search_fields] << {
    :display_label => 'Publisher/Place of Publication',
    :key => 'published',
    :qt => 'search',
    :solr_local_parameters => {
      :qf => "$qf_published",
      :pf => "$pf_published"
    }
  }
  config[:extra_search_fields] << {
    :display_label => 'Year Published',
    :key => 'publication_date',
    :field => 'year_multisort_i',
    :range => 'true'
  }
  
  
  # order in which sort fields should occur
  config[:sort_fields_order] = []
  config[:sort_fields_order] << 'relevancy'
  config[:sort_fields_order] << 'received'
  config[:sort_fields_order] << 'published'
  config[:sort_fields_order] << 'published_a'
  config[:sort_fields_order] << 'title'
  config[:sort_fields_order] << 'author'
  config[:sort_fields_order] << 'articles_relevancy'
  config[:sort_fields_order] << 'articles_date'
  
  # "sort results by"
  # format is 'sort_key' => ['label to use on form', 'solr_sort']
  config[:sort_fields] = {
    'relevancy' => ['Relevancy', 'score desc, year_multisort_i desc'],
    'received' => ['Date Received', 'date_received_facet desc'],
    'published' => ['Date Published - newest first', 'year_multisort_i desc'],
    'published_a' => ['Date Published - oldest first', 'year_multisort_i asc'],
    'title' => ['Title', 'title_sort_facet asc, author_sort_facet asc'],
    'author' => ['Author', 'author_sort_facet asc, title_sort_facet asc'],
  }
  
  config[:articles_sort_fields] = {
    'articles_relevancy' => ['Relevancy', 'popularity'],
    'articles_date' => ['Date', 'scdate']
  }
  
  # the maximum number of search results to allow display of a spelling 
  #  ("did you mean") suggestion, if one is available.
  config[:spell_max] = 5
  
  # the number of bookmarks to display per page
  config[:bookmarks_per_page] = 20
  
end

