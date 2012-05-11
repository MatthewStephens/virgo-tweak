class VideoController < CatalogController
  
  before_filter :featured_documents, :only=>:index
    
  configure_blacklight do |config|
    config.facet_fields = {}
    config.add_facet_field 'library_facet', :label => 'Library'
    config.add_facet_field 'format_facet', :label => 'Format'
    config.add_facet_field 'video_genre_facet', :label => 'Genre'
    config.add_facet_field 'subject_facet', :label => 'Subject'
    config.add_facet_field 'language_facet', :label => 'Language'
    config.add_facet_field 'series_title_facet', :label => 'Series Title'
  end
  
  # gets cover images for featured documents
  def featured_documents
    return unless facetless? && params[:q].blank? && params[:search_field] != 'advanced'
    phrase_filters = {}
    phrase_filters[:format_facet] = ["Video"]
    @featured_documents = get_featured_documents(phrase_filters)
  end
  
end