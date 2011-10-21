require_dependency 'vendor/plugins/blacklight/app/helpers/application_helper.rb'
require 'fastercsv'

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
   
  ############# local methods - not included in the Blacklight plugin (see overrides afterwards)
  include UVA::Fedora  
  include BlacklightAdvancedSearch::AdvancedSearchFields
  include UVA::ScopeHelper

  
  # Slices the @featured_documents up into to arrays/"rows"
  # This makes it easy to do "rows" in the view.
  # returns an array
  def featured_documents_rows
    # slice up into 2 rows of 4 items each if possible
    if @featured_documents.size >= 4
      fd = @featured_documents.collect
      # split into two arrays, 4 items in each, remove the nil items (see Ruby Array.slice)
      # from each "row"
      rows = [fd[0..3], fd[4..7].compact]
    else
      # just one array, items 1-4, remove the nils
      rows = [@featured_documents.collect[0..3].compact]
    end
    # remove any empty "rows"
    rows.delete_if{|v|v.empty?}
  end
  
  # this method is highly questionable, but we want to use link_to_document to take
  # advantage of the smoke and mirrors used with the "counter", but we need to interleave
  # a <span> within the <a href> tags in order for the ajax loading to work correctly
  #
  def link_to_document_from_cover(doc, opts={:span => "", :label=>Blacklight.config[:index][:show_link].to_sym, :counter => nil, :bookmarks_view => false})
    span_open = "<span class=\"#{opts[:span]}\" title=\"#{doc[:id]}\">\n"
    span_close = "</span>\n"
    val = link_to_document(doc, opts={:label=>Blacklight.config[:index][:show_link].to_sym, :counter => opts[:counter], :bookmarks_view => opts[:bookmarks_view]})
    val.insert(val.index(">") + 1, span_open)
    # unforunately, the :plugin setting doesn't work when referencing an image
    # in the /javascript path, so a hardcoded path like this will have to do for now
    val.insert(val.rindex("<"), (image_tag javascript_path('ext-2.2/resources/images/default/shared/blue-loading.gif'), :class=>'ajaxLoader', :width=>'16', :height=>'16', :alt => 'Loading') + span_close)
    val 
  end
   
  # gets the location for a document, or "Multiple Locations" if there is more than 1
  def location_listing(document)
    libraries = document.values_for(:library_facet)
    locations = document.values_for(:location_facet)
    locations2 = document.values_for(:location2_facet)
    return '' if libraries.nil? or locations.nil?
    if special_collections_lens?
      libraries = libraries.select{ |lib| lib =~ /Special Collections/ }
      return libraries[0]
    end
    return '' if locations.length == 0
    return 'Multiple locations' if libraries.length > 1 or locations.length > 1
    return locations2[0] if locations2[0] =~ /Special Collections/
    return locations2[0] if locations2[0] =~ /Reserve/
    return (document.values_for(:library_facet)[0] + " " + locations[0]) rescue locations[0]
  end
  
  # gets a list of the call numbers for a document, or "Multiple call numbers" if there are more than 3
  def call_number(document, sep=";", default='n/a')
    values = document.values_for(:call_number_display)
    return '' if values.nil?
    values.delete_if {|val| val =~ /VOID/i }
    return '' if values.empty?
    return '' if location_listing(document) == 'Multiple locations'
    return '' if document.online_only?
    return 'Multiple call numbers' if values.size > 3
    values.join(sep)
  end
  
  # return first call number along with how many call numbers there are
  def first_call_number(document)
    values = document.values_for(:call_number_display)
    return '' if values.nil?
    values.delete_if {|val| val =~ /VOID/i }
    return '' if values.empty?
    return "#{values[0]} (1/#{values.count})"
  end
  
  # make a truncated version of the title for SMS
  def shortened_title(document)
    val = truncate(full_title(document), :length => 50)
    val
  end
  
  # make a truncated author listing for SMS
  def shortened_authors(document)
    authors = ""
    author_list = document.author_type_fields
    unless author_list.empty?
      authors = truncate(author_list.values.join("; "), :length => 40)
    end
    authors
  end
  
  # used on show partials for title
  def title(document)
    (document[:title_display].first rescue "Title not available")
  end
  
  # used on show partials for part
  def part(document)
    " " + document[:part_display].first rescue ""
  end
    
  # used on show partials for medium
  def medium(document)
	  document[:medium_display].first.match(/^\[/) ? " " + document[:medium_display].first : " ["+ document[:medium_display].first + "]" rescue ""
  end
  
  # used to generate separator between medium and subtitle
  def separator(document)
    medium = medium(document)
    ( medium.blank? or medium.end_with?("]") ) ?  " : "  :  " "
  end

  # used on show partials for subtitle
  def subtitle(document)
    separator(document) + document[:subtitle_display].first rescue ""
  end
  
  # used on show partials for date_coverage
  def date_coverage(document)
    " " + document[:date_coverage_display].first rescue ""
  end
  
  # used on show partials for date_bulk_coverage
  def date_bulk_coverage(document)
    " " + document[:date_bulk_coverage_display].first rescue ""
  end
  
  def form(document)
    " " + document[:form_display].first rescue ""
  end
    
  def full_title(document, style=false)
    title = title(document)
    title += "." if !part(document).blank?
    title += "<span class=\"documentPart\">" if style
    title += part(document)
    title += "</span><span class=\"documentMedium\">" if style
    title += medium(document)
    title += "</span><span class=\"documentSubtitle\">" if style
    title += subtitle(document)
    title += "</span><span class=\"documentDate_coverage\">" if style
    title += date_coverage(document)
    title += "</span><span class=\"documentDate_bulk_coverage\">" if style
    title += date_bulk_coverage(document)
    title += "</span><span class=\"documentForm\">" if style
    title += form(document)
    title += "</span>" if style
    title
  end
    
  
  # determines which label to use for the "label number" field
  def label_no_label(document)
    return 'Publisher/plate no.' if document.doc_sub_type == :musical_score
    return 'Label no.' if document.doc_sub_type == :musical_recording
    'Publisher no.'
  end
  
  # determines which verb to use for accessing the document online
  def online_access_verb(document)
    verbs = { :book => 'Read',
              :non_musical_recording => 'Listen',
              :musical_recording => 'Listen',
              :video => 'Watch'
             }
    vals = document.fetch :format_facet
    vals.collect do |f|
      clean_f = f.to_s.sub(/_facet$|_display$/,'').gsub(/-| /,'_').downcase
      return verbs[clean_f.to_sym] || 'Access'
    end
  end
  
  # returns a properly encoded link to this document on xtf.lib
  def xtf_link(display_text, document)
    url = "http://xtf.lib.virginia.edu/xtf/view?docId=#{document.fedora_doc_id}"
    if !params[:q].blank?
      url = url + "&query=#{h(params[:q])}"
    end
    link_to display_text, url, :target=>'_blank'
  end
  
  # returns a properly encoded link to this document on xtf.lib (URL as link text)
  def xtf_url_link(document)
    url = "http://xtf.lib.virginia.edu/xtf/view?docId=#{document.fedora_doc_id}"
    if !params[:q].blank?
      url = url + "&query=#{h(params[:q])}"
    end
    link_to url, url, :target=>'_blank'
  end
   
  # used by the digital library/image collection views
  def image_url_exists?(image_src)
    Blacklight::Utils.valid_image_url?(image_src)
  end
   
  # returns the url for bookmarking this document in delicious
  def delicious_export_url(document)
    base_url="http://del.icio.us/post"
    url = url_for(:controller => 'catalog', :action => 'show', :id => document.value_for(:id), :only_path => false)
    title=document.value_for(:title_display, '; ', document.value_for(:id))
    "#{base_url}?url=#{URI.escape(url)}&title=#{URI.escape(title)}"
  end
    
  # determines if the supplied link is a link to an EAD
  def link_to_ead?(link)
    link =~ /^http:\/\/ead\.lib\.virginia\.edu.*file=viu.*\.xml/
  end
  
  def link_to_leo(doc, label, style="")
    if doc.availability.leoable?
      return link_to_ilink_record(doc, label, style)
    end
  end
  
  def link_to_ilink_record(doc, label, style="")
    linkable = doc.availability.linkable_to_ilink? rescue true
    if linkable
      link_to label, 'http://virgo.lib.virginia.edu/uhtbin/cgisirsi/uva/0/0/5?searchdata1=' + doc.ckey + '{CKEY}', :target => '_blank', :class => style
    end
  end
  
  # text to display if it's a sas_only item
  def sas_only_text(doc)
    if doc.sas_only?
      return 'This item is only available to Semester At Sea participants.'
    end
  end
  
  # makes a list of the ISBNs, LCCNs, and OCLC numbers for the given document
  def google_preview_numbers(document)
    numbers = []    
    document.marc_display.isbn(document.doc_sub_type).each do |isbn|
      numbers << "ISBN:#{isbn}"
    end
    document.marc_display.oclc_number.each do |num|
      numbers << "OCLC:#{num.gsub(/[a-zA-Z]/,'')}"
    end
    document.marc_display.lc_control_number.each do |num|
      numbers << "LCCN:#{num}"
    end
    numbers.inspect
  end
  
  # parses :url_display, which has the format url||label (often label is missing)
  def link_to_online_access(document, separator = "<br />", link_text = "")
    return if document.get(:url_display).nil?
    out = ''
    document.values_for(:url_display).each do |string|
      parts = string.split('||')
      url = parts[0]
      unless link_text.blank?
        label = link_text
      else   
        label = parts[1]||online_access_verb(document) + " online"
      end
      out += link_to(label, url, :target => '_blank') + separator
    end
    out
  end
      
  # returns the list of facets from the config/initializers file
  def facet_list
    Blacklight.config[:facet][:field_names]
  end
   
  # which facets are in the params list
  def facet_params
    params[:f]
  end
   
  # lets us know if there are facets in the params list
  def facet_params?
    facet_params.size > 0 rescue false
  end
  
  # how many facet values should be displayed in the sidebar
  #
  def facet_limit
    Blacklight.config[:facet][:limit]
  end
  
  # Returns the default sort pattern for the facet values
  # If we are generating this link prior to actually visiting the facet list (i.e. - the "more>>" link),
  # then we want a different sort option to appear than if we are already viewing the facet values 
  # at the page /catalog/facet/facet_name.
  def facet_sort_scheme(facet_name = '')
    if params[:facet_sort].blank?
      return 'alpha' if facet_name == 'call_number_facet'
      return 'alpha' if facet_name == 'subject_facet' and params[:portal] == 'video'
      return 'hits'
    end
    return params[:facet_sort]
  end

  # determines what the inverse values and labels of the current facet sort is
  def facet_sort_inverse(facet_name = '')
    return ['hits', 'Number of Results'] if facet_sort_scheme(facet_name) == 'alpha'
    return ['alpha', 'A-Z'] if facet_sort_scheme(facet_name) == 'hits'
  end
  
  # determines what label we should assign to the facet inverse  
  def facet_sort_inverse_label(facet_name = '')
    return facet_sort_inverse(facet_name)[1]  
  end
  
  # determines that the value we should assign to the facet inverse
  def facet_sort_inverse_value(facet_name='')
    return facet_sort_inverse(facet_name)[0]
  end
  
  # determines the current sort behavior
  def current_facet_sort(facet_name = '')
    return 'Number of Results' if facet_sort_scheme(facet_name) == 'hits'
    return 'A-Z' if facet_sort_scheme(facet_name) == 'alpha'
  end
  
  # sorts facet values in memory, after lower-casing them
  # we are doing this because solr sorting doesn't lowercase, so things like "eBooks" 
  # don't sort the way we'd want them to 
  def facet_sort!(facet_name='', items=[])
    if facet_sort_scheme(facet_name) == 'alpha'
      items = items.sort! { |a,b| a.value.downcase <=> b.value.downcase }
    else
      items = items.sort! { |a,b| -(a.hits.to_i) <=> -(b.hits.to_i) }
    end
    items
  end
   
  # sifts through params to see what we should keep for facet values
  def params_for_facet_values
    p = {}
    keepers = [:f, :f_inclusive, :q, :qt, :sort, :portal, :search_field, :op]
    keepers << advanced_search_params
    keepers = keepers.flatten
    keepers.each do |k|
      p.merge!(k=>params[k]) unless params[k].blank?
    end
    scrunge_portal(p)
    p
  end
  
  # gets the advanced search param list
  def advanced_search_params
    fields = []    
    BlacklightAdvancedSearch.config[:search_fields].each do |field_def|
      if field_def[:range]
        fields << "#{field_def[:key]}_start".to_sym
        fields << "#{field_def[:key]}_end".to_sym
      else
        fields << field_def[:key].to_sym
      end
    end
    fields
  end
  
  # removes references to the current portal from the parameters if we are in the default portal
  def scrunge_portal(my_params)
    my_params.delete_if { |key, value|
      key.to_sym == :portal and value == 'all' and (value == session[:search][:portal]  or !session[:search][:portal])
    }
  end

  def scrunge_page(my_params)
    my_params.delete_if { |key, value|
      key.to_sym == :page
    }
  end
  
  # Takes a string of XML containing a <descmeta> document, returns a string
  # of HTML for display within a <dl> element
  def show_descmeta(descmeta_xml_string)
    require 'nokogiri'
    xslt = Nokogiri::XSLT(open('lib/uva/xsl/descmeta.xsl'))
    # Transform <descmeta> XML to HTML (namely <dt> and <dd> elements) using XSLT
    dl_entries = xslt.apply_to(Nokogiri::XML(descmeta_xml_string))
    # Make a few substitutions that are better handled in Ruby than XSLT 1.0
	  dl_entries.gsub!(/(<dd>)<author_link>([^<]*)<\/author_link>(<\/dd>)/) {|match| $1 + link_to($2, catalog_index_path({:focus=>'author', :q=>$2})) + $3}
	  dl_entries.gsub!(/(<dt>)<titlecase>([^<]*)<\/titlecase>(<\/dt>)/) {|match| $1 + $2.titlecase + $3}
	  # Return HTML string
	  return dl_entries
  end

  # Returns a string containing the title suitable for display as the heading for the item
  def get_heading_title(main_title_display, series_title_display, title_display)
    # Use main_title_display + series_title_display if available; otherwise
    # fall back to title_display
    if main_title_display == 'n/a'
      out = title_display
    else
      out = main_title_display.strip
      unless series_title_display == 'n/a'
        out += ';' unless out =~ /[,\.;]$/
        out += ' ' + series_title_display
      end
    end
    return out
  end

  # Returns a string containing the title of an image for use in the @title
  # attribute of <a> elements
  def get_image_title(document, index, default = nil)
    # Use main_title_display + image description if available; otherwise
    # fall back to default value
    begin
      image_description = document.values_for(:media_description_display)[index].gsub(/<[^>]+>/,'').strip
      raise if image_description.blank?
      main_title_display = document.value_for(:main_title_display).strip
      raise if main_title_display.blank? or main_title_display == 'n/a'
      sep = main_title_display =~ /[,\.;]$/ ? ' ' : ', '
      return main_title_display + sep + image_description
    rescue
      return default.to_s
    end
  end

  # some digital library texts have a main_title_display, and we want to use that if we can
  def dl_text_title(document)
    document.value_for(:main_title_display) == 'n/a' ? document.value_for(:title_display) : document.value_for(:main_title_display)
  end
  
  # determines if we are in the special collections lens
  def special_collections_lens?
    return true if !session.nil? && session[:special_collections]
    false
  end
  
  # makes a link to the special collections request if appropriate
  def special_collections_request_link(document, limit=0)
    if display_special_collections_request_link?(document.availability) && (limit == 0 or document.availability.holdings.size > limit)
      link = link_to "&rarr; Request this Item &larr;", start_special_collections_request_path(@document[:id])
      return "<div class=\"specialCollectionsRequestLink\">#{link}</div>"
    end
  end
  
  # determines if leo/recall links should display
  def leo_and_recall_links(document)
    if !special_collections_lens?
      link1 = ''
      if document.availability and document.availability.might_be_holdable?
        link1 = link_to('Request Unavailable Item&nbsp;&nbsp;&middot;&nbsp;&nbsp;', start_hold_account_request_path(document[:id], :popup => "true"), :class => 'recall initiate-request')
      end
      link2 = ''
      # only show Ivy link if there are Ivy holdings
      if display_ivy_link?(document)
        link2 = link_to_ilink_record(document, 'Request Item from Ivy&nbsp;&nbsp;&middot;&nbsp;&nbsp;', 'recall')
      end
      link3 = link_to_leo(document, 'Request LEO delivery (faculty/SCPS)', 'recall')
      return "<div class=\"recallAndLeo\">#{link1}#{link2}#{link3}#{sas_only_text(document)}</div>"
    end
  end
  
  def display_ivy_link?(document)
    return false unless document.availability.has_ivy_holdings?
    call_numbers = document.availability.holdings.collect { |holding| holding.call_number } || []
    call_numbers.uniq!
    return true if call_numbers.size > 1 # too ambiguous, we'll assume not
    deliverables = document.availability.holdings.select { |holding| holding.library.deliverable? } || []
    deliverables.each do |holding|
      availables = holding.copies.select { |copy| copy.available? } || []
      return false if availables.size > 0
    end
    return true
  end
  
  # show access restrictions for special collections items
  def access_restriction_text(document)
    out = ''
    if special_collections_lens? 
      unless document.marc_display.nil? or document.marc_display.access_restriction.empty?
    	  document.marc_display.access_restriction.each do |v|
    	    out += "<div>#{v}</div>"
    	  end
      end
    end
  end
  
  # show text when it's a sas item
  def sas_availability_text(document, library, sas_counter)
    if library.is_sas?
      if document.availability.has_non_sas_items? and sas_counter == 0 
        return "<div class=\"holding\">This item is also available to Semester at Sea participants.</div>"
      end
    end
  end
  
  def location_text(holding, copy)      
    return "Special Collections" if holding.library.is_special_collections? and !copy.special_collections_display?
    return "" if copy.current_location.suppressed?
    return copy.current_location.name
  end
  
  # display "Available" or "Unavilable"
  def availability_text(copy)
    copy.available? ? "Available" : "Unavailable"
  end
    
  # display call number for sas when
  def sas_call_number_text(holding, copy)
    return if !holding.library.is_sas?
    if !copy.pending?
      return "<span class=\"holdingCallNumber\">#{holding.call_number}</span>"
    end
  end
  
  # display map link
  def link_to_map(holding)
    unless holding.map.nil?
      link_to "[Map]", Map.find(holding.map.id).url, :target => "_blank"
    end 
  end
  
  # looks through the items of a special collections request to see if this location and
  # call number are included
  def item_included?(special_collections_request, location, call_number, barcode)
    special_collections_request.special_collections_request_items.each do |item|
      return true if location.include?(item.location) and item.call_number == call_number and item.barcode == barcode
    end
    false
  end
  
  # determines if the special collections request link should be displayed
  def display_special_collections_request_link?(availability)
    return false if !special_collections_lens? 
    return false if availability.special_collections_holdings.size == 0
    availability.special_collections_holdings.each do |holding|
      holding.copies.each do |copy|
        if copy.current_location.code !~ /SC-IVY/
          if copy.home_location.code =~ /SC-IVY/ and ["IN-PROCESS", "SC-IN-PROCESS"].include?(copy.current_location.code)
            # don't display link
          else
            return true
          end
        end
      end
    end
    return false
  end
  
  # determines offset for number of bookmarks
  def bookmark_offset
    page = params[:page].to_i - 1
    page = 0 if page < 1
    Blacklight.config[:bookmarks_per_page] * page
  end
  
  def folder_offset
    page = params[:page].to_i - 1
    page = 0 if page < 1
    per_page = params[:per_page].to_i rescue 0
    per_page = Blacklight.config[:bookmarks_per_page] if per_page = 0
    per_page * page
  end
  
  # determines if the given availability only has one holding
  def one_holding?(availability)
    return true if special_collections_lens? and availability.special_collections_holdings.size == 1
    availability.holdings.size == 1 ? true : false
  end
  
  # determines if the document is a journal or magazine
  def journal?(document)
    return document.has?(:format_facet, 'Journal/Magazine')
  end
  
  # determines which fielded search is in use
  def selected_fielded_search
    return h(params[:search_field]) unless params[:search_field].nil?
    return h(session[:search][:search_field]) unless session[:search][:search_field].nil?
    return ''
  end

  # remove a populated advanced search field
  def remove_advanced_search_field(key, source_params=params)
    p = source_params.dup.symbolize_keys!
    # need to dup the facet values too,
    # if the values aren't dup'd, then the values
    # from the session will get remove in the show view...
    p.delete :page
    p.delete :id
    p.delete :counter
    p.delete :commit
    p.delete(key)
    p.delete("#{key}_start")
    p.delete("#{key}_end")
    p[:action] = "index"
    p 
  end
  
  # use google link shortener
  def shortened_link(document)
    url = "https://www.googleapis.com/urlshortener/v1/url?key=AIzaSyDTcTFIqkvnwK0VJ9q64BZLs7AGx_0oJdI"
    @host = "search.lib.virginia.edu"
    data = {"longUrl" => catalog_path(document.id, :only_path => false, :host => @host)}.to_json
    response = Curl::Easy.http_post(url, data) do |curl|
      curl.headers['Accept'] = 'application/json'
      curl.headers['Content-Type'] = 'application/json'
      curl.headers['Api-Version'] = '2.2'
    end
    body = JSON.parse(response.body_str)
    body["id"]
  end

 # find advanced search
  def advanced_search_case?
    return true if params[:f_inclusive] && ! params[:f_inclusive].empty?
    return true if ! populated_advanced_search_fields.empty?
    return false
  end

  def refine_search_hash
    my_params = Hash.new
    populated_advanced_search_fields.each_pair do |key, value|
        my_params[key] =  h(value)     
     end

    # it should look like this:
    # params[:f][library_facet][]=Clemons
    if params[:f]
      params[:f].each_pair do |facet,values|
        values.each do |v|
          if (facet == "library_facet" || facet == "format_facet" )
            my_params[:f_inclusive] ||={}
    	      my_params[:f_inclusive][facet] ||={}
    	      my_params[:f_inclusive][facet][v] = "1"	 
    	    elsif (facet == "series_title_facet")
            facet = "title"
            my_params[facet] = h(values)            
  	      elsif (facet == "call_number_facet")
            #add call_number_facet case here
          else 
            facet = facet.gsub(/_\w\w\w\w\w$/,'')
            my_params[facet]= h(values)
          
         end
  	    end
  	  end
      
	  end

    # it should look like this:
	  # params[:f_inclusive][library_facet][Alderman]=1
	  # it comes through this way: {"library_facet"=>{"Alderman"=>"1"}}
    if params[:f_inclusive]
  	  params[:f_inclusive].each_pair do |facet,values|
  	    values.each do |v|
  	      my_params[:f_inclusive] ||={}
  	      my_params[:f_inclusive][facet] ||={}
  	      my_params[:f_inclusive][facet][v.first] = "1"
	      end
      end
    end
    my_params[:catalog_select] = 'articles' if params[:controller] == 'articles'
		my_params
  end

  # parse a glued-together range back into its parts
  def range_value(field)
    parts = params[field].split(" - ") rescue []
    first = parts[0] rescue ""
    last = parts[1] rescue ""
    return {:start => first, :end => last}
  end

  ############# end local methods
  
  ############# methods pending addition to Blacklight plugin -- revisit as needed
  
  # determines if the given document id is in the folder.  This can probably go away when the Folder
  # logic is added to the Blacklight plugin.
  def item_in_folder?(doc_id)
    session[:folder_document_ids] && session[:folder_document_ids].include?(doc_id) ? true : false
  end
  
  # handles refworks generation for multiple documents.  This can probably go away when the Folder
  # logic is added to the Blacklight plugin
  def render_refworks_texts(documents)
    val = ''
    documents.each do |doc|
      if doc.respond_to?(:to_marc)
        val += doc.export_as_refworks_marc_txt + "\n"
      end
    end
    val
  end
  
  # handles endnote generation for multiple documents.  This can probably go away when the Folder
  # logic is added to the Blacklight plugin
  def render_endnote_texts(documents)
    val = ''
    documents.each do |doc|
      if doc.respond_to?(:to_marc)
        val += doc.export_as_endnote + "\n"
      end
    end
    val
  end
  
 def render_csv(documents)
    csv_string = FasterCSV.generate do |csv|
      csv << ["ITEM_ID", "ITEM_FORMAT", "ITEM_TITLE", "ITEM_AUTHOR"]        
      documents.each do |doc|
        csv << [doc.value_for(:id), doc.value_for(:format_facet), doc.value_for(:title_facet), doc.value_for(:author_facet)]
      end
    end    
  end
  
  ############# end methods pending addition
  

  ############# methods overridden from Blacklight plugin -- revisit as needed
  
  # overriding so as to take into account facets from advanced search
  
  def facet_in_params?(field, value)
    return true if params[:f] and params[:f][field] and params[:f][field].include?(value)
    return true if params[:f_inclusive] and params[:f_inclusive][field] and params[:f_inclusive][field].include?(value)
    return false
  end

  # overriding from Blacklight plugin since default_search_field now needs (params) passed to it
  # Search History and Saved Searches display
   def link_to_previous_search(params)
     query_part = case
                    when params[:q].blank?
                      ""
                    when (params[:search_field] == Blacklight.default_search_field(params)[:key])
                      params[:q]
                    else
                      "#{Blacklight.label_for_search_field(params[:search_field])}:(#{params[:q]})"
                  end      

     facet_part = 
     if params[:f]
       tmp = 
       params[:f].collect do |pair|
         "#{Blacklight.config[:facet][:labels][pair.first]}:#{pair.last}"
       end.join(" AND ")
       "{#{tmp}}"
     else
       ""
     end
     link_to("#{query_part} #{facet_part}", catalog_index_path(params))
   end

  # overriding from the Blacklight plugin.  We want to use regular expression mathches to determine
  # which partial, as opposed to a value indexed in solr.
  def document_partial_name(document)
    (params[:portal] == 'video' && params[:action] == 'index' ? "lib_video" : document.doc_type) rescue document.doc_type
  end

  # overriding from Blacklight plugin to account for bookmarks view
  def render_document_partial(doc, action_name, counter, offset=0, bookmarks_view=false)
    format = document_partial_name(doc)
    begin
      render :partial=>"catalog/_#{action_name}_partials/#{format}", :locals=>{:document=>doc, :counter=>counter, :offset=>offset, :bookmarks_view=>bookmarks_view}
    rescue ActionView::MissingTemplate
      render :partial=>"catalog/_#{action_name}_partials/default", :locals=>{:document=>doc, :counter=>counter, :offset=>offset, :bookmarks_view=>bookmarks_view}
    end
  end

  # overriding from Blacklight plugin to keep track of if we are in Bookmarks view or not.
  def link_to_document(doc, opts={:label=>Blacklight.config[:index][:show_link].to_sym, :counter => nil, :bookmarks_view => false})
    label = case opts[:label]
    when Symbol
      doc.get(opts[:label])
    when String
      opts[:label]
    else
      raise 'Invalid label argument'
    end
    link_to_with_data(label, catalog_path(doc[:id]), {:method => :put, :data => {:counter => opts[:counter], :bookmarks_view => opts[:bookmarks_view]}})
  end

  # overriding from the Blacklight plugin so that we can switch facets depending on the portal
  def facet_field_labels
    if params[:portal] == 'music'
      Blacklight.config[:facet_music][:labels]
    elsif params[:portal] == 'video'
      Blacklight.config[:facet_video][:labels]
    elsif params[:controller] == 'articles'
      Blacklight.config[:facet_articles][:labels]
    else
      Blacklight.config[:facet][:labels]
    end
  end
  
  
  #
  # Displays the "showing X through Y of N" message. Not sure
  # why that's called "page_entries_info". Not entirely sure
  # what collection argument is supposed to duck-type too, but
  # an RSolr::Ext::Response works.  Perhaps it duck-types to something
  # from will_paginate?
  def virgo_page_entries_info(collection, options = {})
    total_hits = @response.total
    total_num = format_num(total_hits)
    combined_sort = (collection.size > 0 and params[:catalog_select] == "all") ? "sorted by relevancy" : ""
    entry_name = options[:entry_name] ||
     (collection.empty?? 'entry' : collection.first.class.name.underscore.sub('_', ' '))
  
    case collection.size
      when 0; "<span class='no-items'>No #{entry_name.pluralize} found. Need help? <a class=\"no-items-ask\" href=\"http://www2.lib.virginia.edu/askalibrarian\">Ask a librarian</a>.</span>"
      when 1; "<strong>1</strong> result #{combined_sort}"
      else;   "<strong>#{total_num}</strong> results #{combined_sort}"
    end
  end

  # overriding from the Blacklight plugin so that we can switch facets depending on the portal
  def facet_field_names
    if params[:portal] == 'music' && home_page?
      Blacklight.config[:facet_music][:home_field_names]
    elsif params[:portal] == 'music' 
      Blacklight.config[:facet_music][:field_names]
    elsif params[:portal] == 'video'
      Blacklight.config[:facet_video][:field_names]        
    elsif params[:controller] == 'advanced'
      Blacklight.config[:facet][:advanced_field_names]
    elsif params[:controller] == 'articles'
      Blacklight.config[:facet_articles][:field_names]
    elsif home_page?
      Blacklight.config[:facet][:home_field_names]
    else
      Blacklight.config[:facet][:field_names]
    end
  end

  # overriding from Blacklight plugin to add logic for cleaning up the portal references
  def add_facet_params(field, value)
    p = params.dup
    p[:f]||={}
    p[:f][field] ||= []
    p[:f][field].push(value)
    scrunge_portal(p) 
    scrunge_page(p)
    p
   
  end


  # overriding from the blacklight plugin to shift out relevancy if there is no search
  def sort_fields
    sort_fields = []
    Blacklight.config[:sort_fields_order].each { |key|
      if params[:controller] == 'articles'
        my_sort_fields = Blacklight.config[:articles_sort_fields]
      else
        my_sort_fields = Blacklight.config[:sort_fields]
      end
      next if !my_sort_fields[key]
      sort_fields << [my_sort_fields[key][0], key]
    }
    # remove 'relevancy' if there is no search
    sort_fields.shift if params[:q].blank? and params[:controller] != 'advanced' and params[:search_field] != 'advanced' and params[:catalog_select] != 'articles'
    sort_fields
  end

  # overriding from the Blacklight plugin, since plugin does h(name) -- that h messes up display of some titles
  def link_to_with_data(*args, &block)
    if block_given?
      options      = args.first || {}
      html_options = args.second
      concat(link_to(capture(&block), options, html_options))
    else
      name         = args.first
      options      = args.second || {}
      html_options = args.third

      url = url_for(options)

      if html_options
        html_options = html_options.stringify_keys
        href = html_options['href']
        convert_options_to_javascript_with_data!(html_options, url)
        tag_options = tag_options(html_options)
      else
        tag_options = nil
      end

      href_attr = "href=\"#{url}\"" unless href
      "<a #{href_attr}#{tag_options}>#{name || h(url)}</a>"
    end
  end

  # overriding from plugin to account for when the search session doesn't exist;
  # also overriding to clean up portal references
  def link_back_to_catalog(opts={:label=>'Back to Search'})
    query_params = session[:search].dup || {} rescue {}
    query_params.delete :counter
    query_params.delete :total
    scrunge_portal(query_params)
    link_url = catalog_index_path(query_params)
    link_to opts[:label], link_url
  end
  
  # overriding from the Blacklight plugin. this is hardcoded in the plugin to be 'Blacklight', and
  # we want it to say 'Virgo'
  def application_name
    'VIRGO'
  end

  # overriding from Blacklight plugin to pass along params
  def search_fields
    Blacklight.search_field_options_for_select(params)
  end
  
  

  
  
  ############# end methods overridden
  
  ############# methods for Video Search view
  
  def video_call_number(document, sep=";", default='n/a')
    call = call_number(document, sep, default)
    # Stripping out VIDEO, pt. nn, and parenthetical volume info from call number
    return call.gsub(/video\./i, '').gsub(/pt\.[ 0-9,]+/i, '').gsub(/\([a-z0-9 ]+\)/i, '')
  end
  
  def video_format(document)
    vals = document.fetch :format_facet
    vals.delete_if {|format| format.match(/video/i) }    
    format = ''

    vals.each do |val|
      class_name = val.downcase.gsub(/\//i, '-')
      val_name = val.gsub(/([a-z])\/([a-z])/i, '\1 / \2')
      format = format + '<span class="format_value ' + class_name + '">' + val_name + '</span>'
    end

    return format
  end
  
  # gets the location for a document, truncated for video view
  def video_location_listing(document)
    loc = location_listing(document)
    loc = loc.first if loc.kind_of?(Array)
    
    location = case loc
      when /Clemons Robertson.+/i then "Robertson"
      when /Law.+/i then "Law"
      when /Semester at Sea.+/i then "Semester at Sea"
      when /Item is on hold--Ask at Robertson.+/i then "On Hold - Robertson"
      when /Special Collections.+/i then "Special Collections"
      when /Fine Arts.+/i then "Fine Arts"
      else loc
    end
    
    return location
  end
  
  def video_title(document)
    return full_title(document).gsub(/\[video[ ,-]*recording\]/i, '')
  end
  
  ############# end methods for Video Search view
  ############# methods for articles
  
  # picks appropriate lael for the search results
  def search_result_label
    if params[:controller] == 'articles'
      return 'Article'
    elsif params[:catalog_select] == 'all'
      return 'Catalog + Article'
    elsif params[:portal] == 'music'
      return 'Music'
    elsif params[:portal] == 'video'
      return 'Video'
    else
      return 'Catalog'
    end
  end


  # presents apprpriate links for changing search scope
  def switch_search_scope_links
    base_params = {:q => params[:q], :search_field => params[:search_field]}.merge(populated_advanced_search_fields)
    all_label = 'Catalog + Article'
    all_link = catalog_index_path(base_params.merge(:catalog_select => 'all', :portal => 'all'))
    catalog_label = 'Catalog'
    catalog_link = catalog_index_path(base_params.merge(:portal => 'all'))
    articles_label = 'Article'
    articles_link = catalog_index_path(base_params.merge(:catalog_select => 'articles',:portal => 'all'))
    music_label = "Music"
    music_link = catalog_index_path(base_params.merge(:portal => 'music'))
    video_label = "Video"
    video_link = catalog_index_path(base_params.merge(:portal => 'video'))
    
    
    if search_result_label == 'Article'
      parts = [all_label, all_link, catalog_label, catalog_link, music_label, music_link, video_label, video_link]
    elsif search_result_label == 'Catalog + Article'
      parts = [catalog_label, catalog_link, articles_label, articles_link, music_label, music_link, video_label, video_link]
    elsif search_result_label == 'Music'
      parts = [all_label, all_link, catalog_label, catalog_link, articles_label, articles_link, video_label, video_link]
    elsif search_result_label == 'Video'
      parts = [all_label, all_link, catalog_label, catalog_link, articles_label, articles_link, music_label, music_link]
    else
      parts = [all_label, all_link, articles_label, articles_link, music_label, music_link, video_label, video_link]
    end
    "<span class=\"search-toggle-label\">Switch to:</span> #{link_to parts[0] + ' Results', parts[1], :class => parts[0].downcase.gsub(/ /,'').gsub(/\+/,'-') + '-search'} <span class=\"divider\">|</span>#{link_to parts[2] + ' Results', parts[3], :class => parts[2].downcase + '-search'} <span class=\"divider\">|</span> #{link_to parts[4] + ' Results', parts[5], :class => parts[4].downcase + '-search'} <span class=\"divider\">|</span> #{link_to parts[6] + ' Results', parts[7], :class => parts[6].downcase + '-search'}"
  end
  
  # presents apprpriate links for changing search scope
  def search_elsewhere_links
    base_params = {:q => params[:q], :search_field => params[:search_field]}.merge(populated_advanced_search_fields)
    all_label = 'everything'
    all_link = catalog_index_path(base_params.merge(:catalog_select => 'all'))
    catalog_label = 'catalog'
    catalog_link = catalog_index_path(base_params)
    articles_label = 'articles'
    articles_link = catalog_index_path(base_params.merge(:catalog_select => 'articles'))
    if search_result_label == 'Article'
      parts = [all_label, all_link, catalog_label, catalog_link]
    elsif search_result_label == 'Catalog + Article'
      parts = [catalog_label, catalog_link, articles_label, articles_link]
    else
      parts = [all_label, all_link, articles_label, articles_link]
    end
    "<li>#{link_to( 'Search ' + parts[0], parts[1] )}</li><li>#{link_to( 'Search ' + parts[2], parts[3] )}</li><li>#{link_to "Start&nbsp;over", catalog_index_path(:portal => session[:search][:portal]||"all")}</li>"
  end
  
  # catalog items and articles paginate differently
  def pagination_links
  	if params[:controller] == 'articles'
  		will_paginate @response, :separator=>''
  	else
  	  will_paginate @response.docs, :separator=>''
  	end
  end

  # used on combined view to view more results
  def see_all_results(style)
    base_params = {:q => params[:q], :search_field => params[:search_field]}.merge(populated_advanced_search_fields)
    if params[:controller] == 'articles'
      link = articles_path(base_params.merge(:catalog_select => 'articles'))
      label = 'article'
    else
      link = catalog_index_path(base_params)
      label = 'catalog'
    end
    link_to "See all #{label} results &rarr;", link, :class => style
  end

end