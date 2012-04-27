# for sending feedback
class Notifier < ActionMailer::Base
  
  def feedback(name, email, message, referer)
    raise 'FEEDBACK_NOTIFICATION_RECIPIENTS is not defined. This should be an array of email recipients' unless defined?(FEEDBACK_NOTIFICATION_RECIPIENTS)
    # Email header info MUST be added here
    @recipients = FEEDBACK_NOTIFICATION_RECIPIENTS # set in config/environment.rb
    @from = FEEDBACK_NOTIFICATION_FROM
    @subject = FEEDBACK_NOTIFICATION_SUBJECT
    @body = "
VIRGO USER FEEDBACK

SENDER NAME: #{name}

SENDER EMAIL: #{email}

SENDER MESSAGE:
#{message}

REFERING URL:
#{referer}
"
  mail(:to => @recipients, :subject => @subject, :from => @from, :body => @body)
  end
  
end
