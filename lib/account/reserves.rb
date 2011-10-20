require 'happymapper'
require 'open-uri'

module Account::Reserves
    
  def get_reserves(computing_id)
    uri = URI.parse("#{FIREHOSE_URL}/users/#{computing_id}/reserves")
    begin
      str = uri.read
      return Account::Common::User.parse(str, :single=>true, :use_default_namespace => true)
    rescue
      return
    end
  end
  
  def get_reserves_for_course(computing_id, key)
    reserves = get_reserves(computing_id)
    # pick out only the courses that match
    courses = reserves.courses.select{ |course| course.key = key}
    reserves.courses = courses
    reserves
  end
  
end