require 'lib/cover_image/loader'

namespace :cover_images do
  
  task :harvest, :do_solr_updates, :date_string, :needs => :environment do |t, args|
     args.with_defaults(:do_solr_updates => false, :date_string => Date.today.strftime('%Y%m%d'))
     CoverImage::Loader.new(args[:do_solr_updates], args[:date_string])
   end
   
  # task to clean out old image requests
  # rake cover_images:delete_old_requests[days_old]
  # example cron entry to delete requests older than 1 days at 2:00 AM every day: 
  # 0 2 * * * cd /path/to/your/app && /path/to/rake cover_images:delete_old_requests[1] RAILS_ENV=your_env
  task :delete_old_requests, :days_old, :needs => :environment do |t, args|
    DocumentImageRequestRecord.delete_old_requests(args[:days_old].to_i)
  end

 
end