# A location that can be associated with a call number range
class Location < ActiveRecord::Base
  has_many :call_number_ranges
end