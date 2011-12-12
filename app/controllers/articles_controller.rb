class ArticlesController < ApplicationController

  include UVA::ArticlesHelper
  
  helper CatalogHelper
  helper AdvancedHelper
  
  before_filter :adjust_params
  before_filter :delete_or_assign_search_session_params,  :only=>:index
  before_filter :set_articles, :only=>[:index, :facet]
  
  def index
    Rails.logger.info("molly, articles index")
    respond_to do |format|
      format.html { render 'catalog/index' }
      format.json { 
        params[:controller] = 'catalog'
        render :json => @response.to_json
      }
      format.rss  { render 'catalog/index', :layout => false }
    end
  end

  def facet
    render 'catalog/facet', :layout => "popup"
  end
  
  def advanced
    render 'advanced/index'
  end
  
  protected
  
  def adjust_params
    params[:catalog_select] = "articles" unless params[:catalog_select] == "all"
  end
  
  def set_articles
    @response, @document_list = get_article_search_results(params)
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