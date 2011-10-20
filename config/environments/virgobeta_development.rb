# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = false
config.action_view.debug_rjs                         = false
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = true

config.after_initialize do
  ExceptionNotification::Notifier.exception_recipients = %w(mpc3c@virginia.edu)
  ExceptionNotification::Notifier.sender_address = %("Error" <mpc3c@virginia.edu>)
  ExceptionNotification::Notifier.email_prefix = "[virgobetadev] "
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = { 
    :address => 'smtp.mail.virginia.edu',
    :domain => 'virgobetadev.lib.virginia.edu'
  }
end

# API KEYS FOR UVA #
Blacklight::LibraryThing.api_key = '73d3097200e332adbe542b6eb7fdb162'
Blacklight::LastFM.api_key = 'b25b959554ed76058ac220b7b2e0a026'

FEEDBACK_NOTIFICATION_RECIPIENTS = %W(virgo-feedback@virginia.edu)
FEEDBACK_NOTIFICATION_FROM = 'virgo-feedback@virginia.edu'
FEEDBACK_NOTIFICATION_SUBJECT = 'Virgo Feedback (virgobetadev)'

FIREHOSE_URL = "http://webservice.lib.virginia.edu:8080/firehose2"
PRIMO_URL = "http://primo4.hosted.exlibrisgroup.com:1701/PrimoWebServices/xservice/search/brief?institution=UVA&onCampus=true"