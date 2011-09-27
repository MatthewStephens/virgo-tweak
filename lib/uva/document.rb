module UVA
  
  #
  # digital library/image logic
  #
  module DigitalLibraryImageDocument
    
    def fedora_get_url
      self[:repository_address_display]||"http://repo.lib.virginia.edu:18080/fedora/get"
    end
    
    def fedora_url
      self.value_for(:repository_address_display) || FEDORA_REST_URL
		end
    
    def dl_image_default_preview_src
      return "" if self[:media_resource_id_display] == nil
      "#{fedora_get_url}/#{self[:media_resource_id_display].first}/uva-lib-bdef:102/getPreview"
    end
    
    def dl_image_viewer(media_id, parent_id)
      "#{fedora_get_url}/#{media_id}/uva-lib-bdef:102/getImageViewer?parentPid=#{parent_id}"
    end
       
    def dl_image_full_src(media_id)
      # we shouldn't refernece the getScreen behaviors because they are broken quite often
      #"#{fedora_get_url}/#{media_id}/uva-lib-bdef:102/getScreen"
      # instead, reference the SCREEN datastream
      "#{fedora_get_url}/#{media_id}/SCREEN"
      
    end
    
    def dl_image_preview_src(media_id)
      "#{fedora_get_url}/#{media_id}/uva-lib-bdef:102/getPreview"
    end
    
    def dl_jp2k_preview
      "#{fedora_get_url}/get/#{self[:id]}/djatoka:jp2SDef/getRegion?scale=125,125"
    end
    
    def dl_jp2k_viewer
      "#{fedora_get_url}/get/#{self[:id]}/djatoka:jp2SDef/getImageView/"
    end
    
    def dl_jp2k_child_screen(media_id)
      "#{fedora_get_url}/get/#{media_id}/djatoka:jp2SDef/getRegion?scale=900,900"
    end
    
    def dl_jp2k_child_preview(media_id)
      "#{fedora_get_url}/get/#{media_id}/djatoka:jp2SDef/getRegion?scale=125,125"
    end

    def dl_jp2k_child_full(media_id)
      "#{fedora_get_url}/get/#{media_id}/djatoka:jp2SDef/getImageView/"
    end
    
    def dl_jp2k_applet_viewer(media_id, *focus_id)
      if ! focus_id.empty?
        "#{ENV['RAILS_RELATIVE_URL_ROOT']}/catalog/#{media_id}/page_turner?focus=#{focus_id}"
      else
        "#{ENV['RAILS_RELATIVE_URL_ROOT']}/catalog/#{media_id}/page_turner"
      end
    end
    
    def mods_get_url
      "http://fedora.lib.virginia.edu/get/#{self[:id]}/MODS"
    end
    
  end
  
  #
  # The extension happens in app/controllers/catalog.rb
  #
  module Document
    # When a redirect to another URL is needed, use this
    class RedirectNeeded < RuntimeError; end
    
    attr_accessor :availability
    
    def self.extended(base)
      raise "This is not a solr doc - it's nil" if base.nil?
      base.extend DigitalLibraryImageDocument if base.doc_type==:dl_image || base.doc_type==:dl_jp2k || base.doc_type==:dl_book
    end
            
    # image data for a document
    # this method should return the image file in binary form
    #def image_data
    #  doc_image = UVA::DocumentImage.new(self)
    #  if doc_image.image_data.nil?
    #    return doc_image.default_data
    #  end
    #  return doc_image.data
    #end
    
    def image_path
      doc_image = UVA::DocumentImage.new(self)
      return doc_image.url_path
    end
    
    def has_image?
      doc_image = UVA::DocumentImage.new(self)
      return doc_image.has_image?
    end
    
  #  def album_covers
  #    return if doc_type != :lib_album
  #    doc_image = UVA::DocumentImage.new(self)
  #    album_covers = doc_image.preview
  #  end
    
  #  def album_cover(music_brainz_id)
  #    return if doc_type != :lib_album
  #    doc_image = UVA::DocumentImage.new(self)
  #    album_cover = doc_image.preview_album(music_brainz_id)
  #  end      
    
    # get previews from syndetics
    #def previews
    #  previews = []
    #  isbns.each do |isbn|
    #    finder = Blacklight::Syndetics::Review.new
    #    previews << finder.find_by_isbn(isbn)
    #  end
    #  previews
    # end
    
    #
    # Returns an instance of UVA::VirgoMarcRecord if this document has marc_display data
    # UVA::VirgoMarcRecord should probably move to UVA::Document::Marc
    #
    def marc_display
      if self.respond_to?(:to_marc) and self.to_marc
      #if self.has?(:marc_display)
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
          [:lib_album, has?(:format_facet, /Musical Recording/i)],
          [:dl_book, has?(:content_model_facet, 'digital_book')],
          [:lib_catalog, has?(:source_facet, 'Library Catalog')],
          [:lib_coins, has?(:source_facet, 'U.Va. Art Museum')],
          [:dl_image, has?(:content_model_facet, 'media')],
          [:dl_text, has?(:content_model_facet, 'text')],
          [:dl_text, has?(:content_model_facet, 'finding aid')],
          [:dl_jp2k, has?(:content_model_facet, 'jp2k')],
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
      raise RedirectNeeded.new(mods_get_url) if doc_type == :dl_jp2k
      if self.respond_to?(:to_marc) and self.to_marc
        self.export_as_marcxml
      elsif !get(:desc_meta_file_display).nil?
        values_for(:desc_meta_file_display).join
      end
    end
  end
  
end
