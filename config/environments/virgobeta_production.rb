# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

config.after_initialize do
  ExceptionNotification::Notifier.exception_recipients = %w(mpc3c@virginia.edu)
  ExceptionNotification::Notifier.sender_address = %("Error" <mpc3c@virginia.edu>)
  ExceptionNotification::Notifier.email_prefix = "[virgobeta] "
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = { 
    :address => 'smtp.mail.virginia.edu',
    :domain => 'virgobeta.lib.virginia.edu'
  }
end

# API KEYS FOR UVA #
LIBRARY_THING_API_KEY = '73d3097200e332adbe542b6eb7fdb162'
LAST_FM_API_KEY = 'b25b959554ed76058ac220b7b2e0a026'

FEEDBACK_NOTIFICATION_RECIPIENTS = %W(virgo-feedback@virginia.edu)
FEEDBACK_NOTIFICATION_FROM = 'virgo-feedback@virginia.edu'
FEEDBACK_NOTIFICATION_SUBJECT = 'Virgo Feedback (production)'

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Enable threaded mode
# config.threadsafe!

FIREHOSE_URL = "http://firehose.lib.virginia.edu:8080/firehose2"
PRIMO_URL = "http://primo4.hosted.exlibrisgroup.com:1701/PrimoWebServices/xservice/search/brief?institution=UVA&onCampus=true"