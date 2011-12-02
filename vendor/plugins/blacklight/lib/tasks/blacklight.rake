namespace :blacklight do
  
  desc "Copies Blacklight's default images, css and javascript into your apps public/plugin_assets/blacklight directory."
  task :copy_assets do
    bl_root = File.join(File.dirname(__FILE__), '..', '..')
    from = File.join(bl_root, 'assets', '*')
    to = File.join(Rails.root, 'public', 'plugin_assets', 'blacklight')
    mkdir_p to
    cp_r Dir[from], to
  end
  
  # task to clean out old, unsaved searches
  # rake blacklight:delete_old_searches[days_old]
  # example cron entry to delete searches older than 7 days at 2:00 AM every day: 
  # 0 2 * * * cd /path/to/your/app && /path/to/rake blacklight:delete_old_searches[7] RAILS_ENV=your_env
  desc "Removes entries in the searches table that are older than the number of days given."
  task :delete_old_searches, :days_old, :needs => :environment do |t, args|
    Search.delete_old_searches(args[:days_old].to_i)
  end

end

# Rake tasks for Blacklight plugin

# if you would like to see solr startup messages on STDERR
# when starting solr test server during functional tests use:
# 
#    rake SOLR_CONSOLE=true
require File.expand_path(File.dirname(__FILE__) + '/../../spec/lib/test_solr_server.rb')


SOLR_PARAMS = {
  :quiet => ENV['SOLR_CONSOLE'] ? false : true,
  :jetty_home => ENV['SOLR_JETTY_HOME'] || File.expand_path('./jetty'),
  :jetty_port => ENV['SOLR_JETTY_PORT'] || 8888,
  :solr_home => ENV['SOLR_HOME'] || File.expand_path('./jetty/solr')
}

namespace :solr do
  
  desc "Calls RSpec Examples wrapped in the test instance of Solr"
  task :spec do
    # wrap tests with a test-specific Solr server
    error = TestSolrServer.wrap(SOLR_PARAMS) do
      rm_f "coverage.data"
      Rake::Task["rake:spec"].invoke 
      #puts `ps aux | grep start.jar` 
    end
    raise "test failures: #{error}" if error
  end

  desc "Calls Cucumber Features wrapped in the test instance of Solr"
  task :features do
    # wrap tests with a test-specific Solr server
    error = TestSolrServer.wrap(SOLR_PARAMS) do
      Rake::Task["cucumber:all"].invoke 
      #puts `ps aux | grep start.jar` 
    end
    raise "test failures: #{error}" if error
  end
  
  desc "Runs all features and specs"
  task :all do
    error = TestSolrServer.wrap(SOLR_PARAMS) do
      Rake::Task["rake:spec"].invoke
      Rake::Task["cucumber:all"].invoke
    end
    raise "test failures: #{error}" if error
  end
  
end
