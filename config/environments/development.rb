Virgo::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.perform_deliveries = false
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # API KEYS FOR UVA #
  LIBRARY_THING_API_KEY = '73d3097200e332adbe542b6eb7fdb162'
  LAST_FM_API_KEY = 'b25b959554ed76058ac220b7b2e0a026'

  FEEDBACK_NOTIFICATION_RECIPIENTS = %W(mpc3c@virginia.edu)
  FEEDBACK_NOTIFICATION_FROM = 'virgo-feedback@virginia.edu'
  FEEDBACK_NOTIFICATION_SUBJECT = 'Virgo Feedback (dev)'

  FIREHOSE_URL = "http://webservice.lib.virginia.edu:8080/firehose2"
  PRIMO_URL = "http://primo4.hosted.exlibrisgroup.com:1701/PrimoWebServices/xservice/search/brief?institution=UVA&onCampus=true"
  
  FEDORA_REST_URL = 'http://fedora.lib.virginia.edu'
  FEDORA_USERNAME = 'fedoraAdmin'
  FEDORA_PASSWORD = 'aro2def'

end


