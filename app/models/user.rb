class User < ActiveRecord::Base                                    
  include Blacklight::User
  acts_as_authentic                               
end