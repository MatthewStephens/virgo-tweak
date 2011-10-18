Feature: Everything (Default) Search Result Relevancy
  In order to get fantastic search results
  As an end user
  I want to enter search terms, click the search button, and see awesome results

  Scenario: Search "buddhism"
	  Given I am on the homepage
    When I fill in "q" with "Buddhism"
    And I press "Search"
	  Then I should get results
    Then I should get at least 6500 results
	  Then I should get at most 11000 results

  Scenario: Search "String quartets Parts" and variants
	  Given I am on the homepage
    When I fill in "q" with "String quartets Parts"
    And I press "search"
    Then I should get at least 900 results
    And I should get the same number of results as a search for "(string Quartets parts)"
    And I should get more results than a search for ""String Quartets parts""
     
  Scenario: Search "french beans food scares" without quotes
	  Given I am on the homepage
    When I fill in "q" with "french beans food scares"
    And I press "search"
    Then I should get ckey u4416306 in the results
    And I should get ckey u4416306 in the first 1 results

  Scenario: Search "united states in the air" without quotes
	  Given I am on the homepage
	  When I fill in "q" with "united states in the air"
	  And I press "search"
	  And I should get ckey u4823821 in the first 1 results
	
  Scenario: Search "thomas jefferson library personal copy" without quotes
	  Given I am on the homepage
	  When "library_facet":"Special Collections" is applied
	  Then I should get at least 300000 results
    When I fill in "q" with "thomas jefferson library personal copy"
	  And I press "search"
    Then I should get at most 500 results
    
  Scenario: Single-word searches should give precedence to exact matches
    Given I am on the homepage
    When I fill in "q" with "nature"
    And I press "search"
    Then I should get ckey u2583402 in the results
    And I should get ckey u503598 in the results
    And I should get ckey u503599 in the results
    And I should get ckey u1970128 in the results
    And I should get ckey u4612916 in the results
    
  Scenario: Greater precision for known item searching: columbia law review
    Given I am on the homepage
    When I fill in "q" with "columbia law review"
    And I press "search"
    Then I should get ckey u4482328 in the first 2 results
    And I should get ckey u3488491 in the first 2 results
  
  Scenario: Additive facets
    Given I am on the homepage
    When "library_facet":"Blandy Experimental Farm" is applied
    And "author_facet":"Darwin, Charles, 1809-1882" is applied
    And I fill in "q" with "geology"
    And I press "search"
    Then I should get exactly 3 results
 
# Pending until I can actually find something with more than 3 call numbers    
#  Scenario: Display "Multiple call numbers" when call numbers are > 3
#  Given I am on the homepage
#  When I fill in "q" with "The parliamentary debates (Hansard)"
#    And I select "Title" from "focus"
#    And I press "search"
#  Then I should see multiple call numbers
  
  Scenario: Do not display "HIDDEN" records in search results
    Given I am on the homepage
    When I fill in "q" with "Rail-truck intermodal transportation research, 1982"
    And I press "search"
    Then I should not get ckey u63 in the results
   
  Scenario: Do not display "HIDDEN_OVERRIDE" records in search results
    Given I am on the homepage
    When I fill in "q" with "nationalism and sexuality : respectability and abnormal sexuality in modern europe"
    And I press "search"
    Then I should not get ckey u200 in the results  

  Scenario: Music library searches
	  Given I am on the homepage
	  When "library_facet":"Music" is applied
	  Then I should get at least 84000 results
	  And  I should get at most 120000 results
    When I fill in "q" with "calexico"
    And I press "search"
    Then I should get at least 3 results

  Scenario:  Portal stickiness
    Given I am on the homepage
    When I follow "Music Search"
    Then I should be in the Music Search portal
    When "recording_format_facet":"CD" is applied
    Then I should be in the Music Search portal
    When I follow "Start over"
    Then I should be in the Music Search portal
    
  Scenario:  switch Portal 
    Given I am on the homepage
    When I follow "Music Search"
    Then I should be in the Music Search portal
    When I fill in "q" with "nature"
    Then I should be in the Music Search portal
    When I follow "Catalog + Article Results"
    Then I should be in the Catalog + Article Search portal
    When I follow "Start over"
    Then I should be on the original catalog and article search page
    
  Scenario:  switch Portal 
    Given I am on the homepage
    When I follow "Music Search"
    Then I should be in the Music Search portal
    When I fill in "q" with "nature"
    Then I should be in the Music Search portal
    When I follow "Article Results"
    Then I should be in the Article Search portal
    When I follow "Start over"
    Then I should be on the original catalog and article search page
    
  Scenario:  switch Portal 
    Given I am on the homepage
    When I follow "Video Search"
    Then I should be in the Video Search portal
    When I fill in "q" with "nature"
    Then I should be in the Video Search portal
    When I follow "Article Results"
    Then I should be in the Article Search portal
    When I follow "Start over"
    Then I should be on the original catalog and article search page
    
  Scenario:  switch Portal 
    Given I am on the homepage
    When I follow "Video Search"
    Then I should be in the Video Search portal
    When I fill in "q" with "nature"
    Then I should be in the Video Search portal
    When I follow "Catalog + Article Results"
    Then I should be in the Catalog + Article Search portal
    When I follow "Start over"
    Then I should be on the original catalog and article search page
    
  Scenario:  Start over should return user to the main page of selected portal or view 
    Given I am on the homepage
    And I choose "catalog_select_all"
    And I fill in "q" with "nature"
    And I press "search"
    Then I should be in the Catalog + Article Search portal
    When I follow "Start over"
    Then I should be on the original catalog and article search page
    
  Scenario:  Start over should return user to the main page of selected portal or view 
    Given I am on the homepage
    And I choose "catalog_select_all"
    And I fill in "q" with "nature"
    And I press "search"
    Then I should be in the Catalog + Article Search portal
    When I follow "Article Results"
    Then I should be in the Article Search portal
    When I follow "Start over"
    Then I should be on the original catalog and article search page
    
  Scenario:  Start over should return user to the main page of selected portal or view 
    Given I am on the homepage
    And I choose "catalog_select_all"
    And I fill in "q" with "nature"
    And I press "search"
    Then I should be in the Catalog + Article Search portal
    When I follow "Music Results"
    Then I should be in the Music Search portal
    When I follow "Start over"
    Then I should be in the Music Search portal
    
   Scenario:  Start over should return user to the main page of selected portal or view 
    Given I am on the homepage
    And I choose "catalog_select_all"
    And I fill in "q" with "nature"
    And I press "search"
    Then I should be in the Catalog + Article Search portal
    When I follow "Video Results"
    Then I should be in the Video Search portal
    When I follow "Start over"
    Then I should be in the Video Search portal
    
  Scenario:  Start over should return user to the main page of selected portal or view 
    Given I am on the homepage
    And I choose "catalog_select_catalog"
    And I fill in "q" with "nature"
    And I press "search"
    Then I should be in the Catalog Search portal
    When I follow "Start over"
    Then I should be on the original catalog and article search page
    
  Scenario:  Start over should return user to the main page of selected portal or view 
    Given I am on the homepage
    And I choose "catalog_select_catalog"
    And I fill in "q" with "nature"
    And I press "search"
    Then I should be in the Catalog Search portal
    When I follow "Article Results"
    Then I should be in the Article Search portal
    When I follow "Start over"
    Then I should be on the original catalog and article search page
    
  Scenario:  Start over should return user to the main page of selected portal or view 
    Given I am on the homepage
    And I choose "catalog_select_catalog"
    And I fill in "q" with "nature"
    And I press "search"
    Then I should be in the Catalog Search portal
    When I follow "Music Results"
    Then I should be in the Music Search portal
    When I follow "Start over"
    Then I should be in the Music Search portal
    
  Scenario:  Start over should return user to the main page of selected portal or view 
    Given I am on the homepage
    And I choose "catalog_select_catalog"
    And I fill in "q" with "nature"
    And I press "search"
    Then I should be in the Catalog Search portal
    When I follow "Video Results"
    Then I should be in the Video Search portal
    When I follow "Start over"
    Then I should be in the Video Search portal
    
  Scenario:  Start over should return user to the main page of selected portal or view 
    Given I am on the homepage
    And I choose "catalog_select_articles"
    And I fill in "q" with "nature"
    And I press "search"
    Then I should be in the Article Search portal
    When I follow "Start over"
    Then I should be on the original catalog and article search page
    
  Scenario:  Start over should return user to the main page of selected portal or view 
    Given I am on the homepage
    And I choose "catalog_select_articles"
    And I fill in "q" with "nature"
    And I press "search"
    Then I should be in the Article Search portal
    When I follow "Catalog Results"
    Then I should be in the Catalog Search portal
    When I follow "Start over"
    Then I should be on the original catalog and article search page
    
  Scenario:  Start over should return user to the main page of selected portal or view 
    Given I am on the homepage
    And I choose "catalog_select_articles"
    And I fill in "q" with "nature"
    And I press "search"
    Then I should be in the Article Search portal
    When I follow "Music Results"
    Then I should be in the Music Search portal
    When I follow "Start over"
    Then I should be in the Music Search portal
    
  Scenario:  Start over should return user to the main page of selected portal or view 
    Given I am on the homepage
    And I choose "catalog_select_articles"
    And I fill in "q" with "nature"
    And I press "search"
    Then I should be in the Article Search portal
    When I follow "Video Results"
    Then I should be in the Video Search portal
    When I follow "Start over"
    Then I should be in the Video Search portal
    
  Scenario:  Start over should return user to the main page of selected portal or view 
    Given I am on the homepage
    When I follow "Music Search"
    Then I should be in the Music Search portal
    When I fill in "q" with "nature"
    And I press "search"
    Then I should be in the Music Search portal
    When I follow "Start over"
    Then I should be in the Music Search portal
    
  Scenario:  Start over should return user to the main page of selected portal or view 
    Given I am on the homepage
    When I follow "Music Search"
    Then I should be in the Music Search portal
    When I fill in "q" with "nature"
    And I press "search"
    Then I should be in the Music Search portal
    When I follow "Video Results"
    Then I should be in the Video Search portal
    When I follow "Start over"
    Then I should be in the Video Search portal
    
  Scenario:  Start over should return user to the main page of selected portal or view 
    Given I am on the homepage
    When I follow "Video Search"
    Then I should be in the Video Search portal
    When I fill in "q" with "nature"
    And I press "search"
    Then I should be in the Video Search portal
    When I follow "Start over"
    Then I should be in the Video Search portal
    
  Scenario:  Start over should return user to the main page of selected portal or view 
    Given I am on the homepage
    When I follow "Video Search"
    Then I should be in the Video Search portal
    When I fill in "q" with "nature"
    And I press "search"
    Then I should be in the Video Search portal
    When I follow "Music Results"
    Then I should be in the Music Search portal
    When I follow "Start over"
    Then I should be in the Music Search portal
    
    
  Scenario: Make sure Music portal searches have music facets
    Given I am on the homepage
    When I follow "Music Search"
    Then I should be in the Music Search portal
    And I should see the facet "Recordings and scores"
    When I fill in "q" with "Tim O'Brien"
    And I press "search"
    Then I should see the facet "Recordings and scores"
    
  Scenario: Additive facets
	  Given I am on the homepage
	  When "library_facet":"Music" is applied
	  Then I should get at least 84000 results
	  And  I should get at most 120000 results
	  When "format_facet":"Book" is applied
	  Then I should get at least 24000 results
	  And  I should get at most 38000 results
    
  Scenario: Display print and online versions in proximity in search results
    Given I am on the homepage
    When I fill in "q" with "germanic review"
    And I press "search"
    Then I should get ckey u4487286 followed by ckey u461865
    Given I am on the homepage
    When I fill in "q" with "representations"
    And I press "search"
    Then I should get ckey u4500425 followed by ckey u141067
  
  Scenario: Display Digital Library objects
    Given I am on the homepage
    When I fill in "q" with "The psychology of perspective and Renaissance art"
    And I press "search"
    Then I should get ckey uva-lib:32444 in the results
  
# having trouble getting this to work -- will investigate later
  Scenario: Encode query onto xtf.lib.virginia.edu links
#  Given I am on the homepage
#  When I fill in "q" with "Job Dundy"
#    And I press "search"
#  Then the result display should have the full text view link of #http://xtf.lib.virginia.edu/xtf/view?docId=modern_english/uvaGenText/tei/BibNarr.xml&query=Job Dundy
 
	
  Scenario: DVD call number search
    Given I am on the homepage
    When I fill in "q" with "Video .DVD05885"
    And I press "search"
    Then I should get ckey u4372110 in the results
  
  Scenario: Author search should produce hits by the actual author in early results
    Given I am on the homepage
    When I fill in "q" with "hofmann michael"
    And I press "search"
    Then I should see 10 results for the author Hofmann, Michael
    
  Scenario: If user inputs call number with quotes, preserve quotes
    Given I am on the homepage
    When I fill in "q" with "'mss 13'"
    And I press "search"
    Then I should see the keyword value "'mss 13'"
    
  Scenario: If user inputs call number without quotes, don't display them
    Given I am on the homepage
    When I fill in "q" with "mss 13"
    And I press "search"
    Then I should see the keyword value "mss 13"
    
  Scenario:  Uniform title search
    Given I am on the homepage
    When I fill in "q" with "holy bible 1748"
    And I press "search"
    Then I should get ckey u2057213 in the results
  
  Scenario: Make sure keyword label defaults to "Keywords" if no focus is selected
    Given I am on the homepage
    When I fill in "q" with "women"
    And I choose "catalog_select_catalog"
    And I press "search"
    Then I should see the keyword label "Keyword"
  
  Scenario: Make sure keyword label defaults to "Keywords" if no focus is selected in the Music portal
    Given I am on the homepage
    When I follow "Music Search"
    When I fill in "q" with "Sibelius"
    And I press "search"
    Then I should see the keyword label "Keyword"
    
  Scenario: Return user to search results after logging in
    Given I am on the homepage
    When I fill in "q" with "edwin dugger"
    And I choose "catalog_select_catalog"
    And I press "search"
    Then I should get ckey u29037 in the results
    When I click the "Sign in" link
    Then I should be logged in
    And I should get ckey u29037 in the results
    
   Scenario: Return user to first page of search results after refining a search
    Given I am on the homepage
    When I fill in "q" with "william pusey"
    And I choose "catalog_select_catalog"
    And I press "search"
    Then I should get results
		When I follow "Next »"
    And I follow "Alderman"
    Then I should get results
    
  Scenario: Sorting records
    Given I am on the homepage
    When I fill in "q" with "red rain"
    And I choose "catalog_select_catalog"
    And I press "search"
    When "library_facet":"Education" is applied
    Then I should get exactly 2 results
    And I should get ckey u2958712 in the first 1 results
    And I should get ckey u2285503 in the first 2 results
    When I select "Title" from "sort_key"
    And I press "sort results"
    Then I should get ckey u2285503 in the first 1 results
    And I should get ckey u2958712 in the first 2 results
       
  Scenario: Switching sorting multiple times
    Given I am on the homepage
    When I fill in "q" with "william w pusey"
    And I choose "catalog_select_catalog"
    And I press "search"
    And "library_facet":"Special Collections" is applied
    Then I should get ckey u3900118 in the first 1 results
    When I select "Title" from "sort_key"
    And I press "sort results"
    Then I should get ckey u3900119 in the first 1 results
    When I select "Date Published - oldest first" from "sort_key"
    And I press "sort results"
    Then I should get ckey u2060062 in the first 1 results
    
  Scenario: Make sure sort option sticks when we change the hits per page
    Given I am on the homepage
    When I fill in "q" with "william webb pusey"
    And I choose "catalog_select_catalog"
    And I press "search"
    Then I should get ckey u3900118 in the first 1 results
    And I should get ckey u3900120 in the first 2 results
    When I select "100" from "per_page"
    And I press "update"
    Then I should get ckey u3900118 in the first 1 results
    And I should get ckey u3900120 in the first 2 results
    
  Scenario: Make sure sort option sticks when we change hits per page when there is no q specified
    Given I am on the homepage
    When "region_facet":"Bath County (Va.)" is applied
    And "format_facet":"Thesis/Dissertation" is applied
    And I select "Author" from "sort_key"
    And I press "sort results"
    Then I should get ckey u1659100 in the first 1 results
    And I should get ckey u1651581 in the first 2 results
    When I select "100" from "per_page"
    And I press "update"
    Then I should get ckey u1659100 in the first 1 results
    And I should get ckey u1651581 in the first 2 results
    
  Scenario: Make sure there are no errors when an invalid sort option is specified
    Given I am on the homepage
    And I set "2" as my sort option
    # that's all that is needed - the page will blow up if it doesn't work
    
  Scenario: Make sure we don't display DL items to which we don't have legal rights
    Given I am on the homepage
    When "source_facet":"Digital Library" is applied
    When I fill in "q" with "parkways and park roads"
    And I press "search"
    Then I should not get ckey uva-lib:151436 in the results
  
  Scenario:  Make sure microform journals are included in search results
    Given I am on the homepage
    When I fill in "q" with "utne reader"
    And I press "search"
    Then I should get ckey u1851372 in the results
    
  Scenario: Make sure EADs don't get back into the index
    Given I am on the homepage
    When "digital_collection_facet":"UVa Archival Finding Aids" is applied
    Then I should see no results
  
  Scenario: RSS feed
    Given I am on the homepage
    When "library_facet":"Alderman" is applied
    And I follow "resultsRSSLink"
    Then I should see "VIRGO Catalog Search Results"
  
  Scenario: Display chat widget, remove per page and RSS when there's no search result
    Given I am on the homepage
    When I fill in "q" with "lariope"
    And I choose "catalog_select_catalog"
    And I press "search"
    Then I should see no results
    Then I should not see "per page"
    Then I should not see "RSS"
    Then I should see "Chat with a Librarian"
    

    
  
  
# should get ckeys X and Y within Z positions of each other in the results
# search X should have <,<=,=,>=,> results than search Y  (phrase!  boolean! parens!)
# should have results with search terms occurring in the title sorted first

# TODO: would like to test that default search is not case sensitive
# TODO: FIXME: test for other less relevant results for Two3
# TODO: FIXME: test for non-relevant results for Two3

  # Scenario: Search "waffle" and check result order
  #   Given a SOLR index with Stanford MARC data
  #   And I go to the home page
  #   When I fill in "q" with "waffle"
  #   And I press "search"
  #   Then I should get ckey 6720427 before ckey 7763651
  #   And I should get ckey 4535360 before ckey 7763651
  #   And I should get ckey 2716658 before ckey 6546657
  #   And I should get ckey 5087572 before ckey 6546657
