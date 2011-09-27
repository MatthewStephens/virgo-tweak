module Blacklight::SearchFields
  extend ActiveSupport::Memoizable
  
  require_dependency 'vendor/plugins/blacklight/lib/blacklight/search_fields.rb'
  
  def search_field_list(params)
    return music_search_field_list_values if params[:portal] == 'music'
    return video_search_field_list_values if params[:portal] == 'video'
    return article_advanced_search_field_list_values if params[:catalog_select] == 'articles' or params[:controller] == 'articles'
    return advanced_search_field_list_values if params[:controller] == 'advanced'
    return search_field_list_values
  end
  
  # Returns suitable argument to options_for_select method, to create
  # an html select based on #search_field_list. Skips search_fields
  # marked :include_in_simple_select => false
  def search_field_options_for_select(params)
    search_field_list(params).collect do |field_def|
      [field_def[:display_label],  field_def[:key]] unless field_def[:include_in_simple_select] == false
    end.compact
  end
  
  def search_field_def_for_key(key)
    return nil if key.blank?
    all_field_list_values = []
    search_field_list_values.collect { |v| all_field_list_values << v }
    music_search_field_list_values.collect { |v| all_field_list_values << v }
    video_search_field_list_values.collect { |v| all_field_list_values << v }
    extra_search_field_list_values.collect { |v| all_field_list_values << v }
    article_advanced_search_field_list_values.collect { |v| all_field_list_values << v }
    advanced_search_field_list_values.collect { |v| all_field_list_values << v }
    ret = all_field_list_values.find {|c| c[:key] == key}
    ret
  end
  
  def music_search_field_list_values
    Blacklight.config[:music_search_fields].collect { |obj| 
      normalize_config(obj)
    }
  end
  memoize :music_search_field_list_values
  
  def video_search_field_list_values
    Blacklight.config[:video_search_fields].collect {|obj| normalize_config(obj)}
  end
  memoize :video_search_field_list_values
  
  def extra_search_field_list_values
    Blacklight.config[:extra_search_fields].collect {|obj| normalize_config(obj)}
  end
  memoize :extra_search_field_list_values
  
  def search_field_list_values
    Blacklight.config[:search_fields].collect {|obj| normalize_config(obj)}
  end
  memoize :search_field_list_values
  
  def advanced_search_field_list_values
    BlacklightAdvancedSearch.config[:search_fields].collect  {|obj| normalize_config(obj)}
  end
  memoize :advanced_search_field_list_values
  
  def article_advanced_search_field_list_values
    BlacklightAdvancedSearch.config[:article_search_fields].collect  {|obj| normalize_config(obj)}
  end
  memoize :article_advanced_search_field_list_values
  
  # Returns default search field, used for simpler display in history, etc.
  # if not set in config, defaults to first field listed in #search_field_list
  def default_search_field(params)
    Blacklight.config[:default_search_field] || search_field_list(params)[0]
  end
end