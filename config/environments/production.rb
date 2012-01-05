Virgo::Application.configure do

  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
  
  config.middleware.use ExceptionNotifier,
    :email_prefix => "[virgo] ",
    :sender_address => %{"Error" <mpc3c@virginia.edu>},
    :exception_recipients => %w{mpc3c@virginia.edu}
    
  # API KEYS FOR UVA #
  LIBRARY_THING_API_KEY = '73d3097200e332adbe542b6eb7fdb162'
  LAST_FM_API_KEY = 'b25b959554ed76058ac220b7b2e0a026'

  FEEDBACK_NOTIFICATION_RECIPIENTS = %W(virgo-feedback@virginia.edu)
  FEEDBACK_NOTIFICATION_FROM = 'virgo-feedback@virginia.edu'
  FEEDBACK_NOTIFICATION_SUBJECT = 'Virgo Feedback (production)'

  FIREHOSE_URL = "http://firehose.lib.virginia.edu:8080/firehose2"
  PRIMO_URL = "http://primo4.hosted.exlibrisgroup.com:1701/PrimoWebServices/xservice/search/brief?institution=UVA&onCampus=true"
  
  FEDORA_REST_URL = 'http://fedora.lib.virginia.edu'
  FEDORA_USERNAME = 'fedoraAdmin'
  FEDORA_PASSWORD = 'aro2def'

end


