namespace :blacklight do

  # task to clean out old, unsaved searches
  # rake blacklight:delete_old_searches[days_old]
  # example cron entry to delete searches older than 7 days at 2:00 AM every day: 
  # 0 2 * * * cd /path/to/your/app && /path/to/rake blacklight:delete_old_searches[7] RAILS_ENV=your_env
  task :delete_old_searches, :days_old, :needs => :environment do |t, args|
    Search.delete_old_searches(args[:days_old].to_i)
  end

end