require_dependency 'vendor/plugins/blacklight/app/models/record_mailer.rb'
class RecordMailer < ActionMailer::Base
  
  helper :application
  
  # overriding from Blacklight plugin so that we can add availability data and allow for multiple docs
  def email_record(documents, articles, details, from_host, host)
    documents.each do |document|
      document.availability = Account::Availability.find(document)
    end
    recipients details[:to]
    if documents.size == 1 and articles.size == 0
      subject "Item Record: #{documents.first.value_for :title_display}"
    else
      subject "Item records"
    end
    from "no-reply@" << from_host
    details[:full_record] == "true" ? full_record = true : full_record = false
    body :documents => documents, :articles => articles, :host => host, :message => details[:message], :full_record => full_record
  end  
  
  # overriding from Blacklight plugin so that we can add multiple docs
  def sms_record(documents, articles, details, from_host, host)
    if sms_mapping[details[:carrier]]
      to = "#{details[:to]}@#{sms_mapping[details[:carrier]]}"
    end
    recipients to
    from "no-reply@" << from_host
    body :documents => documents, :articles => articles, :host => host
  end
  
end