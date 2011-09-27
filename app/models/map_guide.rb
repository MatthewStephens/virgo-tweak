# A map plus a combination of a location and/or call number range.
class MapGuide < ActiveRecord::Base
  belongs_to :location
  belongs_to :map
  before_save :adjust_call_number_range
  
  validates_presence_of :location_id
  validates_presence_of :map_id
  
  # adjusts call number range so that it is made into a dash if it is blank
  def adjust_call_number_range
    self.call_number_range = "-" if call_number_range.blank?
  end
  
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
  def self.call_number_match(call_number, map_guides)
    out = []
    map_guides.each do |map_guide|
      call_number_range = map_guide.call_number_range.split(/\-/)
      next if call_number_range.length != 2
      out << map_guide if self.bounded?(call_number_range.first, call_number, true) and self.bounded?(call_number_range.second, call_number,false)
    end
    return out
  end
  
  #Given a location code and a call_number return the map that best fits the call_number within that location.
  #If no appropriate map is found, returns default map for that location
  #If the default does not exist, returns nil
  def self.find_best_map(location_code, call_number)
    if call_number.nil?
      return nil
    end
    match_loc = self.find(:all, :joins => :location, :conditions => ["locations.code = ?", location_code])
    match_entire_loc = self.find(:all, :joins => :location, :conditions => ["locations.code = ? AND map_guides.call_number_range = '-'", location_code])
    maps =
    [
    self.call_number_match(call_number, match_loc),
    match_entire_loc
    ]
    temp = maps.detect{ |v| !v.empty? }
    !temp.nil? ? temp.first : nil
  end
end
