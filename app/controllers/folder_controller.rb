# Once Folder controller is added to the Blacklight plugin, it should be removed from here.
# This is the "Marked List" functionality.
class FolderController < ApplicationController
  
  include UVA::ArticlesHelper
  
  before_filter :resolve_sort, :only=>:index
  before_filter :articles, :only=>[:index, :csv]
    
  # add a document_id to the folder
  def create
    add_to_folder_session(params[:id], session_folder_document_ids)
    add_to_folder_session(params[:article_id], session_folder_article_ids)
    respond_to do |format|
      format.js { render :json => session_folder_document_ids }
      format.html { redirect_to :back }
    end
  end
 
  # remove a document_id from the folder
  def destroy
    session_folder_document_ids.delete(params[:id])
    flash[:notice] = "Removed from Starred Items"
    respond_to do |format|
      format.js { render :json => session_folder_document_ids }
      format.html { redirect_to folder_index_path }
    end
  end
  
  def article_destroy
    session_folder_article_ids.delete(params[:article_id])
    flash[:notice] = "Removed from Starred Items"
    respond_to do |format|
      format.js { render :json => session_folder_document_ids }
      format.html { redirect_to folder_index_path }
    end
  end
 
  # get rid of the items in the folder
  def clear
    flash[:notice] = "Cleared Starred Items"
    session_folder_document_ids.clear
    session_folder_article_ids.clear
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
    redirect_to :controller => 'catalog', :action => 'citation', :id => session_folder_document_ids, :show_max_per_page => 'true', :article_id => session_folder_article_ids
  end
  
  def email
    redirect_to :controller => 'catalog', :action => 'email', :id => session_folder_document_ids, :show_max_per_page => 'true', :article_id => session_folder_article_ids
  end
  
  def endnote
    redirect_to :controller => 'catalog', :action => 'endnote', :id => session_folder_document_ids, :format => 'endnote', :show_max_per_page => 'true'
  end
 
  def remaining_id_count
    100 - session_folder_document_ids.count - session_folder_article_ids.count
  end
  
  def add_to_folder_session(field, session_ids)
    ids = field.to_a || []
    if remaining_id_count < ids.count
      flash[:error] = "You may only have 100 Starred Items"
      ids = ids.slice(0, remaining_id_count)
    elsif ids.count > 0
      flash[:notice] = "Added to Starred Items"
    end
    session_ids << ids
    session_ids.flatten!
  end
 
  def articles
    @articles = get_articles_by_ids(session_folder_article_ids)
  end
   
end