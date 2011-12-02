class Bookmark < ActiveRecord::Base
  
  belongs_to :user
  validates_presence_of :user_id, :scope=>:document_id
  
end