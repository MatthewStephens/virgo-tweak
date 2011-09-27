# for sending feedback
class Notifier < ActionMailer::Base
  
  def feedback(form_params)
    raise 'FEEDBACK_NOTIFICATION_RECIPIENTS is not defined. This should be an array of email recipients' unless defined?(FEEDBACK_NOTIFICATION_RECIPIENTS)
    # Email header info MUST be added here
    recipients FEEDBACK_NOTIFICATION_RECIPIENTS # set in config/environment.rb
    from FEEDBACK_NOTIFICATION_FROM
    subject FEEDBACK_NOTIFICATION_SUBJECT
    body <<-EOF
VIRGO USER FEEDBACK

SENDER NAME: #{form_params[:name]}

SENDER EMAIL: #{form_params[:email]}

SENDER MESSAGE:
#{form_params[:message]}

REFERING URL:
#{form_params[:referer]}
EOF
  end
  
end
