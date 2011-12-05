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

config.action_mailer.delivery_method = :smtp
# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = true


config.after_initialize do
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = { 
    :address => 'smtp.mail.virginia.edu',
    :domain => 'd-128-197-140.bootp.Virginia.EDU'
  }
  ActionView::Base.field_error_proc = Proc.new { |html_tag, instance|
  "<span class=\"fieldWithErrors\">#{html_tag}</span>" }
  ExceptionNotification::Notifier.exception_recipients = %w(mpc3c@virginia.edu)  
  ExceptionNotification::Notifier.sender_address = %("Error" <mpc3c@virginia.edu>)
  ExceptionNotification::Notifier.email_prefix = "[development] "
end

# API KEYS FOR UVA #
LIBRARY_THING_API_KEY = '73d3097200e332adbe542b6eb7fdb162'
LAST_FM_API_KEY = 'b25b959554ed76058ac220b7b2e0a026'


FEEDBACK_NOTIFICATION_RECIPIENTS = %W(mpc3c@virginia.edu)
FEEDBACK_NOTIFICATION_FROM = 'eos8d@virginia.edu'
FEEDBACK_NOTIFICATION_SUBJECT = 'VIRGOBeta Feedback (development)'

FEDORA_REST_URL = 'http://localhost:8080/fedora'
Fedora_username = 'fedoraAdmin'
Fedora_password = 'fedoraAdmin'

FIREHOSE_URL = "http://webservice.lib.virginia.edu:8080/firehose2"
PRIMO_URL = "http://primo4.hosted.exlibrisgroup.com:1701/PrimoWebServices/xservice/search/brief?institution=UVA&onCampus=true"