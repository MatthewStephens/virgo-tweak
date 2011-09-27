# Settings specified here will take precedence over those in config/environment.rb

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.cache_template_loading            = true

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
#config.action_mailer.delivery_method = :test
# temporarily changing to test mail
config.action_mailer.delivery_method = :smtp

# route  mail through smtp.mail
# temporarily changing to test mail
#config.action_mailer.smtp_settings = {:address => 'smtp.mail.virginia.edu'}
config.action_mailer.smtp_settings = {
   :address => 'smtp.mail.virginia.edu',
   :domain => 'virgobetatest.lib.virginia.edu'
}

# API KEYS FOR UVA #
Blacklight::LibraryThing.api_key = '73d3097200e332adbe542b6eb7fdb162'
Blacklight::LastFM.api_key = 'b25b959554ed76058ac220b7b2e0a026'

FEEDBACK_NOTIFICATION_RECIPIENTS = %W(virgo-feedback@virginia.edu)
FEEDBACK_NOTIFICATION_FROM = 'mpc3c@virginia.edu'
FEEDBACK_NOTIFICATION_SUBJECT = 'VIRGOBeta Feedback (virgobetatest)'

# Use SQL instead of Active Record's schema dumper when creating the test database.
# This is necessary if your schema can't be completely dumped by the schema dumper,
# like if you have constraints or database-specific column types
# config.active_record.schema_format = :sql