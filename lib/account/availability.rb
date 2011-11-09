require 'happymapper'
require 'open-uri'

class Account::Availability
  
  attr_accessor :document
  attr_accessor :_raw_xml
  attr_accessor :_catalog_item
  attr_accessor :_summary_libraries
  
  def initialize(document, catalog_item, raw_xml)
    @document, @_catalog_item, @_raw_xml = document, catalog_item, raw_xml
    @_summary_libraries = []
    set_summary_holdings
    weed_holdings
    set_maps
  end
  
  def to_xml
    return @_raw_xml
  end
  
  def might_be_holdable?
    return true if ["yes", "maybe"].include?(@_catalog_item.holdability.value)
    return false
  end
  
  def all_are_pending?
    not_pending = @_catalog_item.holding.copies.select { |copy| !copy.pending? } || []
    not_pending.size == 0 ? true : false
  end
  

  def holdability_error
    return @_catalog_item.holdability.message
  end

  def has_holdable_holding?(call_number)
    selected = @_catalog_item.holdings.select { |holding| holding.holdable == true and holding.call_number == call_number }
    selected.size > 0
  end

  def holdable_call_numbers
    selected = @_catalog_item.holdings.select { |holding| holding.holdable == true }
    selected.collect { |holding| holding.call_number }
  end
  
  def leoable?
     @_catalog_item.holdings.each do |holding|
       holding.copies.each do |copy|
         return true if holding.library.code !~ /^BLANDY|MT-LAKE|AT-SEA/
      end
    end
    false
  end
  
  # determines if the given user has this ckey and call number checked out
  def user_has_checked_out?(user, call_number="")
    call_number = holdable_call_numbers[0] if holdable_call_numbers.count == 1 and call_number.blank?
    ckey_matches = user.checkouts.select { |checkout| checkout.catalog_item.key == @_catalog_item.key } || []
    ckey_matches.each do |checkout|
      call_number_matches = checkout.catalog_item.holdings.select { |holding| holding.call_number == call_number } || {}
      return true if call_number_matches.size > 0
    end
    return false
  end
  
  def has_non_sas_items?
    nons = @_catalog_item.holdings.select { |holding| holding.library.code !~ /^AT-SEA/ } || []
    nons.size > 0
  end
  
  def has_ivy_holdings?
    @_catalog_item.holdings.each do |holding|
      holding.copies.each do |copy|
        return true if (holding.library.code =~ /IVY/ or copy.home_location.code =~ /IVY/) and copy.available?
      end
    end
    false
  end
  
  def linkable_to_ilink?
    return leoable?
  end
  
  def weed_holdings
    @_catalog_item.holdings.delete_if { |holding| holding.shadowed? }
    @_catalog_item.holdings.delete_if { |holding| holding.call_number =~ /VOID/i }
    @_catalog_item.holdings.each do |holding|
      holding.copies.delete_if { |copy| copy.shadowed? }
      holding.copies.delete_if { |copy| copy.current_location.code =~ /LOST|WITHDRAWN|LOSTCLOSED|INTERNET|ORD-CANCLD|TBD/i }
    end
    # if everything was shadowed, pitch it
    @_catalog_item.holdings.delete_if { |holding| holding.copies.size == 0 }    
  end
  
  def set_maps
    @_catalog_item.holdings.each do |holding|
      holding.map = Map.find_best_map(holding.library.code, holding.call_number)
    end
  end
  
  def finalize_holdings(order, hold_map)
    hold_order.each do |library|
      order << hold_map[library]
    end
    order.delete([])
    order.flatten!
    order
  end
  
  def holdings
    order = []
    hold_map = {:ivy => [], :blandy => [], :mt_lake => [], :at_sea => []}
    @_catalog_item.holdings.each do |holding|
      hold_map[:ivy] << holding and next if ivy?(holding.library.code)
      hold_map[:blandy] << holding and next if blandy?(holding.library.code)
      hold_map[:mt_lake] << holding and next if mt_lake?(holding.library.code)
      hold_map[:at_sea] << holding and next if at_sea?(holding.library.code)
      order << holding
    end
    order = order.sort_by {|a| [a.library.name, a.shelving_key] } # sort by library and shelving key
    finalize_holdings(order, hold_map)
  end
  
  def special_collections_holdings
    holdings.select {|holding| holding.library.code == 'SPEC-COLL'} || []
  end
    
  # parse the solr record for summary holdings - build into: Library => HomeLocations => Summaries
  def set_summary_holdings  
    vals = @document.values_for(:summary_holdings_display)
    return if vals.nil?
    vals.each do |val|
      # summary_holdings_display comes out in this format:
      # library | location | text | note | optional label
      parts = val.split("|")
      # get library
      library = (@_summary_libraries.select {|library| library.name == parts[0] }).first
      if library.nil?
        library = Account::Common::Library.new
        library.name = parts[0]
        @_summary_libraries << library
      end
      # get location
      location = (library.summary_locations.select{ |location| location.name == parts[1] }).first
      if location.nil?
        location = Account::Common::HomeLocation.new
        location.name = parts[1]
        library.summary_locations << location
      end
      # add summary
      location.summaries << Account::Common::Summary.new(parts[2], parts[3])
    end
  end
  
  def ivy?(string)
    ["Ivy Stacks", "IVY"].include?(string)
  end
  
  def blandy?(string)
    ["Blandy Experimental Farm", "BLANDY"].include?(string)
  end
  
  def mt_lake?(string)
    ["Mountain Lake", "MT-LAKE"].include?(string)
  end
  
  def at_sea?(string)
    ["Semester at Sea", "AT-SEA"].include?(string)
  end
  
  def hold_order
    [:ivy, :blandy, :mt_lake, :at_sea]
  end  
        
  # order the libraries
  def summary_libraries
    order = []
    hold_map = {:ivy => [], :blandy => [], :mt_lake => [], :at_sea => []}
    @_summary_libraries.each do |library|
      hold_map[:ivy] << library and next if ivy?(library.name)
      hold_map[:blandy] << library and next if blandy?(library.name)
      hold_map[:mt_lake] << library and next if mt_lake?(library.name)
      hold_map[:at_sea] << library and next if at_sea?(library.name)
      order << library
    end
    order.sort! {|a,b| a.name <=> b.name}
    finalize_holdings(order, hold_map)
  end
  
  def self.find(document)
    ckey = document.value_for :id
    ckey = Account::Common.ckey_converter(ckey)
    uri = URI.parse("#{FIREHOSE_URL}/items/#{ckey}")
    begin
      xml = uri.read
      ret = Account::Availability.new(document, Account::Common::CatalogItem.parse(xml, :single=>true, :use_default_namespace => true), xml)
      return ret
    rescue
      RAILS_DEFAULT_LOGGER.info("bad thing!")
      return
    end
  end
  
end