require 'happymapper'
require 'open-uri'

module Firehose::Checkouts  

  def get_checkouts(computing_id)
    uri = URI.parse("#{FIREHOSE_URL}/users/#{computing_id}/checkouts")
    begin
      str = uri.read
      return Firehose::Common::User.parse(str, :single=>true, :use_default_namespace => true)
    rescue
      return
    end
  end

  def do_renew_all(computing_id)
    params = { "computingId" => computing_id }
    res = Net::HTTP.post_form(URI.parse("#{FIREHOSE_URL}/request/renewAll"), params)
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      return
    else
      error = Firehose::Common::FirehoseViolation.parse(res.body, :single => true, :use_default_namespace => true)
      raise Firehose::Common::RenewError.new(error.message)
    end
  end  
  
  def do_renew(computing_id, checkout_key=nil)
    params = { "computingId" => computing_id, "checkoutKey" => checkout_key }
    res = Net::HTTP.post_form(URI.parse("#{FIREHOSE_URL}/request/renew"), params)
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      return
    else
      error = Firehose::Common::FirehoseViolation.parse(res.body, :single => true, :use_default_namespace => true)
      raise Firehose::Common::RenewError.new(error.message)
    end
  end
  
end