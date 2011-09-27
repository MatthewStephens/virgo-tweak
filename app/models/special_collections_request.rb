class SpecialCollectionsRequest < ActiveRecord::Base
  has_many :special_collections_request_items, :dependent => :destroy 
  validates_presence_of :user_id
  before_update :set_processed_at 
  
  attr_accessor :document
  
  # locations and call numbers are submitted via a web form as a hash keyed by location
  # example:  
  # { "SC-STKS"=>{"X030761746"=>["PS3623 .R539 S48 2010"]}, 
  #   "SC-BARR-X"=>{"X004958786"=>["MSS 6251 -- 6251-bn"], "X004958758"=>["MSS 6251 -- 6251-bn Box 2"]} }
  # build these out into request items and add those items to this request object
  def build(locations_with_call_numbers)
    return if locations_with_call_numbers.nil? or locations_with_call_numbers.empty?
    locations_with_call_numbers.each { |location, barcode_set|
      barcode_set.each do |barcode, call_numbers|
        call_numbers.each do |call_number|
          item = SpecialCollectionsRequestItem.new(:location => location, :call_number => call_number, :barcode => barcode)
          self.special_collections_request_items << item
        end
      end
    }
  end
  
  private
    def set_processed_at
      self.processed_at = Time.now
    end
  
end
