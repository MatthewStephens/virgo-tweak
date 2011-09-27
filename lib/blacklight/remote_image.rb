module Blacklight::RemoteImage
  
  #
  #
  #
  class Finder
    
    attr :options
    attr :finders
    
    def initialize(options={})
      options[:first] = true unless options.has_key?(:first)
      @options=options
      @finders = []
    end
    
    #
    #
    #
    def add_finder(source, finder)
      @finders << {:source=>source, :finder=>finder}
    end
    
    #
    # {:isbn=>[1234567812, 9876543214]}, '.jpg')
    #
    def find(keys, ext='.*')
      data=[]
      finders.each do |f|
        images = f[:finder].find(keys)
        next if images.nil?
        images.each{ |image| @cache.store!(image) } if @cache
        data += images
        break if @options[:first]==true
      end
      return data unless data.empty?
      unless @options[:default_image_url].nil?
        [{
          :source=>'',
          :key_type=>'',
          :key=>'',
          :url=>@options[:default_image_url]
        }]
      end
    end
  end
  
end