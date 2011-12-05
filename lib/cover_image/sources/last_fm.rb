require 'open-uri'

module CoverImage::Sources
  
  class LastFM
        
    def initialize(options={})
      options[:first] = true unless options.has_key?(:first)
      @options=options
    end
    
    def find(keys)
      
      raise ':mbid is required and the only supported key' unless keys[:mbid].is_a?(Array)
      # add check here - only allow a hash with the key :mbid
      
      ids = keys[:mbid]
      
      data=[]
      ids = [ids] unless ids.is_a?(Array)
      
      api_key = LAST_FM_API_KEY
      
      base_url = "http://ws.audioscrobbler.com/2.0/?method=album.getinfo&api_key=#{api_key}"
      
      ids.each do |mbid|
        url = base_url + "&mbid=#{mbid}"
        
        puts "LAST FM URL:
        #{url}
        "
        
        uri = URI.parse(url)
        
        response = open(uri).collect.join rescue next
        
        if response =~ /status="failed"/i
          puts "LAST FM FAILED!"
          next
        end
        
        doc = Nokogiri::XML(response)
        
        doc_data={
          :source=>:last_fm,
          :key_type=>:mbid,
          :key=>mbid,
          :ext=>'.jpg'
        }
        
        doc_data[:preview_urls] = doc.xpath('//album/url').collect do |v|
          h = v.inner_html
          h.empty? ? nil : h
        end.compact
        
        ['extralarge', 'large', 'medium', 'small'].detect do |size|
          doc.search("//album/image[@size='#{size}']").detect do |v|
            h = v.inner_html
            next if h.to_s.empty?
            binary = Blacklight::Utils.valid_image_url?(h, 100)
            if binary
              doc_data[:source_url]=h
              doc_data[:source_data]=binary
            else
              next
            end
            content_vals = Blacklight::Utils.content_vals(h)
            doc_data[:content_type] = content_vals[:content_type]
            doc_data[:image_size] = content_vals[:image_size]
          end
        end
        
        data << doc_data
        
        break if @options[:first]==true
        
      end
      data
    end
    
  end
  
end