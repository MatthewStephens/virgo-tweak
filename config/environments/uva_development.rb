# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

# route	 mail through smtp.mail
config.action_mailer.smtp_settings = {:address => 'smtp.mail.virginia.edu'}

config.after_initialize do
  ExceptionNotifier.exception_recipients = %W(mpc3c@virginia.edu)
  ExceptionNotifier.sender_address = %("Error" <eos8d@virginia.edu>)
  ExceptionNotifier.email_prefix = "[Blacklight] "
  ActionMailer::Base.delivery_method = :sendmail
end

# API KEYS FOR UVA #
Blacklight::LibraryThing.api_key = '73d3097200e332adbe542b6eb7fdb162'
Blacklight::LastFM.api_key = 'b25b959554ed76058ac220b7b2e0a026'


FEEDBACK_NOTIFICATION_RECIPIENTS = %W(lib-bug@virginia.edu)
FEEDBACK_NOTIFICATION_FROM = 'eos8d@virginia.edu'
FEEDBACK_NOTIFICATION_SUBJECT = 'VIRGOBeta Feedback (uva_development)'

