class ArticlesController < ApplicationController

  include Blacklight::Configurable
  include UVA::ArticlesHelper
  
  helper CatalogHelper
  helper AdvancedHelper
  
  before_filter :adjust_params
  before_filter :delete_or_assign_search_session_params,  :only=>:index
  before_filter :set_articles, :only=>[:index, :facet]
    
  configure_blacklight do |config|
    
     # facets
     config.add_facet_field 'tlevel', :label => 'Designation'
     config.add_facet_field 'creationdate', :label => 'Year'
     config.add_facet_field 'topic', :label => 'Subject'
     config.add_facet_field 'rtype', :label => 'Format'
     config.add_facet_field 'jtitle', :label => 'Journal'
     config.add_facet_field 'creator', :label => 'Author'
     config.add_facet_field 'lang', :label => 'Language'                              
    
    # search fields
    config.add_search_field('keyword') do |field|
      field.primo_key = 'any'
      field.label = 'Keyword'
    end
    config.add_search_field('author') do |field|
      field.primo_key = 'creator'
      field.label = 'Author'
    end
    config.add_search_field('title') do |field|
      field.primo_key = 'title'
      field.label = 'Title'
    end
    config.add_search_field('journal') do |field|
      field.primo_key = 'jtitle'
      field.label = 'Journal Title'
    end
    config.add_search_field('publication_date') do |field|
      field.primo_key = 'creationdate'
      field.label = 'Year Published'
      field.range = 'true'
    end
    
    config.add_sort_field '', :label => 'Relevancy', :sort_key => 'articles_relevancy'
    config.add_sort_field 'scdate', :label => 'Date', :sort_key => 'articles_date'
    
    config.advanced_search = {
      :url_key => 'advanced'
    }
    
  end
  
  def index
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