class ArticlesController < ApplicationController

  include UVA::ArticlesHelper
  
  helper CatalogHelper
  helper AdvancedHelper
  
  before_filter :delete_or_assign_search_session_params,  :only=>:index
  
  def index
    (@response, @document_list) = get_article_search_results(params)
      respond_to do |format|
      format.html { 
        render 'catalog/index' 
      }
      format.json { 
        params[:controller] = 'catalog'
        render :json => @response.to_json
      }
      format.rss  { render 'catalog/index', :layout => false }
    end
  end

  def facet
    (@response, @document_list) = get_article_search_results(params)    
    render 'catalog/facet', :layout => "popup"
  end
  
  def advanced
    render 'advanced/index'
  end
  
  def delete_or_assign_search_session_params
    return unless params[:catalog_select] == 'articles'
    session[:search] = {}
    params.each_pair do |key, value|
      session[:search][key.to_sym] = value unless ["commit", "counter"].include?(key.to_s) ||
      value.blank?
    end
  end
  
  
end