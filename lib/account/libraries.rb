require 'happymapper'
require 'open-uri'

module Account::Libraries
  
  def get_library_list
    uri = URI.parse("#{FIREHOSE_URL}/firehose2/list/libraries")
    begin
      str = uri.read
      Account::Common::LibraryList.parse(str, :single=>true, :use_default_namespace => true)
    rescue
      return
    end
  end
  
end