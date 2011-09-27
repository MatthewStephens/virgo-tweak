# A map is a description and URL of a map that can be associated with a map guide
class Map < ActiveRecord::Base
  has_many :map_guides, :dependent => :destroy
  validates_presence_of :url, :description  
end
