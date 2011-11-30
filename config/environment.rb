# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.11' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), '../vendor/plugins/blacklight/vendor/plugins/engines/boot')


ENV['RECAPTCHA_PUBLIC_KEY']  = '6Ld3LwkAAAAAAJn9mbxRLerYjUVZFHdjFsYLKsCp'
ENV['RECAPTCHA_PRIVATE_KEY'] = '6Ld3LwkAAAAAAMVxlk5cAzoBCVDp-eQxidkffNFd'

FEDORA_REST_URL = 'http://fedora.lib.virginia.edu'
Fedora_username = 'fedoraAdmin'
Fedora_password = 'aro2def'

Rails::Initializer.run do |config|
  config.plugin_paths += ["#{RAILS_ROOT}/vendor/plugins/blacklight/vendor/plugins"]
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
  config.plugins = [:all]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.active_record.default_timezone = :local
  
  #config.gem 'rails', :version => '2.3.5'
  #config.gem 'zoom', :version => '0.4.1'
  #config.gem 'nokogiri', :version => '1.3.3'
  #config.gem 'unicode', :version => '0.3.1'
  #config.gem 'prawn', :version => '0.8.4'
  #config.gem 'prawn-core', :version => '0.8.4'
  #config.gem 'prawn-layout', :version => '0.8.4'
  #config.gem 'prawn-security', :version => '0.8.4'
  
  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de

end