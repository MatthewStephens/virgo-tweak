module CoverImage::Sources
  
  class LibraryThing
    
    attr :options
    
    def initialize(options={})
      options[:first] = true unless options.has_key?(:first)
      @options=options
    end
    
    def find(keys)
      raise ":isbn keys are required and are the only supported key type" unless keys[:isbn].is_a?(Array)
      api_key = LIBRARY_THING_API_KEY
      base_url = "http://covers.librarything.com/devkey/#{api_key}/large/isbn/"
      data=[]
      base_uri = URI.parse(base_url)
      keys[:isbn].each do |isbn|
        image_url = base_uri.to_s + isbn.to_s
        binary = Blacklight::Utils.valid_image_url?(image_url)
        content_vals = Blacklight::Utils.content_vals(image_url)
        next if ! binary
        data << {
          :source_data=>binary,
          :source_url=>image_url,
          :source=>:library_thing,
          :content_type=>content_vals[:content_type],
          :image_size=>content_vals[:image_size],
          :key_type=>:isbn,
          :key=>isbn,
          :ext=>'.jpg'
        }
        break if @options[:first]
      end
      data
    end
    
  end
  
end