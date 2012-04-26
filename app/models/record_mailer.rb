require "#{Blacklight.models_dir}/record_mailer"

class RecordMailer < ActionMailer::Base
  
  helper :application
  
  # overriding from Blacklight plugin so that we can add availability data and allow for multiple docs
  def email_record(documents, articles, to, message, full_record, from_host, host)
    documents.each do |document|
      document.availability = Firehose::Availability.find(document)
    end
    if documents.size == 1 and articles.size == 0
      subject ="Item Record: #{documents.first.value_for :title_display}"
    else
      subject = "Item records"
    end
    from =  "no-reply@" + from_host
    full_record == "true" ? @full_record = true : @full_record = false
    @documents = documents
    @articles = articles
    @host = host
    @message = message
    @full_record = full_record
    mail(:to => to, :subject => subject, :from => from)
  end  
  
  # overriding from Blacklight plugin so that we can add multiple docs
  def sms_record(documents, articles, to, carrier, from_host, host)
    if sms_mapping[carrier]
      to = "#{to}@#{sms_mapping[carrier]}"
    end
    from = "no-reply@" + from_host
    @documents = documents
    @articles = articles
    @host = host
    mail(:to => to, :subject => subject, :from => from)
  end
  
end