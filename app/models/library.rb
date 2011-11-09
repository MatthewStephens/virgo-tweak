# A library that can be associated with a map guide
class Library < ActiveRecord::Base
  has_many :maps
end
