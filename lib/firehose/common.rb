module Firehose::Common
  
  class Library
    include HappyMapper
    attribute :id, String
    attribute :code, String
    element :name, String
    element :deliverable, Boolean
    attr_accessor :summary_locations
    def initialize 
      @summary_locations = []
    end
    def deliverable?
      @deliverable
    end
    def is_sas?
      @code == "AT-SEA"
    end
    def is_special_collections?
      @code == "SPEC-COLL"
    end
  end
  
  class LibraryList
    include HappyMapper
    tag 'libraries'
    has_many :libraries, Library, :tag => 'library'
    def names_and_ids
      @libraries = @libraries.sort! {|a,b| a.name <=> b.name }
      map = []
      @libraries.each do |library|
        map << [library.name, library.id] if library.deliverable?
      end
      map
    end
  end
  
  class Summary
    attr_accessor :text
    attr_accessor :note
    def initialize(text, note)
      text.chomp!(",")
      @text, @note = text, note
    end
  end
  
  class HomeLocation
    include HappyMapper
    tag 'homeLocation'
    attribute :id, String
    attribute :code, String
    element :name, String
    attr_accessor :summaries
    def initialize
      @summaries = []
    end
    def suppressed?
      return false if @code.blank?
      if code =~ /BARRED/i
        return true
      end
      false
    end
  end
  
  class CurrentLocation
    include HappyMapper
    tag 'currentLocation'
    attribute :id, String
    attribute :code, String
    element :name, String
    def suppressed?
      return false if @code.blank?
      if code =~ /BARRED/i
        return true
      end
      false
    end
  end
    
  class Copy
    include HappyMapper
    tag 'copy'
    attribute :copy_number, Integer, :tag => "copyNumber"
    attribute :shadowed, Boolean
    attribute :barcode, String, :tag => "barCode"
    attribute :current_periodical, Boolean, :tag => "currentPeriodical"
    element :last_checkout, Date, :tag => "lastCheckout"
    element :circulate, String
    has_one :current_location, CurrentLocation, :tag => "currentLocation"
    has_one :home_location, HomeLocation, :tag => "homeLocation"
    def shadowed?
      @shadowed
    end
    def current_periodical?
      @current_periodical
    end
    def last_checkout_f
      Firehose::Common.date_string(@last_checkout)
    end
    def available?
      @current_location.code !~ /CHECKEDOUT|MISSING|INTRANSIT|GBP|ON-ORDER|CIRC-HOLD|LAW-HOLD|SERV-HOLD|IN-PROCESS|BINDERY|PRESERVATN|CATALOGING/i
    end
    def reserve?
      @current_location.code =~ /RESV|RESERVE|RSRV/i
    end
    def pending?
      @current_location.code =~ /ON-ORDER|IN-PROCESS/
    end
    def in_transit?
      @current_location.code =~ /INTRANSIT/
    end
    def circulates?
      @circulate =~ /Y|M/
    end
    def special_collections_display?
      @current_location.code =~ /DEC-IND-RM|SC-IN-PROC/
    end
    def map(holding)
      Map.find_best_map(holding, self) if self.available?
    end
  end  
    
  class Holding
    include HappyMapper
    tag 'holding'
    has_many :copies, Copy, :tag => "copy"
    has_one :library, Library
    attribute :call_sequence, Integer, :tag => "callSequence"
    attribute :call_number, String, :tag => "callNumber"
    attribute :holdable, Boolean
    attribute :shadowed, Boolean
    element :shelving_key, String, :tag => "shelvingKey"
    
    def initialize
      @groups = []
    end
    def shadowed?
      return @shadowed
    end
  end  
  
  class Holdability
    include HappyMapper
    attribute :value, String
    element :message, String
  end
  
  class PickupLibrary
    include HappyMapper
    tag 'pickupLibrary'
    attribute :id, String
    element :code, String
    element :name, String
  end
  
  class CatalogItem
    include HappyMapper
    tag 'catalogItem'
    attribute :key, String
    element :authors, String
    element :isbn, String
    element :publish_date, String
    element :status, Integer
    element :subtitle, String, :tag => "subTitle"
    element :title, String
    has_many :holdings, Holding
    has_one :holdability, Holdability, :tag => "canHold"
  end
  
  class Hold
    include HappyMapper
    tag 'hold'
    attribute :type, String
    attribute :level, String
    attribute :active, Boolean
    has_one :catalog_item, CatalogItem, :tag => "catalogItem"
    element :date_notified, Date, :tag => "dateNotified"
    element :date_placed, Date, :tag => "datePlaced"
    element :date_recalled, Date, :tag => "dateRecalled"
    element :inactive_reason, String, :tag => "inactiveReason"
    element :key, String
    has_one :pickup_library, PickupLibrary, :tag => "pickupLibrary"
    element :priority, Integer
    
    def date_notified_f
      Firehose::Common.date_string(@date_notified)
    end
    def date_placed_f
      Firehose::Common.date_string(@date_placed)
    end
    def date_recalled_f
      Firehose::Common.date_string(@date_recalled)
    end
  end
  
  class Reserve
    include HappyMapper
    tag "reserve"
    attribute :key, String
    element :active, String
    element :automatically_select_copies, Boolean, :tag => "automaticallySelectCopies"
    has_one :catalog_item, CatalogItem, :tag => "catalogItem"
    element :keep_copies_at_desk, Boolean, :tag => "keepCopiesAtDesk"
    element :number_of_reserves, Integer, :tag => "numberOfReserves"
    element :status, String
  end
  
  class Course
    include HappyMapper
    tag 'course'
    attribute :key, String
    element :code, String
    element :name, String
    element :number_of_reserves, Integer, :tag => "numberOfReserves"
    element :number_of_students, Integer, :tag => "numberOfStudents"
    has_many :reserves, Reserve, :tag => "reserve"
    element :terms_offered, Integer, :tag => "termsOffered"
    def sorted_reserves
      @reserves.sort_by { |a| a.catalog_item.title }
    end
  end
  
  class Renewability
    include HappyMapper
    tag 'canRenew'
    attribute :value, String
    attribute :code, String
    element :message, String
  end
  
  class Checkout
    include HappyMapper
    tag 'checkout'
    has_one :catalog_item, CatalogItem, :tag => "catalogItem"
    element :circulation_rule, Integer, :tag => "circulationRule"
    element :date_charged, Date, :tag => "dateCharged"
    element :date_due, Date, :tag => "dateDue"
    element :date_recalled, Date, :tag => "dateRecalled"
    element :date_renewed, Date, :tag => "dateRenewed"
    element :key, String
    element :number_overdue_notices, Integer, :tag => "numberOverdueNotices"
    element :number_recall_notices, Integer, :tag => "numberRecallNotices"
    element :number_renewals, Integer, :tag => "numberRenewals"
    element :status, Integer
    element :overdue, Boolean, :tag => "isOverdue"
    has_one :renewability, Renewability, :tag => "canRenew"
    def renewable?
      @renewability.value == "yes" ? true : false
    end
    def date_charged_f
      Firehose::Common.date_string(@date_charged)
    end
    def date_due_f
      Firehose::Common.date_string(@date_due)
    end
    def date_recalled_f
      Firehose::Common.date_string(@date_recalled)
    end
    def date_renewed_f
      Firehose::Common.date_string(@date_renewed)
    end
    def overdue?
      @overdue
    end
    def recalled?
      date_recalled_f == "Never" ? false : true
    end
  end
  
  class User
    include HappyMapper
    tag 'user'
    attribute :key, String
    attribute :sirsi_id, String, :tag => "sirsiId"
    attribute :computing_id, String, :tag => "computingId"
    element :barred, Boolean
    element :bursarred, Boolean
    element :delinquent, Boolean
    element :display_name, String, :tag => "displayName"
    element :email, String
    element :library_group, Integer, :tag => "libraryGroup"
    element :organizational_unit, String, :tag => "organizationalUnit"
    element :preferred_language, Integer, :tag => "preferredlanguage"
    element :profile, String
    element :checkout_count, Integer, :tag => "totalCheckouts"
    element :hold_count, Integer, :tag => "totalHolds"
    element :overdue_count, Integer, :tag => "totalOverdue"
    element :reserve_count, Integer, :tag => "totalReserves"
    element :recalled_count, Integer, :tag => "totalRecalls"
    element :physical_delivery, String, :tag => "physicalDelivery"
    element :description, String
    element :first_name, String, :tag => "givenName"
    element :middle_name, String, :tag => "initials"
    element :last_name, String, :tag => "surName"
    element :physical_delivery, String, :tag => "physicalDelivery"
    element :status_id, Integer, :tag => "statusId"
    element :telephone, String
    element :title, String
    element :pin, String
    has_many :groups, String, :tag => "group"
    has_many :holds, Hold, :tag =>"hold"    
    def sorted_holds
      @holds.sort_by { |a| [a.date_placed, a.catalog_item.title] }
    end
    has_many :courses, Course, :tag =>"course"
    element :status_id, Integer, :tag => "statusId"
    def sorted_courses
      @courses.sort_by { |a| a.code }
    end
    has_many :checkouts, Checkout, :tag =>"checkout"
    def sorted_checkouts
      @checkouts.sort_by { |a| [ a.date_charged, a.catalog_item.title] }
    end
    def faculty?
      return false if @profile.blank?
      @profile.downcase == "faculty"
    end
    def continuing_education?
      return false if @description.blank?
      @description.downcase == "continuing education"
    end
    def undergraduate?
      return false if @profile.blank?
      @profile.downcase == "undergraduate"
    end
    def virginia_borrower?
      # RESEARCHERS don't have a profile, but they shouldn't have a U.Va. computing id
      if @profile.blank?
        return false if @profile =~ /^[A-Z]{2,3}$/i
        return false if @profile =~ /^[A-Z]{2,3}[0-9][A-Z]{1,2}$/i
        return true
      end
      @profile =~ /^Virginia Borrower|Other VA Faculty|Alumni$/i
    end
    def barred?
      @barred
    end
    def can_make_reserves?
      return false if undergraduate? or virginia_borrower?
      return true
    end
  end
  
  class FirehoseViolation
    include HappyMapper
    tag 'FirehoseViolation'
    element :code, String
    element :message, String
  end
  
  class HoldError < RuntimeError; end  
  class RenewError < RuntimeError; end
        
  def self.ckey_converter(ckey)
    ckey[1, ckey.length - 1]
  end
    
  def self.date_string(date_string)
    date_string = date_string.strftime("%b %d, %Y")
    date_string == 'Jan 01, 1900' ? 'Never' : date_string
  end
  
end