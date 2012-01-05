module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the homepage/
       root_path

     when /the folder page/
       folder_index_path
       
     when /the advanced search page/
       advanced_path
       
    when /the feedback page/
      feedback_path

     when /the articles advanced search page/
       advanced_articles_path(:catalog_select => 'articles')
       
     when /the document page for id (.+)/ 
       catalog_path($1)

     when /the xml page for id (.+)/
       catalog_path($1, :format => :xml)

     when /the image page for id (.+)/ 
       image_load_path($1)

     when /the availability page for id (.+)/ 
       availability_path($1)
       
     when /the brief availability page for id (.+)/ 
      brief_availability_path($1)
    
     when /the firehose page for id (.+)/ 
       firehose_path($1)

     when /the citation page for id (.+)/ 
     citation_catalog_path(:id => $1)

     when /the facet page for (.+)/
       catalog_facet_path($1)

     when /my account page/
        account_index_path
        
     when /the notices page/
        notices_account_index_path

     when /the checkouts page/
        checkouts_account_index_path
      
     when /the holds page/
        holds_account_index_path
        
     when /the reserves page/
        reserves_account_index_path
     
     when /the original catalog and article search page/
       catalog_index_path
       
     

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
