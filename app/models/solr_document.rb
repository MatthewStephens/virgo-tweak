require 'lib/uva/digital_library_image_document'
require 'blacklight/solr/document'
require 'lib/cover_image/image'

class SolrDocument
  
  include Blacklight::Solr::Document
  
  attr_accessor :availability
  
  #DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  #SolrDocument.use_extension( Blacklight::Solr::Document::DublinCore)
  extension_parameters[:marc_source_field] = :marc_display
  extension_parameters[:marc_format_type] = :marcxml

  use_extension( Blacklight::Solr::Document::Marc) do |document|
    document.key?( :marc_display  )
  end
  
  use_extension( UVA::DigitalLibraryImageDocument) do |document|
    document.doc_type==:dl_image || document.doc_type==:dl_book || document.doc_sub_type==:dl_book
  end
  
  def initialize(doc, solr_response=nil)
    super(doc, solr_response)
    will_export_as(:json, "application/json")
  end
  
  # This document is also exportable as a json
  def export_as_json
    to_marc.to_hash.to_json
  end  

  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  field_semantics.merge!(
                        :title => "title_display",
                        :author => "author_display",
                        :language => "language_facet"
                        )

          
  def image_path
    doc_image = CoverImage::Image.new(self)
    return doc_image.url_path
  end
  
  def has_image?
    doc_image = CoverImage::Image.new(self)
    return doc_image.has_image?
  end
  
  #
  # Returns an instance of UVA::VirgoMarcRecord if this document has marc_display data
  # UVA::VirgoMarcRecord should probably move to UVA::Document::Marc
  #
  def marc_display
    if self.respond_to?(:to_marc) and self.to_marc
      @marc_display||=UVA::VirgoMarcRecord.new(self.export_as_marcxml, :xml)
      @marc_display
    end
  end
  
  #
  # The FedoraRepo ID
  #
  def fedora_doc_id
    get(:datafile_name_display).to_s.sub(/^\/FedoraRepo\/text\//,'') if has?(:datafile_name_display)
  end
  
  # Determines what kind of a document this.
  #
  def doc_type
    @doc_type||=(
      types = [
        [:hathi, has?(:source_facet, 'Hathi Trust Digital Library')],
        [:dl_video, (has?(:source_facet, 'UVA Library Digital Repository') and has?(:format_facet, 'Video'))],
        [:lib_album, has?(:format_facet, /Musical Recording/i)],
        [:dl_book, ((has?(:content_model_facet, 'digital_book') or has?(:content_model_facet, 'jp2k')) and !has?(:marc_display_facet, 'true'))],
        [:lib_catalog, (has?(:source_facet, 'Library Catalog') or has?(:marc_display_facet, 'true'))],
        [:lib_coins, has?(:source_facet, 'U.Va. Art Museum')],
        [:dl_image, has?(:content_model_facet, 'media')],
        [:dl_text, has?(:content_model_facet, 'text')],
        [:dl_text, has?(:content_model_facet, 'finding aid')],
        [:dl_manuscript, has?(:content_model_facet, 'manuscript')],
        [:default, true]
      ]
      types.detect{|v|v.last}.first
    )
  end

  # determines subtype of document, which is used for controlling display in some partials
  def doc_sub_type
     @doc_sub_type||=(
       types = [
         [:dl_book, has?(:content_model_facet, 'digital_book')],
         [:musical_recording, has?(:format_facet, /Musical Recording/i)],
         [:musical_score, has?(:format_facet, /Musical Score/i)],
         [:finding_aid, has?(:digital_collection_facet, /UVa Archival Finding Aids/i)],
         [:default, true]
       ]
       types.detect{|v|v.last}.first
       )
   end
  
  #
  # doc.value_for(:title_display)
  # doc.value_for(:title_display, ' | ', 'no title')
  #
  def value_for(field, sep='; ', default='n/a')
    values = get(field, {sep, default})
    return default if values.nil?
    # seems that a lot of field values end with " ;" or " :"
    # we'll be removing this from within the index, but for now we'll handle it here...
    values.map!{|v|v.gsub(/;$|:$|\/$/,'').gsub(/ +/, ' ')}
    values.join(sep)
  end
  
  # determines if values exist for the given field
  def has_value?(field)
    value_for(field, '', nil).nil? ? false : true
  end
  
  # gets an array of values for the given field
  def values_for(field)
    get(field, {nil, ''}) rescue []
  end

  def locations
    values = get(:location_facet)
  end
  
  def online_only?
    vals = values_for(:location_facet)
    if !vals.nil?
      return true if vals.size == 1 && vals[0] == "Internet materials"
    end
    return true if has?(:source_facet, 'Digital Library')
    false
  end
  
  def sas_only?
    vals = values_for(:library_facet)
    return false if vals.nil?
    vals.each do |val|
      return false unless val =~ /Semester at Sea/i
    end
    true
  end
  
  #
  # go through all isbns
  # split on spaces,
  # grab the first item
  # reject all empty values
  # return an array
  #
  def isbns
    return [] if values_for(:isbn_display).nil?
    @isbns||=values_for(:isbn_display).collect{|i|i.split(' ').first}.reject{|v|v.to_s.empty?}
  end
  
  
  #
  # collection of common author fields
  #
  def author_type_fields
    authors={}
    author_display = get(:author_display)
    authors[:author_display] = author_display unless author_display.nil?
    linked_author_display = get(:linked_author_display)
    authors[:linked_author_display] = linked_author_display unless linked_author_display.nil?
    authors
  end
  
  
  #
  # collection of common title fields
  #
  def title_type_fields
    titles={}
    title_display = get(:title_display)
    titles[:title_display] = title_display unless title_display.nil?
    linked_title_display = get(:linked_title_display)
    titles[:linked_title_display] = linked_title_display unless linked_title_display.nil?
    titles
  end

  #
  # returns the virgo ckey
  #
  def ckey
    ck = get(:id)
    ck[1, ck.length - 1]
  end
  
  # determines wheter or not the document is shadowed
  def hidden?
    has?(:shadowed_location_facet, 'HIDDEN')
  end
  
  # gets the xml that was used to generate the document
  # for marc items, that's the marc record
  # for digital library objects, it's desc_meta_file_display
  def to_xml      
    raise RedirectNeeded.new(mods_get_url) if (doc_type == :dl_book or doc_type == :dl_image)
    if self.respond_to?(:to_marc) and self.to_marc
      self.export_as_marcxml
    elsif !get(:desc_meta_file_display).nil?
      values_for(:desc_meta_file_display).join
    end
  end
end

