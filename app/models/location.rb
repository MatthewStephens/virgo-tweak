# A location that can be associated with a map guide
class Location < ActiveRecord::Base
  has_many :map_guides
end
