require 'happymapper'
require 'open-uri'

module Firehose
  
  module Patron
  
    def get_patron(computing_id)
      uri = URI.parse("#{FIREHOSE_URL}/users/#{computing_id}")
      begin
        str = uri.read
        return Firehose::Common::User.parse(str, :single=>true, :use_default_namespace => true)
      rescue
        return
      end
    end

  end

end
