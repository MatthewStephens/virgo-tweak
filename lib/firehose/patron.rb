require 'happymapper'
require 'open-uri'

module Firehose
  
  module Patron
  
    def get_patron(computing_id)
      uri = URI.parse("#{FIREHOSE_URL}/users/#{computing_id.parameterize}")
      begin
        str = uri.read
        return Firehose::Common::User.parse(str, :single=>true, :use_default_namespace => true)
      rescue
        return
      end
    end

    def check_pin(patron, pin)
      patron.pin == pin
    end

  end

end
