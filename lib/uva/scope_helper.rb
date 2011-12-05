module UVA::ScopeHelper

  def searchless?
    search_session.keys - [:controller, :action, :total, :counter, :commit, :page, :portal, :sort, :sort_key, :special_collections, :"facet.limit", :width] == []
  end

  def default_portal?
    search_session[:portal].nil? or search_session[:portal] == "all"
  end

  def facetless?
    !params[:f]
  end

  def article_search?
    params[:controller] == "articles"
  end

  def advanced_search?
    params[:search_field] == "advanced"
  end

  def video_portal?
    search_session[:portal] == 'video' 
  end

  def music_portal?
    params[:portal] == 'music'
  end
  
  # determines if we are on the home page (no active search)
  def home_page?
    return true if facetless? and searchless? and !advanced_search? and !article_search? and default_portal?
    return false
  end
  
  def music_home_page?
    return true if facetless? and searchless? and !advanced_search? and !article_search? and music_portal?
    return false
  end
  
  # this is kind of gross.  we know that it's the video home page if the only
  # constraing is format_facet = video
  def video_home_page?
    return true if searchless? and facet_params.size <=1 and facet_params['format_facet'].size <=1 and facet_params['format_facet'].include?('Video') rescue false
    return false
  end
  
  def search_session
    session[:search] ||= {}
  end
  
  def session_folder_document_ids
    session[:folder_document_ids] ||= []
  end  
 
  def session_folder_article_ids
    session[:folder_article_ids] ||= []
  end
  
  #
  # If the :format is rss, use :received
  # If there is no query, don't allow sorting on relevance
  #
  def resolve_sort
    # if the request is for rss, sort on date_received_facet
    if params[:format]=='rss'
      params[:sort_key] == 'published' ? solr_sort = solr_sort_val('published') : solr_sort = solr_sort_val('received')
    elsif params[:f] and params[:f].include?('digital_collection_facet') and params[:sort_key].blank? and params[:q].blank?
      # sort digital_collection_facet searches with no keyword by published date unless user picked sort
      solr_sort = solr_sort_val('published')
      params[:sort_key] = 'published'
    else
      # if there is a query, but no sort set sort by relevancy
      if params[:q] and !params[:q].blank? and params[:sort_key].blank?
        solr_sort = solr_sort_val('relevancy')
      else
        # sort by the requested sort, if invalid, sort by date_received
        solr_sort = solr_sort_val(params[:sort_key]) || solr_sort_val('received')
      end
    end
    params[:sort] = solr_sort
    search_session[:sort] = solr_sort
    search_session[:sort_key] = params[:sort_key]
  end

  # lookup the solr sort from the config for this sort_key
  def solr_sort_val(sort_key)
    return if sort_key.blank?
    Blacklight.config[:sort_fields][sort_key][1] rescue return
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