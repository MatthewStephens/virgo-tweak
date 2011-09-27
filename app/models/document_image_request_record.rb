# a record of when a request was made for a document whose image we don't have on file
class DocumentImageRequestRecord < ActiveRecord::Base
  
  # delete old requests
  def self.delete_old_requests(days_old)
    raise ArgumentError.new('days_old is expected to be a number') unless days_old.is_a?(Numeric)
    raise ArgumentError.new('days_old is expected to be greater than 0') if days_old <= 0
    self.destroy_all(['requested_at < ?', Date.today - days_old])
  end

end