# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

config.after_initialize do
  ExceptionNotifier.exception_recipients = %W(eos8d@virginia.edu mpc3c@virginia.edu)
  ExceptionNotifier.sender_address = %("Error" <eos8d@virginia.edu>)
  ExceptionNotifier.email_prefix = "[Blacklight] "
  ActionMailer::Base.delivery_method = :sendmail
end

# API KEYS FOR UVA #
Blacklight::LibraryThing.api_key = '73d3097200e332adbe542b6eb7fdb162'
Blacklight::LastFM.api_key = 'b25b959554ed76058ac220b7b2e0a026'

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

# route mail through smtp.mail
config.action_mailer.smtp_settings = {:address => 'smtp.mail.virginia.edu'}

# Enable threaded mode
# config.threadsafe!