module Blacklight::Utils
  
  class << self 
    
    def content_vals(url)
      content_vals = {}
      res = fetch_url(url)
      content_vals = { 
        :content_type => res['content-type'],
        :image_size => res['content-length']
      }
      content_vals
    end
    
    def valid_image_url?(url, min_content_length=90, max_content_length=65535)
      return false if url.nil? || url.blank?
      res = fetch_url(url)
      (ok = (res.code=='200' and res.body.length >= min_content_length and res.body.length <= max_content_length)) rescue false
      ok ? res.body : nil
    end
    
    def fetch_url(url)
      begin
        RAILS_DEFAULT_LOGGER.info "***** URL IS: #{url}"
        url = URI.parse(url)
        http = Net::HTTP.new(url.host,url.port)
        http.use_ssl = url.port==443
        http.get(url.path + '?' + url.query.to_s)
      rescue
        return nil
      end
    end
    
    def valid_isbn?(isbn, c_map = '0123456789X')
      sum = 0
      isbn[0..-2].scan(/\d/).each_with_index do |c,i|
        sum += c.to_i*(i+1)
      end
      isbn[-1] == c_map[sum % c_map.length]
    end
    
    # sort the number facet values alphabetically.
    # limit is for when you only want to sort the first N-number of top hits
    def facet_alpha_sort(response, facet_name, limit = -1)
      facet = response.facets.detect {|f| f.name == facet_name}
      return if facet.nil? || facet.items.nil?
      facet_values = {}
      #build hash keyed on facet value (so we can sort on that)
      #hold on to the last one if the index and limit are the same, so we can tack it onto the end
      facet.items.each_with_index do |item, index|
       if limit > -1 && index == limit
         @last = item
         break
       end
       facet_values[item.value.downcase] = item
      end
     #sort hash
     facet_values = facet_values.sort
     #make new list from sorted hash
     final = []
     facet_values.each do |value|
       final << value[1]
     end
     # tack on the last one
     if limit > -1 && !@last.nil?
       final << @last
     end 
     #reassign sorted list to original
     facet.items = final
   end  
    
  end
  
end