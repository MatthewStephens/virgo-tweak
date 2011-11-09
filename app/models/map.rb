# A map is a description and URL of a map that can be associated with a map guide
class Map < ActiveRecord::Base
  has_many :call_number_ranges, :dependent => :destroy, :order => :call_number_range
  
  belongs_to :library
  validates_presence_of :url, :description, :library_id
  
  def self.find_best_map(library_code, call_number)
    # library and call number match
    maps = Map.all :joins => [:library, :call_number_ranges], :conditions => ["libraries.name = ?", library_code]
    hits = CallNumberRange.call_number_match(call_number, maps)
    return hits[0] unless hits.empty?
    # whole library match
    hits = Map.all (:joins => 'INNER JOIN libraries on maps.library_id = libraries.id LEFT JOIN call_number_ranges on call_number_ranges.map_id = maps.id', 
                    :conditions => ["libraries.name = ? AND call_number_range IS NULL", library_code])
    return hits[0] unless hits.empty?
  end
end
