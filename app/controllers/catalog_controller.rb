# Catalog controller base class is included in the Blacklight plugin.  Overriding all sorts of methods for
# custom behavior.  Once folder logic is included in the plugin, we can remove several methods.
require 'lib/uva/fedora'
require 'lib/firehose/holds'
require 'lib/firehose/availability'
require 'lib/uva/advanced_search/controller'
require 'lib/uva/advanced_search/advanced_search_fields'
require 'lib/uva/articles_helper'
require 'lib/uva/solr_helper_override'
class CatalogController < ApplicationController
  include UVA::Fedora
  include Blacklight::Catalog
  include Firehose::Holds
  include UVA::AdvancedSearch::Controller
  include UVA::AdvancedSearch::AdvancedSearchFields
  include UVA::ArticlesHelper
  include UVA::SolrHelperOverride
  include BlacklightAdvancedSearch::ParseBasicQ
  
  # the featured_documents are used when there are no queries or filters applied
  before_filter :notices_update, :only=>[:index, :show]
  before_filter :adjust_for_advanced_search, :only=>:index
  before_filter :adjust_for_portal, :only=>:index
  before_filter :setup_call_number_search, :only=>:index
  before_filter :adjust_for_special_collections_search, :only=>:index
  before_filter :adjust_for_full_view, :only=>[:index, :show]
  before_filter :resolve_sort, :only=>:index
  before_filter :add_lean_query_type, :only=>[:image_load, :image, :brief_availability]
  before_filter :recaptcha_check, :only=>:send_email_record
  before_filter :articles, :only=>[:email, :send_email_record, :citation]
  before_filter :set_solr_document, :only=>[:availability, :brief_availability, :firehose, :image_load, :image, :page_turner, :fedora_metadata]
  before_filter :set_document_availability, :only=>[:availability, :brief_availability]
  
  # when a request for /catalog/HIDDEN_SOLR_ID is made, this method is executed...
  rescue_from HiddenSolrID, :with => lambda {
    flash[:notice] = "Sorry, you seem to have encountered an error."
    redirect_to catalog_index_path and return
  }

  # when a path is requested that should result in a redirect, this method is executed  
  rescue_from UVA::RedirectNeeded do |redirect| 
    redirect_to redirect.message and return
  end
  
  # too many of these are showing up in ExceptionNotification emails, ususally generated
  # by a bot crawling the site.  This is here to keep the email volume lower.
  rescue_from ActionController::InvalidAuthenticityToken, :with => lambda {
    redirect_to catalog_index_path and return
  }
  
  # When RSolr::RequestError is raised, this block is executed.
  # The index action will more than likely throw this one.
  # Example, when the standard query parser is used, and a user submits a "bad" query.
  rescue_from RSolr::Error::InvalidRubyResponse do |error|
    # when solr (RSolr) throws an error, this method is executed.
    flash[:notice] = "Sorry, I don't understand your search."
    notify_about_exception(error)
    redirect_to catalog_index_path and return
  end
  
  # some googlebot keeps doing an OPTIONS request on status, and status doesn't allow that.
  # trying to reduce exception emails
  rescue_from ActionController::MethodNotAllowed, :with => lambda {
    redirect_to catalog_index_path and return
  }
    
  configure_blacklight do |config|
    config.default_solr_params = {
      :qt => "search",
      :rows => 20
    }
    config.default_qt = "search"
    # solr field values given special treatment in the index (search results) view
    config.index.show_link = "title_display"
    config.index.record_display_type = "format"
    
    # solr field values given special treatment in the show (single result) view
    config.show.html_title = "title_display"
    config.show.heading = "title_display"
    config.show.display_type = "format"
    
    # facets
    config.add_facet_field 'library_facet', :label => 'Library' 
    config.add_facet_field 'format_facet', :label => 'Format'
    config.add_facet_field 'published_date_facet', :label => 'Publication Era'
    config.add_facet_field 'author_facet', :label => 'Author'
    config.add_facet_field 'subject_facet', :label => 'Subject'
    config.add_facet_field 'language_facet', :label => 'Language'
    config.add_facet_field 'call_number_facet', :label => 'Call Number'
    config.add_facet_field 'region_facet', :label => 'Geographic Location'
    config.add_facet_field 'digital_collection_facet', :label => 'Digital Collection'
    config.add_facet_field 'source_facet', :label => 'Source'
    config.add_facet_field 'series_title_facet', :label => 'Series'
    config.add_facet_field 'call_number_broad_facet', :label => 'Call Number'
    
    # index fields
    config.add_index_field 'title_display', :label => 'Title:' 
    config.add_index_field 'author_display', :label => 'Author:' 
    config.add_index_field 'format_facet', :label => 'Format:' 
    config.add_index_field 'language_facet', :label => 'Language:' 
    config.add_index_field 'published_date_display', :label => 'Published:' 
    config.add_index_field 'location_facet', :label => 'Location:' 
  
    # show fields
    config.add_show_field 'year_facet', :label => 'Date:'
    config.add_show_field 'author_display', :label => 'Creator:'
    config.add_show_field 'digital_collection_facet', :label => 'Collection:'
    config.add_show_field 'media_resource_id_display', :label => 'Type:'
    config.add_show_field 'title_display', :label => 'Title:' 
    config.add_show_field 'subtitle_display', :label => 'Subtitle:' 
    config.add_show_field 'format_facet', :label => 'Format:'
    config.add_show_field 'language_facet', :label => 'Language:'
    config.add_show_field 'note_display', :label => 'Note:'
    config.add_show_field 'published_date_display', :label => 'Published:'
    config.add_show_field 'isbn_display', :label => 'ISBN'

    # search fields
    config.add_search_field('author') do |field|
      field.solr_local_parameters = {
       :qf => '$qf_author',
       :pf => '$pf_author'
      }
    end
    config.add_search_field('title') do |field|
      field.solr_local_parameters = {
       :qf => '$qf_title',
       :pf => '$pf_title'
      }
    end
    config.add_search_field('journal') do |field|
      field.label = 'Journal Title'
      field.solr_local_parameters = {
       :qf => '$qf_journal_title',
       :pf => '$pf_journal_title'
      }
    end
    config.add_search_field('subject') do |field|
      field.solr_local_parameters = {
       :qf => '$qf_subject',
       :pf => '$pf_subject'
      }
    end
    config.add_search_field 'keyword' do |field|
      field.label = 'Keywords'
      field.solr_local_parameters = {
        :qf => '$qf_keyword',
        :pf => '$pf_keyword'
       }
    end
    config.add_search_field('call_number') do |field|
      field.label = 'Call Number'
      field.solr_local_parameters = {
       :qf => '$qf_call_number',
       :pf => '$pf_call_number'
      }
    end
    config.add_search_field('published') do |field|
      field.label = 'Publisher/Place of Publication'
      field.solr_local_parameters = {
       :qf => '$qf_published',
       :pf => '$pf_published'
      }
    end
    config.add_search_field('publication_date') do |field|
      field.label = 'Year Published'
      field.range = 'true'
      field.solr_field = 'year_multisort_i'
    end
    config.add_search_field('issn') do |field|
      field.include_in_advanced_search = false
      field.label = 'ISSN'
      field.solr_local_parameters = {
        :qf => '$qf_issn',
        :pf => '$pf_issn'
      }
    end
    config.add_search_field('isbn') do |field|
      field.include_in_advanced_search = false
      field.label = 'ISBN'
      field.solr_local_parameters = {
        :qf => '$qf_isbn',
        :pf => '$pf_isbn'
      }
    end
    
    # sort fields
    config.add_sort_field 'score desc, year_multisort_i desc', :label => 'Relevancy', :sort_key => 'relevancy'
    config.add_sort_field 'date_received_facet desc', :label => 'Date Received', :sort_key => 'received'
    config.add_sort_field 'year_multisort_i desc', :label => 'Date Published - newest first', :sort_key => 'published'
    config.add_sort_field 'year_multisort_i asc', :label => 'Date Published - oldest first', :sort_key => 'published_a'
    config.add_sort_field 'title_sort_facet asc, author_sort_facet asc', :label => 'Title', :sort_key => 'title'
    config.add_sort_field 'author_sort_facet asc, title_sort_facet asc', :label => 'Author', :sort_key => 'author'
    
    config.spell_max = 5

    # advanced search facets
    config.advanced_search = {
      :form_solr_parameters => {
        'facet.field' => ['library_facet', 'format_facet', 'call_number_broad_facet', 'digital_collection_facet'],
        'facet.limit' => -1, # return all facet values
        'facet.sort' => 'index', # sort by byte order of values
      },
      :url_key => 'advanced',
      :qt => 'search'
    }
  end
  
  # get search results from the solr index
  # overriding from plugin to add cleanup_call_number_search and json response
  def index
    (@response, @document_list) = get_search_results(params)
    cleanup_call_number_search
    respond_to do |format|
      format.html { render :layout => index_layout }
      format.json { render :json => @response.to_json}
      format.rss  { render :layout => false }
    end
  end
  
  # displays values and pagination links for a single facet field
  # overriding from plugin to add json response
  def facet
    @pagination = get_facet_pagination(params[:id], params)
    respond_to do |format|
       format.html {render :layout => "popup"}
       format.json {render :json => @pagination.to_json}
     end
  end

  # get item availability status
  def availability
    respond_to do |format|
      format.html
      format.json {render :layout=>false}
    end
  end
  
  # just get the availability info independently of the docume
  def brief_availability
    respond_to do |format|
      format.html {render :layout=>false}
      format.json {render :layout=>false}
    end
  end
  
  # display raw results from firehose
  def firehose
    a = Firehose::Availability.find(@document)
    respond_to do |format|
      format.xml  {render :xml => a.to_xml}
    end
  end
  
  # ajax loader page for image
  # /catalog/u1/image_load
  def image_load
  end
  
  # image for a single record:
  #   /catalog/u1/image.jpg
  # this is here for historical purposes, in case someone is externally referencing this url
  def image
    respond_to do |format|
      format.jpg {
        redirect_to @document.image_path and return
      }
    end
  end
  
  # action for sending email.  This is meant to post from the form and to do processing
  # overriding from plugin for sending full record
  def send_email_record
    @response, @documents = get_solr_response_for_field_values("id",params[:id])
    if params[:to]
      from = request.host # host w/o port for From address (from address cannot have port#)
      host = request.host
      host << ":#{request.port}" unless request.port.nil? # host w/ port for linking
      case params[:style]
        when 'sms'
          if !params[:carrier].blank?
            if params[:to].length != 10
              flash[:error] = "You must enter a valid 10 digit phone number"
            else
              email = RecordMailer.sms_record(@documents, @articles, params[:to], params[:carrier], from, host)
            end
          else
            flash[:error] = "You must select a carrier"
          end
        when 'email'
          if params[:to].match(/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
            email = RecordMailer.email_record(@documents, @articles, params[:to], params[:message], params[:full_record], from, host)
          else
            flash[:error] = "You must enter a valid email address"
        end
        when 'reserves_email'
          if params[:to].match(/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
            email = RecordMailer.email_reserves(@documents, params[:to], params[:to_instructor],params[:instructor_name],params[:requestor_name],params[:requestor_uvaid], params[:course_id],params[:semester],params[:location],params[:loan],params[:full_record], from, host)          
          else
            flash[:error] = "You must enter a valid email address"
          end
      end
      email.deliver unless flash[:error]
      if @articles.size == 0 && @documents.size == 1 
        if ( params[:style] == 'reserves_email' && flash[:error])
          redirect_to reserves_email_path and return
        else 
          flash[:notice] = "Everything went ok"
          redirect_to catalog_path(@documents.first.id) and return
        end          
      else
        redirect_to folder_index_path and return
      end
    else
      flash[:error] = "You must enter a recipient in order to send this message"
    end
  end

  
  # Displays the page turner UI, for viewing page images of DL text resources
  def page_turner
    # The id passed is the pid of the Fedora aggregation object (the book,
    # manuscript, etc. for which we want to display page images)
    @repository = @document.value_for(:repository_address_display) || FEDORA_REST_URL 

    # get id of image to use for initial_page_pid
    @exemplar_id = get_exemplar(@document.fedora_url, params[:id]) 

    # get list of pids for images belonging to this item
    response = sparql_query_others(@document.fedora_url, params[:id], "hasCatalogRecordIn", :supp => "dc:title", :desc => "dc:description")
    
    all = get_pids_from_sparql(response)
    single =  [{ :pid => @exemplar_id, 
                :title => @document.value_for(:main_title_display), 
                :description => @document.value_for(:note_display) }]
    
    all.empty? ? @images = single : @images = all
    
    render :layout => false
  end
  
  def fedora_metadata
    @repository = @document.value_for(:repository_address_display) || FEDORA_REST_URL 
    result = Net::HTTP.get_response(URI.parse(@repository + "/get/" + params[:pid] + "/djatoka:jp2SDef/getMetadata"))
    respond_to do |format|
      format.json { render :json => result.body }
    end
  end
  
  
  protected
  
  # fetches the solr document based on id in params
  def set_solr_document
    @response, @document = get_solr_response_for_doc_id(params[:id], params)
  end
  
  # sets the availability for the document
  def set_document_availability
    @document.availability = Firehose::Availability.find(@document)
  end

  # used for images, since we don't need much data for them
  def add_lean_query_type
    params[:qt] = :document_lean
  end
  
  # this is so gross - put quotes around the sort
  def setup_call_number_search
    if params[:search_field] == 'call_number' && !params[:q].nil?
      q = params[:q]
      @hold_q = params[:q].dup
      q.gsub!('"', '')
      params[:q] = '"' + q + '"'
    end
  end
    
  # this is gross too - put params[:q] back to original
  def cleanup_call_number_search
    if params[:search_field] == 'call_number'
      params[:q] = @hold_q
    end
  end  
  
  # controls if we are in the special collections lens or not
  def adjust_for_special_collections_search
    if params[:special_collections]
      if params[:special_collections] == "false"
        session[:special_collections] = nil
      else
        session[:special_collections] = true
      end
    end
    if session[:special_collections]
      params[:special_collections] = "true" 
      if params[:catalog_select].blank?
        params[:catalog_select] = "catalog"
        redirect_to catalog_index_path(params) and return
      end
    end
  end
  
  # controls whether users sees show/hide metadata feature
  def adjust_for_full_view
    if params[:full_view]
      if params[:full_view] == "false"
        session[:full_view] = nil
      else
        session[:full_view] = true
      end
    end
  end
  
  # redirecting to appropriate portal
  def adjust_for_portal
    if params[:catalog_select] == "articles"
      redirect_to articles_path(params_to_keep.merge(:catalog_select => "articles")) and return
    end
    return if params[:portal].blank?
    if params[:portal] == 'all' and params[:controller] != 'catalog'
      redirect_to catalog_index_path(params_to_keep)
    end
    if params[:portal] == 'music' and params[:controller] != 'music'
      redirect_to music_index_path(params_to_keep)
    end
    if params[:portal] == 'video' and params[:controller] != 'video'
      redirect_to video_index_path(params_to_keep)
    end
  end
      
  # do recaptcha check before allowing email to be sent out
  def recaptcha_check
    unless verify_recaptcha(:model => @post)
      flash[:error] = "Text validation did not match."
    end
  end
  
  # provides cutom error message for when a bad id is selected
  def invalid_solr_id_error
    flash[:notice] = "Sorry, you seem to have encountered an error."
    redirect_to catalog_index_path and return
  end
   
  def adjust_for_advanced_search
    my_params = params.dup
    if (params[:f_inclusive] or params[:search_field] == 'advanced') and params[:q]
      if params[:search_field].blank?
        field = "keyword"
      else
        field = my_params[:search_field].to_sym
      end
      my_params.delete(field)
      my_params[field] = params[:q]
      my_params[:search_field] = 'advanced'
      my_params.delete(:q)
      redirect_to catalog_index_path(my_params) and return
    end
  end
  
  def extra_head_content
    return ""
  end
  
  def params_to_keep
    my_params = {}
    unless params[:q].blank?
      my_params[:q] = params[:q]
    else
      my_params = populated_advanced_search_fields.merge(:search_field => params[:search_field])
    end
    my_params[:f] = params[:f]
    my_params[:format] = params[:format]
    my_params[:sort_key] = params[:sort_key]
    my_params
  end
  
  def index_layout
    if searchless?
      if special_collections_lens?
        layout = "application"
      elsif default_portal? and facetless?
        layout = "home"
      else
        layout = "application"
      end
    elsif params[:catalog_select] == "all"
      layout = "combined"
    else
      layout = "application"
    end
    return layout
  end
  
  def articles
    @articles = get_articles_by_ids(params[:article_id])
  end
 
end