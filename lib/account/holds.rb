require 'happymapper'
require 'open-uri'

module Account::Holds


  def get_holds(computing_id)
    uri = URI.parse("#{FIREHOSE_URL}/firehose2/users/#{computing_id}/holds")
    begin
      str = uri.read
      return Account::Common::User.parse(str, :single=>true, :use_default_namespace => true)
    rescue
      return
    end
  end
  
  def place_hold(computing_id, ckey, library_id, call_number="")
    ckey = Account::Common.ckey_converter(ckey)
    params = { "computingId" => computing_id,
               "catalogId" => ckey,
               "pickupLibraryId" => library_id }
    params["callNumber"] = call_number unless call_number.blank?
    res = Net::HTTP.post_form(URI.parse("#{FIREHOSE_URL}/firehose2/request/hold"), params)
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      return
    else
      error = Account::Common::FirehoseViolation.parse(res.body, :single => true, :use_default_namespace => true)
      raise Account::Common::HoldError.new(error.message)
    end
  end
    
end
