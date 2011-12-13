module UVA
  
  module SearchFieldsHelper
    
    def search_field_list(params)
       return music_search_field_list_values if params[:portal] == 'music'
       return video_search_field_list_values if params[:portal] == 'video'
       return article_advanced_search_field_list_values if params[:catalog_select] == 'articles' or params[:controller] == 'articles'
       return advanced_search_field_list_values if params[:controller] == 'advanced'
       return search_field_list_values
     end

     def music_search_field_list_values
       Blacklight.config[:music_search_fields].collect { |obj| normalize_config(obj) }
     end

     def video_search_field_list_values
       Blacklight.config[:video_search_fields].collect {|obj| normalize_config(obj)}
     end

     def extra_search_field_list_values
       Blacklight.config[:extra_search_fields].collect {|obj| normalize_config(obj)}
     end

     def search_field_list_values
       Blacklight.config[:search_fields].collect {|obj| normalize_config(obj)}
     end

     def advanced_search_field_list_values
       BlacklightAdvancedSearch.config[:search_fields].collect  {|obj| normalize_config(obj)}
     end

     def article_advanced_search_field_list_values
       BlacklightAdvancedSearch.config[:article_search_fields].collect  {|obj| normalize_config(obj)}
     end

     def normalize_config(field_hash)
       field_hash = field_hash.clone
       raise Exception.new("Search field config is missing ':key' => #{field_hash.inspect}") unless field_hash[:key]

       # If no display_label was provided, turn the :key into one.      
       field_hash[:display_label] ||= field_hash[:key].titlecase

       # If no :qt was provided, take from config default
       field_hash[:qt] ||= config[:default_solr_params][:qt] if config[:default_solr_params]

       field_hash
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
    
     def label_for_search_field(key)
       field_def = search_field_def_for_key(key)
       if field_def && field_def[:display_label]
          field_def[:display_label]
       else
          "Keyword"
       end            
     end
    
      


  
      # Returns default search field, used for simpler display in history, etc.
      # if not set in config, defaults to first field listed in #search_field_list
      #def default_search_field(params)
      #  Blacklight.config[:default_search_field] || search_field_list(params)[0]
      #end
    #end
  end
end