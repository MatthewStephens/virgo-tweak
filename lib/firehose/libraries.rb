require 'happymapper'
require 'open-uri'

module Firehose::Libraries
  
  def get_library_list
    uri = URI.parse("#{FIREHOSE_URL}/list/libraries")
    begin
      str = uri.read
      Firehose::Common::LibraryList.parse(str, :single=>true, :use_default_namespace => true)
    rescue
      return
    end
  end
  
end