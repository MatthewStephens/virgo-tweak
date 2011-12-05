module CoverImage
  
  class Image
    
    attr_reader :doc
    
    def initialize(doc)
      @doc = doc
    end
    
    def has_image?
      File.exists?(file_path)
    end
    
    def file_path
      File.join(RAILS_ROOT, 'public', 'images', 'bookcovers', path_parts)
    end
    
    def url_path
      if !has_image?
        log_failed_request!
        return default_url_path  
      end
      File.join('/images', 'bookcovers', path_parts)
    end
    
    # carves up the document into directories and filename
    # examples:  u1 = 1.jpg;  u1234 = 123/1234.jpg; u12345 = 123/u12345.jpg; u1234567 = 123/456/u123456.jpg
    def path_parts
      path = ''
      parts =  @doc.value_for(:id).scan(/\d{1,3}/)
      parts.each_with_index do |val, index|
         path = File.join(path, '/', val) unless index == parts.length - 1
       end
      path += "/#{@doc.value_for(:id)}.jpg"
      path
    end
    
    # the path for when no cover image is found
    def default_url_path
      return "/images/catalog/default_bookcover.gif"
    end

    # log that a user tried to look at this image, but we didn't have one in the cache
    def log_failed_request!
      return if recently_requested?
      DocumentImageRequestRecord.create(:document_id => @doc.value_for(:id), :requested_at => Time.now)    
    end
    
    # checks to see if we have already requested this image within the last day
    def recently_requested?
      images = DocumentImageRequestRecord.find_all_by_document_id(@doc.value_for(:id),
              :conditions => ['requested_at >= ?', 1.day.ago])
      return true if images.length > 0
      false
    end
  
  end
  
end