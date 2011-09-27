require 'net/ldap'

module UVA

  module Ldap
    
    def full_name
      ldap = Net::LDAP.new(:host => 'ldap.virginia.edu', :base => 'o=University of Virginia,c=US')
      filter = Net::LDAP::Filter.eq( "userid", self.user_id)
      attrs = []
      vals = {}
      ldap.search( :base => "o=University of Virginia,c=US", :attributes => attrs, :filter => filter, :return_result => true ) do |entry|
        entry.attribute_names.each do |n|
          vals[n] = entry[n]
        end
      end
      (vals[:givenname][0] + " " + vals[:sn][0]) rescue ''
    end

  end
end
