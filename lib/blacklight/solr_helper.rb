module Blacklight::SolrHelper

  require_dependency 'vendor/plugins/blacklight/lib/blacklight/solr_helper.rb'
  
  class HiddenSolrID < RuntimeError; end
   
  # overriding from plugin to account for shadowed records, music portal
  def get_search_results(extra_controller_params={})
    add_music_portal(extra_controller_params)
    my_solr_params = self.solr_search_params(extra_controller_params)
    add_shadowing(my_solr_params)
    solr_response = Blacklight.solr.find my_solr_params
    document_list = solr_response.docs.collect {|doc| SolrDocument.new(doc)}
    document_list.each{|d|d.extend UVA::Document} # all methods in lib/uva/document.rb are available now 
    cleanup_music_portal(extra_controller_params)
    [solr_response, document_list]
  end
  
  # given a field name and array of values, get the matching SOLR documents
  # overriding from plugin to account for shadowed records
   def get_solr_response_for_field_values(field, values, extra_controller_params={})
     if params and params[:show_max_per_page]
       extra_controller_params[:per_page] = 100
     end
     value_str = "(\"" + values.to_a.join("\" OR \"") + "\")"
     solr_params = {
       :qt => "standard",   # need boolean for OR
       :q => "#{field}:#{value_str}",
       'fl' => "*",
       'facet' => 'false',
       'spellcheck' => 'false'
     }
     my_solr_params = self.solr_search_params(solr_params.merge(extra_controller_params))
     add_shadowing(my_solr_params)
     solr_response = Blacklight.solr.find my_solr_params
     document_list = solr_response.docs.collect{|doc| SolrDocument.new(doc) }
     document_list.each{|d|d.extend UVA::Document} # all methods in lib/uva/document.rb are available now 
     [solr_response,document_list]
   end
  
  
  # a solr query method
  # retrieve a solr document, given the doc id
  # TODO: shouldn't hardcode id field;  should be setable to unique_key field in schema.xml
  def get_solr_response_for_doc_id(id=nil, extra_controller_params={})
    response = Blacklight.solr.find solr_doc_params(id, extra_controller_params)
    raise InvalidSolrID.new if response.docs.empty?
    document = SolrDocument.new(response.docs.first)
    document.extend UVA::Document
    raise HiddenSolrID if document.hidden?
    [response, document]  
  end
  
  # gets the solr data for the provided bookmarks
  def get_solr_response_for_bookmarks(bookmarks=[], extra_controller_params={})
    bookmarks.each { |b|
      response, document = get_solr_response_for_doc_id(b.document_id)
      b.set_document(document)
    }
  end
  
  def get_facet_pagination(facet_field, extra_controller_params={})
    my_solr_params = self.solr_facet_params(facet_field, extra_controller_params)
    add_shadowing(my_solr_params)

     # Make the solr call
     response = Blacklight.solr.find(my_solr_params)

     limit =       
       if respond_to?(:facet_list_limit)
         facet_list_limit.to_s.to_i
       elsif my_solr_params[:"f.#{facet_field}.facet.limit"]
         my_solr_params[:"f.#{facet_field}.facet.limit"] - 1
       else
         nil
       end


     # Actually create the paginator!
     # NOTE: The sniffing of the proper sort from the solr response is not
     # currently tested for, tricky to figure out how to test, since the
     # default setup we test against doesn't use this feature. 
     return     Blacklight::Solr::FacetPaginator.new(response.facets.first.items, 
       :offset => my_solr_params['facet.offset'], 
       :limit => limit,
       :sort => response["responseHeader"]["params"]["f.#{facet_field}.facet.sort"] || response["responseHeader"]["params"]["facet.sort"]
     )
   end
    
  # overriding from plugin to avoild fl=*, since that causes errors with some
  # records in our solr index.  Also adding shadowing 
  def get_single_doc_via_search(extra_controller_params={})
    my_solr_params = solr_search_params(extra_controller_params)
    my_solr_params[:per_page] = 1
    add_shadowing(my_solr_params)
    response = Blacklight.solr.find(my_solr_params).docs.first
    response
  end
  
  # overriding from plugin b/c we want to read facet.limit from params
  def solr_facet_params(facet_field, extra_controller_params={})
    input = params.deep_merge(extra_controller_params)

    # First start with a standard solr search params calculations,
    # for any search context in our request params. 
    solr_params = solr_search_params(extra_controller_params)

    # Now override with our specific things for fetching facet values
    solr_params[:"facet.field"] = facet_field
     
    # Need to set as f.facet_field.facet.limit to make sure we
    # override any field-specific default in the solr request handler. 
    solr_params[:"f.#{facet_field}.facet.limit"] = 
      if params && params["facet.limit"]
        params["facet.limit"].to_i + 1
      elsif solr_params["facet.limit"] 
        solr_params["facet.limit"] + 1
      elsif respond_to?(:facet_list_limit)
        facet_list_limit.to_s.to_i + 1
      else
        20 + 1
      end
    solr_params['facet.offset'] = input[  Blacklight::Solr::FacetPaginator.request_keys[:offset]  ].to_i # will default to 0 if nil
    solr_params['facet.sort'] = input[  Blacklight::Solr::FacetPaginator.request_keys[:sort] ]     
    solr_params[:rows] = 0

    return solr_params
  end
    
  # overriding from plugin so we can specify the qt (we want a lean one for image requests)
  def solr_doc_params(id=nil, extra_controller_params={})  
    id ||= params[:id]
    (params[:qt].blank? ? qt = :document : qt = params[:qt]) rescue qt = :document
     #just to be consistent with the other solr param methods:
    input = (params.deep_merge(extra_controller_params) rescue extra_controller_params)
    {
      :qt => qt,
      :id => id
    }
  end
  
  def add_music_portal(extra_controller_params={})
    if extra_controller_params[:portal] == 'music'
      extra_controller_params[:facets] = Blacklight.config[:facet_music][:field_names]
    end
  end
  
  def cleanup_music_portal(extra_controller_params={})
    extra_controller_params.delete(:facets)
  end

  def add_shadowing(params_to_send_to_solr={})
    params_to_send_to_solr[:phrase_filters]||={}
    params_to_send_to_solr[:phrase_filters]["-shadowed_location_facet"] = ["HIDDEN"]    
  end
  
  # adds the value and/or field to params[:f]
  def add_facet_param(field, value, my_params = params)
    included = my_params[:f][field].include?(value) ? true : false rescue false
    p = my_params.dup.symbolize_keys!
    unless included
      p[:f]||={}
      p[:f][field]||=[]
      p[:f][field].push(value)
    end
    p
  end

end
