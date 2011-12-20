# special collections requests are for patrons in special collections to make requests for
# viewing items.  Also used by special collections administrators to view and process the
# request queue.
require 'uva/ldap'
class SpecialCollectionsRequestsController < ApplicationController

  include UVA::SolrHelperOverride

  before_filter :verify_admin, :except => [:new, :create, :start, :non_uva]
  before_filter :bypass_login, :only => [:start]
  before_filter :setup_request, :only => [:start, :non_uva, :new]
  before_filter :build_request, :only => [:create]
  before_filter :verify_user, :only => [:new, :create]
  
  # dummy method to display which type of login a person wants to use (UVa or non-UVa)
  def start
  end

  # allows a non-uva person to enter his or her library id
  def non_uva
  end

  # pulls up the items and allows a person to construct a request
  def new
    response, document = get_solr_response_for_doc_id(params[:id], params)
    document.availability = Firehose::Availability.find(document)
    @special_collections_request.document = document
  end
  
  # submits the request
  def create
    if @special_collections_request.special_collections_request_items.empty?
      flash[:error] = 'You must select at least one item.'
      redirect_to new_special_collections_request_path(:id => @special_collections_request.document_id)
      return
    end
    respond_to do |format|
      if @special_collections_request.save
        session[:non_uva_login] = nil
        flash[:notice] = 'Request successfully submitted.'
        format.html { redirect_to(catalog_path(@special_collections_request[:document_id])) }
      else
        format.html { render :action => 'start' }
      end
    end
  end
  
  # used by special collections staff to view the queue  
  def index
    start_time = DateTime.civil(params[:range][:"date(1i)"].to_i,params[:range][:"date(2i)"].to_i,params[:range][:"date(3i)"].to_i) rescue DateTime.civil(Time.now.year, Time.now.month, Time.now.day)
    end_time = start_time + 1
    @date = start_time.strftime("%m/%d/%Y")
    @special_collections_requests = SpecialCollectionsRequest.find(:all, :conditions => {:created_at => start_time..end_time}, :order => 'created_at desc') || []
    @special_collections_requests.each do |request|
      response, document = get_solr_response_for_doc_id(request.document_id, params)
      request.document = document    
    end
  end
  
  # used by special collections staff to review an individual request
  def edit
    @special_collections_request = SpecialCollectionsRequest.find(params[:id])
    response, document = get_solr_response_for_doc_id(@special_collections_request.document_id)
    document.availability = Firehose::Availability.find(document)
    @special_collections_request.document = document   
  end
  
  # used by special collections staff to process the request
  def update
    @special_collections_request = SpecialCollectionsRequest.find(params[:id])  
    respond_to do |format|
      if @special_collections_request.update_attributes(params[:special_collections_request])
        format.html { redirect_to(special_collections_request_path(params[:id])) }
      else
        format.html { render :action => 'edit' }
      end
    end
  end
  
  # generates a pdf of the request
  def show
    @special_collections_request = SpecialCollectionsRequest.find(
      params[:id], :include => :special_collections_request_items, 
      :order => 'special_collections_request_items.location, special_collections_request_items.barcode')
    @response, @document = get_solr_response_for_doc_id(@special_collections_request.document_id) 
    @date = @special_collections_request.created_at.strftime("%A, %B %e, %Y")
    respond_to do |format|
      format.pdf {
        prawnto :prawn=>{:page_layout=>:landscape}, :inline=>false
        render :layout => false
      }
    end
  end

 
  
  
  protected
  # verifies that the current user is a special collections administrator
  def verify_admin
    if current_user.nil?
      flash[:error] = "Please log in to manage Special Collections Requests. <a class='btn small' href='/login?redirect=special_collections_admin'>Login</a>"
      redirect_to catalog_index_path 
    else
      unless SpecialCollectionsUser.find_by_computing_id(current_user[:login])
        flash[:error] = "You are not authorized to manage Special Collections Requests."
        redirect_to catalog_index_path 
      end
    end
  end
  
  # makes it so that a person doesn't have to re-login if they are already logged in
  def bypass_login
    return if current_user.nil? || current_user[:login].nil?
    redirect_to new_special_collections_request_path(:id => params[:id])
  end
  
  # generates a new Special Collections Request based on the id in the params
  def setup_request
    @special_collections_request = SpecialCollectionsRequest.new
    @special_collections_request.document_id = params[:id]
  end
  
  # builds out a request from the params
  def build_request
    @special_collections_request = SpecialCollectionsRequest.new(params[:special_collections_request])
    @special_collections_request.build(params[:location_plus_call_number])
  end
  
  # ensures that there is a user id present
  # if the non-uva login route was specified, verifies that the supplied id is not a computing id
  # does a patron lookup to ensure that it's a valid patron id
  def verify_user
    # if we came from a non-uva login id, set that in session
    if !current_user.nil?
      @special_collections_request.user_id = current_user[:login]
    else
      session[:non_uva_login] = params[:user_id] unless params[:user_id].blank?
      @special_collections_request.user_id = session[:non_uva_login]
      uva_id?
    end
    check_login
    patron_lookup
  end
  
  # makes sure that a user id is present
  def check_login
    if @special_collections_request.user_id.blank?
      flash[:error] = 'You must establish your identify before making a request.' 
      redirect_to start_special_collections_request_path(:id => @special_collections_request.document_id)
    end
  end
  
  # looks up the user id to see if it's a UVa computing id
  def uva_id?
    return false if @special_collections_request.user_id.blank?
    @special_collections_request.extend(UVA::Ldap)
    unless @special_collections_request.full_name.blank?
      flash[:error] = 'UVa members should use NetBadge to authenticate'
      session[:non_uva_login] = nil
      redirect_to start_special_collections_request_path(:id => @special_collections_request.document_id)
    end
  end
  
  # looks up the user id to see if it's a valid patron.  
  # sets the name from the patron record.
  def patron_lookup
    return if @special_collections_request.user_id.blank?
    patron = get_patron(@special_collections_request.user_id)
    last_name = patron.last_name rescue ""
    first_name = patron.first_name rescue ""
    middle_name = patron.middle_name rescue ""
    unless last_name.blank?
      name = ("" + last_name + ", " + first_name + " " + middle_name).strip
    else
      name = patron.display_name rescue ""
    end
    if @special_collections_request.user_id =~ /^demo_/
      @special_collections_request.name = @special_collections_request.user_id
    elsif name.blank?
      flash[:error] = 'Unable to locate your patron record.  Please verify your login information and try again.'
      session[:non_uva_login] = nil
      redirect_to catalog_path(:id => @special_collections_request.document_id)
    else
      @special_collections_request.name = name
    end
  end
end