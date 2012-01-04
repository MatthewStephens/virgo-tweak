# A map plus a combination of a location and/or call number range.
class CallNumberRange < ActiveRecord::Base
  belongs_to :map
  has_many :locations
      
  validates_presence_of :map_id
      
  #Takes in a call number and parses it into tokens.  These tokens are grouped based on if they are alphabetical tokens or numeric tokens
  #Returns array with alpha tokens as first item, numeric as second item
  def self.call_number_parse(call_number)
    alpha_parts = call_number.scan(/[A-Z]{1,}/)
    numeric_parts = call_number.scan(/[0-9]{1,}/)
    return [alpha_parts, numeric_parts]
  end

  #This method takes in a prefix(One half of the range), a call number, and lower(if true then prefix is lower bound, if false then upper bound)
  #It return true if The call number is bounded by the range based on the directionality implied by lower
  def self.bounded?(prefix, call_number, lower=true)
    bound = self.call_number_parse(prefix)
    call_number_parts = self.call_number_parse(call_number)
    out = true
    i = 0 #Alpha index
    j = 0 #numeric index
    k = 0 #alpha numeric switcher
    m = 0  #index proxy
    while out and ((k == 0 and i < bound[0].length) or (k==1 and j < bound[1].length))
      k == 0 ? m = i : m = j
      if lower == true
        out = false if(bound[k][m] > call_number_parts[k][m])
        break if bound[k][m] < call_number_parts[k][m]
      else
        out = false if(bound[k][m] < call_number_parts[k][m])
        break if bound[k][m] > call_number_parts[k][m]
      end
      k == 0 ? i=i+1 : j=j+1
      k == 0 ? (k = 1) : (k = 0)
    end
    return out
  end

  # given a call number and a list of map guides, returns a list of map guides where the given call number is 
  # bounded by the call number range in the given map guides
  def self.call_number_match(call_number, maps)
    return if call_number.blank?
    out = []
    maps.each do |map|
      map.call_number_ranges.each do |raw_range|
        call_number_range = raw_range.call_number_range.split(/\-/)
        out << map if call_number_range.length == 1 and call_number.match(/^#{call_number_range.first}/) rescue()
        next if call_number_range.length != 2
        out << map if self.bounded?(call_number_range.first, call_number, true) and self.bounded?(call_number_range.second, call_number,false)
      end
    end
    return out
  end  
  
  def self.location_match(location_code, maps)
    out = []
    maps.each do |map|
      map.call_number_ranges.each do |raw_range|
        out << map if raw_range.location == location_code
      end
    end
    out
  end
  
  def self.location_and_call_number_match(holding, copy, maps)
    call_number_matches = call_number_match(holding.call_number, maps) || []
    location_and_call_number_matches = location_match(copy.current_location.code, call_number_matches)
    location_matches = location_match(copy.current_location.code, maps)
    
    return location_and_call_number_matches unless location_and_call_number_matches.empty?
    return location_matches unless location_matches.empty?
    return call_number_matches
  end
end
