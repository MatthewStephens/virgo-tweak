class MusicController < CatalogController
  
  before_filter :featured_documents, :only=>:index  
  
  configure_blacklight do |config|
    config.facet_fields.clear
    config.add_facet_field 'library_facet', :label => 'Library'
    config.add_facet_field 'format_facet', :label => 'Format'
    config.add_facet_field 'recordings_and_scores_facet', :label => 'Recordings and scores'
    config.add_facet_field 'recording_format_facet', :label => 'Recording format'
    config.add_facet_field 'instrument_facet', :label => 'Instrument'
    config.add_facet_field 'music_composition_era_facet', :label => 'Composition era'
    config.add_facet_field 'author_facet', :label => 'Author'
    config.add_facet_field 'language_facet', :label => 'Language'
    config.add_facet_field 'source_facet', :label => 'Source'
    config.add_facet_field 'region_facet', :label => 'Region'
    config.add_facet_field 'subject_facet', :label => 'Subject'
    
    config.add_search_field('music') do |field|
      field.label = 'Keyword'
      field.solr_local_parameters = {
       :qf => '$qf_music',
       :pf => '$pf_music'
      }
    end
    
  end
  
  # gets cover images for featured documents
  def featured_documents
    return unless facetless? && params[:q].blank? && params[:search_field] != 'advanced'
    phrase_filters = {}
    phrase_filters[:library_facet] = ["Music"]
    phrase_filters[:format_facet] = "\"Musical_Recording\"^2.0 \"Book\""
    @featured_documents = get_featured_documents(phrase_filters)
  end
  
end