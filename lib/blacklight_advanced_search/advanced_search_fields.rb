module BlacklightAdvancedSearch::AdvancedSearchFields

  # list of advanced search fields
  def advanced_search_fields
    fields = BlacklightAdvancedSearch.config[:search_fields].collect {|x| x[:key]}
    fields.push(BlacklightAdvancedSearch.config[:article_search_fields].collect{|x| x[:key]})
    fields.flatten
  end
  
  def advanced_search_range_fields
    range_fields = BlacklightAdvancedSearch.config[:search_fields].select {|x| x[:range] == 'true'}
    range_fields.collect {|x| x[:key]}
  end

  # hash of populated advanced search fields
  def populated_advanced_search_fields
    fields = {}
    advanced_search_fields.each do |field|
      fields[field] = params[field] if !params[field].blank?
      fields[field] =  session[:search][field.to_sym] if !session[:search][field.to_sym].blank?
    end
    advanced_search_range_fields.each do |field|
      val = ""
      val += params["#{field}_start"] unless params["#{field}_start"].blank?
      val += " - " + params["#{field}_end"] unless params["#{field}_end"].blank?
      fields[field] = val unless val.blank?
    end
    fields
  end

end