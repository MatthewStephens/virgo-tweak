require_dependency 'vendor/plugins/blacklight/app/models/search.rb'

# overriding from Blacklight plugin so to include delete_old_searches.  Remove when added to plugin
class Search < ActiveRecord::Base
  
# delete old, unsaved searches
  def self.delete_old_searches(days_old)
    raise ArgumentError.new('days_old is expected to be a number') unless days_old.is_a?(Numeric)
    raise ArgumentError.new('days_old is expected to be greater than 0') if days_old <= 0
    self.destroy_all(['created_at < ? AND user_id IS NULL', Date.today - days_old])
  end
  
end