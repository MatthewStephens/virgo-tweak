module UVA
  
  class RedirectNeeded < RuntimeError; end

  module SolrHelperOverride

    # set up search_params_logic, which will get sent with every search  
    def self.included(base)
      base.send :include, UVACustomizations

      base.solr_search_params_logic << :show_only_public_records
      base.solr_search_params_logic << :add_music_portal
      base.solr_search_params_logic << :add_video_portal
      base.solr_search_params_logic << :add_special_collections_lens
      base.solr_search_params_logic << :add_max_per_page
      base.solr_search_params_logic << :add_facet_limit
      base.solr_search_params_logic << :adjust_qt
    end
  
    class HiddenSolrID < RuntimeError; end
  
    # solr_search_params_logic methods take two arguments
    # @param [Hash] solr_parameters a hash of parameters to be sent to Solr (via RSolr)
    # @param [Hash] user_parameters a hash of user-supplied parameters (often via `params`)
    def show_only_public_records solr_parameters, user_parameters
      solr_parameters[:phrase_filters]||={}
      solr_parameters[:phrase_filters]["-shadowed_location_facet"] = ["HIDDEN"]    
    end
  
    # use music facets if it's the music portal
    def add_music_portal solr_parameters, user_parameters
      solr_parameters["facet.field"] = Blacklight.config[:facet_music][:field_names] if user_parameters[:portal] == 'music' and user_parameters[:action] != "facet"
    end
    
    # add format facet of video if it's the video portal
    def add_video_portal solr_parameters, user_parameters
      solr_parameters[:phrase_filters]||={}
      solr_parameters[:phrase_filters]["format_facet"]||=[]
      solr_parameters[:phrase_filters]["format_facet"] << "Video" if user_parameters[:portal] == 'video'
    end
    
    # add library facet of special collections if it's the special collections lens
    def add_special_collections_lens solr_parameters, user_parameters
      solr_parameters[:phrase_filters]||={}
      solr_parameters[:phrase_filters]["library_facet"]||=[]
      solr_parameters[:phrase_filters]["library_facet"] << "Special Collections" if user_parameters[:special_collections] == 'true'
    end
  
    # show as many search results as allowed if requested
    def add_max_per_page solr_parameters, user_parameters    
      solr_parameters[:per_page] = 100 if user_parameters[:show_max_per_page]
    end
  
    # set a facet limit based on user input
    def add_facet_limit solr_parameters, user_parameters
      solr_parameters["facet.limit"] = user_parameters["facet.limit"] if user_parameters["facet.limit"]
    end
    
    # toss old request handler mappings
    def adjust_qt solr_parameters, user_parameters
      swap_handler(user_parameters, 'subject_search', 'subject')
      swap_handler(user_parameters, 'title_search', 'title')
      swap_handler(user_parameters, 'journal_title_search', 'journal')
    end

    # swap request handler based on old qt to new search_field
    def swap_handler(user_parameters, original_qt, search_field)
      if user_parameters[:qt] and user_parameters[:qt] == original_qt
        user_parameters.delete(:qt)
        user_parameters[:search_field] = search_field
      end
    end

    module UVACustomizations
            
      # overriding from plugin to test for shadowedness
      def get_solr_response_for_doc_id(id=nil, extra_controller_params={})
        solr_response = find solr_doc_params(id).merge(extra_controller_params)
        raise Blacklight::Exceptions::InvalidSolrID.new if solr_response.docs.empty?
        document = SolrDocument.new(solr_response.docs.first, solr_response)
        raise HiddenSolrID if document.hidden?
        [solr_response, document]
      end
      
      # do what the plugin does but swap out qt if it's specified
      def solr_doc_params(id=nil)
        id ||= params[:id]
        params[:qt].blank? ? qt = :document : qt = params[:qt]
        # just to be consistent with the other solr param methods:
        {
          :qt => qt,
          :id => id # this assumes the document request handler will map the 'id' param to the unique key field
        }
      end
      
      # overriding b/c of broken bit in plugin
      def add_sorting_paging_to_solr(solr_parameters, user_params)
        # Omit empty strings and nil values.             
        # Apparently RSolr takes :per_page and converts it to Solr :rows,
        # so we let it. 
        [:page, :per_page, :sort].each do |key|
          solr_parameters[key] = user_params[key] unless user_params[key].blank?      
        end
        if solr_parameters[:sort].blank?
          # this part is broken in the plugin
          first_sort_field_key = Blacklight.config[:sort_fields_order].first
          default_sort_field = Blacklight.config[:sort_fields][first_sort_field_key]          
          solr_parameters[:sort] = default_sort_field.last unless default_sort_field.last.blank?
        end

        # limit to MaxPerPage (100). Tests want this to be a string not an integer,
        # not sure why.     
        solr_parameters[:per_page] = solr_parameters[:per_page].to_i > self.max_per_page ? self.max_per_page.to_s : solr_parameters[:per_page]      
      end
      
        
      ##
      # Take the user-entered query, and put it in the solr params, 
      # including config's "search field" params for current search field. 
      # also include setting spellcheck.q. 
      def add_query_to_solr(solr_parameters, user_parameters)
        ###
        # Merge in search field configured values, if present, over-writing general
        # defaults
        ###
        # legacy behavior of user param :qt is passed through, but over-ridden
        # by actual search field config if present. We might want to remove
        # this legacy behavior at some point. It does not seem to be currently
        # rspec'd. 
        solr_parameters[:qt] = user_parameters[:qt] if user_parameters[:qt]
        # overriding from plugin, where this is hard-coded as Blacklight.search_field_def_for_key
        search_field_def = search_field_def_for_key(user_parameters[:search_field])
        if (search_field_def)     
          solr_parameters[:qt] = search_field_def[:qt] if search_field_def[:qt]      
          solr_parameters.merge!( search_field_def[:solr_parameters]) if search_field_def[:solr_parameters]
        end

        ##
        # Create Solr 'q' including the user-entered q, prefixed by any
        # solr LocalParams in config, using solr LocalParams syntax. 
        # http://wiki.apache.org/solr/LocalParams
        ##         
        if (search_field_def && hash = search_field_def[:solr_local_parameters])
          local_params = hash.collect do |key, val|
            key.to_s + "=" + solr_param_quote(val, :quote => "'")
          end.join(" ")
          solr_parameters[:q] = "{!#{local_params}}#{user_parameters[:q]}"
        else
          solr_parameters[:q] = user_parameters[:q] if user_parameters[:q]
        end

        ##
        # Set Solr spellcheck.q to be original user-entered query, without
        # our local params, otherwise it'll try and spellcheck the local
        # params! Unless spellcheck.q has already been set by someone,
        # respect that.
        #
        # TODO: Change calling code to expect this as a symbol instead of
        # a string, for consistency? :'spellcheck.q' is a symbol. Right now
        # rspec tests for a string, and can't tell if other code may
        # insist on a string. 
        solr_parameters["spellcheck.q"] = user_parameters[:q] unless solr_parameters["spellcheck.q"]
      end
      
      
      
    end
      
  end
  
end
