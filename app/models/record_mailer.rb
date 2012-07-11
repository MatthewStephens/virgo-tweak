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
    @documents = documents
    @articles = articles
    @host = host
    @message = message
    full_record == "true" ? @full_record = true : @full_record = false
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
  
  def email_reserves(documents, to, instructor_id, instructor_name, requestor_name, requestor_uvaid, course_id, semester, location, loan, full_record, from_host, host)
    documents.each do |document|
      document.availability = Firehose::Availability.find(document)
    end
    if documents.size == 1 
      subject ="Reserve Item: #{documents.first.value_for :title_display}"
    else
      subject = "Reserve Items"
    end
    from =  "no-reply@" + from_host
   
    @documents = documents
    @host = host
    @instructor_id = "Instructor Computing ID: " + instructor_id
    @instructor_name = "Instructor Name: " + instructor_name
    @requestor_name = "Requestor Name: " + requestor_name
    @requestor_uvaid = "Requstor University ID: " + requestor_uvaid
    @course_id = "Course ID: " + course_id
    @semester = "Semester : " + semester
    @reserve_library = {}
    coordinator = []
    location.each do |item_key, library| 
      case library.to_s
        when "Astronomy", "Brown Science & Engineering", "Chemistry", "Math"
          coordinator << "," + RESERVE_COORDINATOR_SCI
        when "Biology/Psychology"
          coordinator << "," + RESERVE_COORDINATOR_BIO
        when "Clemons"
          coordinator << "," + RESERVE_COORDINATOR_CLEMONS
        when "Education"
          coordinator << "," + RESERVE_COORDINATOR_ED
        when "Fine Arts"
          coordinator << "," + RESERVE_COORDINATOR_FA
        when "Law"
          coordinator << "," + RESERVE_COORDINATOR_LAW
        when "Music"
          coordinator << "," + RESERVE_COORDINATOR_MUSIC
        when "Physics"
          coordinator << "," + RESERVE_COORDINATOR_PHYSICS
      end
      @reserve_library[item_key] = "Reserve Library: " + library.to_s    
    end
    
    @loan_period ={}
    loan.each do |item_key, loan|
      @loan_period[item_key] = "Loan Period: " + loan.to_s 
    end
  
  
    email_list=[]
    email_list << to + coordinator.uniq.to_s 
    full_record == "true" ? @full_record = true : @full_record = false
    mail(:to =>email_list, :subject => subject, :from => from)
  end    
end