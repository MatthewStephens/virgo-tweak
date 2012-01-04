# A map is a description and URL of a map that can be associated with a map guide
class Map < ActiveRecord::Base
  has_many :call_number_ranges, :dependent => :destroy, :order => :call_number_range
  
  belongs_to :library
  validates_presence_of :url, :description, :library_id
  
  def self.find_best_map(holding, copy)
    # library and call number match
    maps = Map.all :joins => [:library], :conditions => ["libraries.name = ?", holding.library.name]
    hits = CallNumberRange.location_and_call_number_match(holding, copy, maps)
    return hits[0] unless hits.empty?
    # whole library match
    hits = Map.all(:joins => 'INNER JOIN libraries on maps.library_id = libraries.id LEFT JOIN call_number_ranges on call_number_ranges.map_id = maps.id', 
                    :conditions => ["libraries.name = ? AND call_number_range IS NULL", holding.library.code])
    return hits[0] unless hits.empty?
  end
end
