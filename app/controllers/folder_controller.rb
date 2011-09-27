# Once Folder controller is added to the Blacklight plugin, it should be removed from here.
# This is the "Marked List" functionality.
class FolderController < ApplicationController
  
  include UVA::ScopeHelper
  
  before_filter :resolve_sort, :only=>:index
  
  # add a document_id to the folder
  def create
    session[:folder_document_ids] = session_folder_document_ids
    session[:folder_document_ids] << params[:id] 
    session[:folder_document_ids] = session[:folder_document_ids].flatten
    if session[:folder_document_ids].size > 100
      session[:folder_document_ids] = session[:folder_document_ids].slice(0, 100)
      flash[:error] = "You may only have 100 Starred Items"
    else
      flash[:notice] = "Added to Starred Items"
    end
    respond_to do |format|
      format.js { render :json => session[:folder_document_ids] }
      format.html { redirect_to :back }
    end
  end
 
  # remove a document_id from the folder
  def destroy
    session_folder_document_ids.delete(params[:id])
    flash[:notice] = "Removed from Starred Items"
    respond_to do |format|
      format.js { render :json => session[:folder_document_ids] }
      format.html { redirect_to folder_index_path }
    end
  end
 
  # get rid of the items in the folder
  def clear
    flash[:notice] = "Cleared Starred Items"
    session[:folder_document_ids] = []
    redirect_to folder_index_path
  end
 
  def refworks_texts
    params[:show_max_per_page] = 'true'
    @response, @documents = get_solr_response_for_field_values("id", session_folder_document_ids)
  end
  
  def csv
    params[:show_max_per_page] = 'true'
    @response, @documents = get_solr_response_for_field_values("id", session_folder_document_ids)
    respond_to do |format|
      format.csv
    end   
  end
  
  def citation
    redirect_to :controller => 'catalog', :action => 'citation', :id => session_folder_document_ids, :show_max_per_page => 'true'
  end
  
  def email
    redirect_to :controller => 'catalog', :action => 'email', :id => session_folder_document_ids, :show_max_per_page => 'true'
  end
  
  def endnote
    redirect_to :controller => 'catalog', :action => 'endnote', :id => session_folder_document_ids, :format => 'endnote', :show_max_per_page => 'true'
  end
 
  def session_folder_document_ids
   session[:folder_document_ids] || []
  end  
 
end