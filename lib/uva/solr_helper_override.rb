require 'lib/uva/search_fields_override'

module UVA
  
  class RedirectNeeded < RuntimeError; end

  module SolrHelperOverride

    # set up search_params_logic, which will get sent with every search  
    # set up alias method chains so that we can use the methods provided by the plugin but add behaviors
    def self.included(base)
      base.send :include, Blacklight::SolrHelper
      base.solr_search_params_logic << :show_only_public_records
      base.solr_search_params_logic << :add_music_portal
      base.solr_search_params_logic << :add_max_per_page
      base.solr_search_params_logic << :add_facet_limit
      base.send :include, UVACustomizations
      base.send :include, Blacklight::SearchFields
      base.send :include, UVA::SearchFieldsOverride
      base.class_eval do
        alias_method_chain :get_solr_response_for_doc_id, :customizations
        alias_method_chain :solr_doc_params, :customizations
      end
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
      solr_parameters["facet.field"] = Blacklight.config[:facet_music][:field_names] if user_parameters[:portal] == 'music'
    end
  
    # show as many search results as allowed if requested
    def add_max_per_page solr_parameters, user_parameters    
      solr_parameters[:per_page] = 100 if user_parameters[:show_max_per_page]
    end
  
    # set a facet limit based on user input
    def add_facet_limit solr_parameters, user_parameters
      solr_parameters["facet.limit"] = user_parameters["facet.limit"] if user_parameters["facet.limit"]
    end
  
    module UVACustomizations
      
      # do what the plugin does, then wrap in UVA-ness and check to see if it's shadowed
      def get_solr_response_for_doc_id_with_customizations(id=nil, extra_controller_params={})
        solr_response, document = get_solr_response_for_doc_id_without_customizations(id, extra_controller_params)
        #document.extend UVA::Document
        raise HiddenSolrID if document.hidden?
        [solr_response, document]
      end
    
      # do what the plugin does but swap out qt if it's specified
      def solr_doc_params_with_customizations(id=nil)
        my_params = solr_doc_params_without_customizations(id)
        my_params[:qt] = params[:qt] unless params[:qt].blank? rescue false
        my_params
      end
    
      # wrap a solr response and document list in UVA-ness
      def uva_document!(solr_response, document_list)
        document_list.each{|d|d.extend UVA::Document} # all methods in lib/uva/document.rb are available now 
        [solr_response, document_list]
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
        test
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
