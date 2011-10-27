# Catalog controller base class is included in the Blacklight plugin.  Overriding all sorts of methods for
# custom behavior.  Once folder logic is included in the plugin, we can remove several methods.
class CatalogController < ApplicationController
  
  include UVA::Document
  include UVA::Fedora
  include Account::Holds
  include BlacklightAdvancedSearch::AdvancedSearchFields
  include UVA::ArticlesHelper
  
  # the featured_documents are used when there are no queries or filters applied
  before_filter :adjust_for_advanced_search, :only=>:index
  before_filter :adjust_for_portal, :only=>:index
  before_filter :setup_call_number_search, :only=>:index
  before_filter :adjust_for_special_collections_search, :only=>:index
  before_filter :adjust_for_full_view, :only=>[:index, :show]
  before_filter :resolve_sort, :only=>:index
  before_filter :load_featured_documents, :only=>:index  
  before_filter :add_lean_query_type, :only=>[:image_load, :image]
  before_filter :adjust_for_bookmarks_view, :only=>:update
  before_filter :recaptcha_check, :only=>:send_email_record
  before_filter :filters, :only =>:show
  before_filter :articles, :only=>[:email, :send_email_record]
  
  # when a request for /catalog/HIDDEN_SOLR_ID is made, this method is executed...
  rescue_from HiddenSolrID, :with => lambda {
    flash[:notice] = "Sorry, you seem to have encountered an error."
    redirect_to catalog_index_path
  }

  # when a path is requested that should result in a redirect, this method is executed  
  rescue_from RedirectNeeded do |redirect| 
    redirect_to redirect.message
  end
  
  # too many of these are showing up in ExceptionNotification emails, ususally generated
  # by a bot crawling the site.  This is here to keep the email volume lower.
  rescue_from ActionController::InvalidAuthenticityToken, :with => lambda {
    redirect_to catalog_index_path
  }
  
  # When RSolr::RequestError is raised, this block is executed.
  # The index action will more than likely throw this one.
  # Example, when the standard query parser is used, and a user submits a "bad" query.
  rescue_from RSolr::RequestError do |error|
    # when solr (RSolr) throws an error (RSolr::RequestError), this method is executed.
    flash[:notice] = "Sorry, I don't understand your search."
    notify_about_exception(error)
    redirect_to catalog_index_path
  end
  
  # some googlebot keeps doing an OPTIONS request on status, and status doesn't allow that.
  # trying to reduce exception emails
  rescue_from ActionController::MethodNotAllowed, :with => lambda {
    redirect_to catalog_index_path
  }
  
  # get search results from the solr index
  # overriding from plugin to add cleanup_call_number_search and json response
  def index
    if params[:catalog_select] == "articles"
      # ignore advanced search stuff if there is a "q"
      unless params[:q].blank?
        my_params = {:q => params[:q], :catalog_select => "articles"}
      else
        my_params = populated_advanced_search_fields.merge(:catalog_select => "articles", :search_field => params[:search_field])
      end
      redirect_to articles_path(my_params) and return
    end
    (@response, @document_list) = get_search_results(params)
    cleanup_call_number_search
    @filters = params[:f] || []
    respond_to do |format|
      format.html { 
        render :layout => index_layout 
      }
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
  def status
    # go ahead and refetch the document.  we will need it for making links to virgo and for
    # semester at sea availability text
    @response, @document = get_solr_response_for_doc_id(params[:id], params)
    @document.availability = Account::Availability.find(@document)
    respond_to do |format|
      format.html
      format.json {render :layout=>false}
    end
  end
  
  # display raw results from firehose
  def firehose
    @response, @document = get_solr_response_for_doc_id(params[:id], params)
    a = Account::Availability.find(@document)
    respond_to do |format|
      format.xml  {render :xml => a.to_xml}
    end
  end
  
  # ajax loader page for image
  # /catalog/u1/image_load
  def image_load
    @response, @document = get_solr_response_for_doc_id(params[:id], params)
  end
  
  # image for a single record:
  #   /catalog/u1/image.jpg
  # this is here for historical purposes, in case someone is externally referencing this url
  def image
    @response, @document = get_solr_response_for_doc_id(params[:id], params)
    respond_to do |format|
      format.jpg {
        @document.extend UVA::Document
        redirect_to @document.image_path
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
              email = RecordMailer.create_sms_record(@documents, @articles, {:to => params[:to], :carrier => params[:carrier]}, from, host)
            end
          else
            flash[:error] = "You must select a carrier"
          end
        when 'email'
          if params[:to].match(/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
            email = RecordMailer.create_email_record(@documents, @articles, {:to => params[:to], :message => params[:message], :full_record => params[:full_record]}, from, host)
          else
            flash[:error] = "You must enter a valid email address"
          end
      end
      RecordMailer.deliver(email) unless flash[:error]
      if @articles.size == 0 && @documents.size == 1
        redirect_to catalog_path(@documents.first.id)
      else
        redirect_to folder_index_path
      end
    else
      flash[:error] = "You must enter a recipient in order to send this message"
    end
  end
  
  # Displays the page turner UI, for viewing page images of DL text resources
  def page_turner
    # The id passed is the pid of the Fedora aggregation object (the book,
    # manuscript, etc. for which we want to display page images)
    # @pid = document[:id]
    @response, @document = get_solr_response_for_doc_id(params[:id])	
    @repository = @document.value_for(:repository_address_display) || FEDORA_REST_URL 
    @pid = params[:id]

    # get id of image to use for initial_page_pid
    @exemplar_id = get_exemplar(@document.fedora_url, @pid) 

    # get list of pids for images belonging to this item
    response=sparql_query_others(@document.fedora_url, @pid, "hasCatalogRecordIn", :supp => "dc:title")
    media_ids = Array.new
    media_ids = get_pids_from_sparql(response)
    if media_ids == []
      media_ids << @exemplar_id 
    end
    
    @initial_page_pid=String.new
    if params[:focus] 
      @initial_page_pid=params[:focus] 
    else 
      @initial_page_pid=@exemplar_id 
    end

    #params[:pages]=@media_ids
    @image_pids=[]
    @image_titles=[]
    media_ids.each { |m| @image_pids << m[:pid]; @image_titles << m[:title]; }
    @pid_string = String.new
    @caption_string= String.new
    @image_pids.each { |p| @pid_string << "#{p};" }
    @image_titles.each { |p| @caption_string << "#{p};" }

    render :layout => false
  end
  
  def fedora_metadata
    @response, @document = get_solr_response_for_doc_id(params[:id])
    @repository = @document.value_for(:repository_address_display) || FEDORA_REST_URL 
    result = Net::HTTP.get_response(URI.parse(@repository + "/get/" + params[:pid] + "/djatoka:jp2SDef/getMetadata"))
    respond_to do |format|
      format.json { render :json => result.body }
    end
  end
  
  
  protected
  
  # gets cover images for featured documents
  def load_featured_documents
    if (!params[:f] || params[:f].size == 0 || (params[:portal] == 'video' && params[:f].size <=1 && params[:f]['format_facet'].size <= 1)) && params[:q].blank? && params[:search_field] != 'advanced'
      phrase_filters = {}
      if params[:portal] == 'music'
        phrase_filters[:library_facet] = ["Music"]
        phrase_filters[:format_facet] = "\"Musical_Recording\"^2.0 \"Book\""
      elsif params[:portal] == 'video'
        phrase_filters[:format_facet] = ["Video"]
      else
        phrase_filters[:format_facet] = ["Book"]
      end
      opts={
        :page=>1,
        :per_page=>200, # load plenty to match up with the ids_for_docs_with_cached_covers output
        :solr=>{
          :fl=>%W(id format_facet library_facet),
          :sort=>[{:date_received_facet=>:descending}]
        },
        :phrase_filters=>phrase_filters,
        :qt => 'search'
      }
      featured_response, document_list = get_search_results(opts)
      @featured_documents = featured_response.docs.select do |doc|
        doc.extend UVA::Document
        doc.has_image?
      end
        
      @featured_documents = @featured_documents.sort_by {rand}
    end
  end

  # fetch all doc ids that have pre-cached cover images
  def ids_for_docs_with_cached_covers(solr_docs, max_file_size=1500)
    # get the solr ids so we can send them to mysql
    solr_doc_ids = solr_docs.docs.collect { |doc| doc.get(:id) }
    # limit the query to just our ids and make an upper-bound on the image size
    docs = DocumentImageRequest.find(:all, :select => 'document_id', :conditions => {:document_id => solr_doc_ids, :image_size => 0..max_file_size.kilobytes })
    doc_ids = []
    docs.each do |doc|
      doc_ids << doc.document_id
    end
    doc_ids
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
      my_params = add_facet_param('library_facet', 'Special Collections') 
      params[:f] = my_params[:f]
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
  
  # storing which portal we are in
  def adjust_for_portal
    unless params[:portal].blank?
      session[:search][:portal] = params[:portal]
    end
    if params[:portal] == 'video'
      my_params = add_facet_param('format_facet', 'Video') 
      params[:f] = my_params[:f]
    end
  end
    
  # we need to know if we are viewing the bookmarks page so we can
  # include certain partials or not
  def adjust_for_bookmarks_view
    if params[:bookmarks_view] == "true"
      session[:search][:bookmarks_view] = true
    else
      session[:search][:bookmarks_view] = false
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
    redirect_to catalog_index_path
  end
  
  # grabs the facet filters from the session
  def filters
    @filters = session[:search][:f] || []
  end
 
  def delete_or_assign_search_session_params
    portal = session[:search][:portal]
    session[:search] = {}
    params.each_pair do |key, value|
      session[:search][key.to_sym] = value unless ["commit", "counter"].include?(key.to_s) ||
      value.blank?
      session[:search][:portal] = portal unless portal.blank?
    end
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
      redirect_to catalog_index_path(my_params)
    end
  end
  
  private
  
    def index_layout
      if searchless?
        if default_portal? and facetless?
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