module BlacklightAdvancedSearch::CatalogHelperOverride

  require_dependency 'vendor/plugins/blacklight_advanced_search/lib/blacklight_advanced_search/catalog_helper_override.rb'
  

  def remove_advanced_facet_param(field, value, my_params = params)
    my_params = Marshal.load(Marshal.dump(my_params))
    if (my_params[:f_inclusive] && 
        my_params[:f_inclusive][field] &&
        my_params[:f_inclusive][field].include?(value))
        
      my_params[:f_inclusive][field] = my_params[:f_inclusive][field].dup
      my_params[:f_inclusive][field].delete(value)
      
      my_params[:f_inclusive].delete(field) if my_params[:f_inclusive][field].length == 0
      
      my_params.delete(:f_inclusive) if my_params[:f_inclusive].length == 0
    end

    my_params.delete_if do |key, value| 
      [:page, :id, :counter, :commit].include?(key)
    end
    my_params
  end
  
end