module UVA  
  #
  # digital library/image logic
  #
  module DigitalLibraryImageDocument
    
    def fedora_url
      self.value_for(:repository_address_display) || FEDORA_REST_URL
    end
    
    def dl_image_default_preview_src
      return "" if self[:media_resource_id_display] == nil
      "#{fedora_url}/#{self[:media_resource_id_display].first}/uva-lib-bdef:102/getPreview"
    end
    
    def dl_image_viewer(media_id, parent_id)
      "#{fedora_url}/#{media_id}/uva-lib-bdef:102/getImageViewer?parentPid=#{parent_id}"
    end
       
    def dl_image_full_src(media_id)
      # we shouldn't refernece the getScreen behaviors because they are broken quite often
      #"#{fedora_url}/#{media_id}/uva-lib-bdef:102/getScreen"
      # instead, reference the SCREEN datastream
      "#{fedora_url}/#{media_id}/SCREEN"
      
    end
    
    def dl_image_preview_src(media_id)
      "#{fedora_url}/#{media_id}/uva-lib-bdef:102/getPreview"
    end
    
    def dl_jp2k_preview
      "#{fedora_url}/get/#{self[:id]}/djatoka:jp2SDef/getRegion?scale=125,125"
    end
    
    def dl_jp2k_viewer
      "#{fedora_url}/get/#{self[:id]}/djatoka:jp2SDef/getImageView/"
    end
    
    def dl_jp2k_child_screen(media_id)
      "#{fedora_url}/get/#{media_id}/djatoka:jp2SDef/getRegion?scale=900,900"
    end
    
    def dl_jp2k_child_preview(media_id)
      "#{fedora_url}/get/#{media_id}/djatoka:jp2SDef/getRegion?scale=125,125"
    end

    def dl_jp2k_child_full(media_id)
      "#{fedora_url}/get/#{media_id}/djatoka:jp2SDef/getImageView/"
    end

    def dl_jp2k_applet_viewer(media_id, *focus_id)
        if ! focus_id.empty?
          "#{ENV['RAILS_RELATIVE_URL_ROOT']}/catalog/#{media_id}/view?focus=#{focus_id}"
        else
          "#{ENV['RAILS_RELATIVE_URL_ROOT']}/catalog/#{media_id}/view"
        end
      end

    def mods_get_url
      "http://fedora.lib.virginia.edu/get/#{self[:id]}/MODS"
    end

  end
end