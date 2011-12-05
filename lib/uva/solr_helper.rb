module UVA::SolrHelper

  require_dependency 'vendor/plugins/blacklight/lib/blacklight/solr_helper.rb'

  # set up search_params_logic, which will get sent with every search  
  # set up alias method chains so that we can use the methods provided by the plugin but add behaviors
  def self.included(base)
    base.solr_search_params_logic << :show_only_public_records
    base.solr_search_params_logic << :add_music_portal
    base.solr_search_params_logic << :add_max_per_page
    base.solr_search_params_logic << :add_facet_limit
    base.send(:include, UVACustomizations)
    base.class_eval do
      alias_method_chain :get_search_results, :customizations
      alias_method_chain :get_solr_response_for_field_values, :customizations
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

    # do what the plugin does, then wrap in UVA-ness
    def get_search_results_with_customizations(extra_controller_params={})
      solr_response, document_list = get_search_results_without_customizations(extra_controller_params)
      uva_document!(solr_response, document_list)
    end

    # do what the plugin does, then wrap in UVA-ness
    def get_solr_response_for_field_values_with_customizations(field, values, extra_controller_params={})
      solr_response, document_list = get_solr_response_for_field_values_without_customizations(field, values, extra_controller_params)
      uva_document!(solr_response, document_list)
    end

    # do what the plugin does, then wrap in UVA-ness and check to see if it's shadowed
    def get_solr_response_for_doc_id_with_customizations(id=nil, extra_controller_params={})
      solr_response, document = get_solr_response_for_doc_id_without_customizations(id, extra_controller_params)
      document.extend UVA::Document
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
  end
      
end
