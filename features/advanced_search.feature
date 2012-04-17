Feature: Advanced Search Results
  In order to get fantastic search results
  As an end user
  I want to enter search terms in Advanced Search, click the search button, and see awesome results

	Scenario: Advanced search label
		Given I am on the advanced search page
		Then I should see "Catalog Advanced Search"
		
	Scenario: Advanced search label for articles
		Given I am on the articles advanced search page
		Then I should see "Article Advanced Search"
		
	Scenario: Advanced search label in Special Collections lens
		Given I am in the Special Collections lens
		And I follow "Catalog Advanced Search"
		Then I should see "Catalog Advanced Search"
		
	Scenario: Advanced search label in Special Collections lens for articles
		Given I am in the Special Collections lens
		And I follow "Article Advanced Search"
		Then I should see "Article Advanced Search"

  Scenario: Perform advanced search
    Given I am on the advanced search page
    And I fill in "author" with "smith"
    And I press "advanced_search"
    Then I should get results

	Scenario: Advanced Search should display all facet values
		Given I am on the advanced search page
		Then I should see "Biology & Psychology"
    
  Scenario: Title search should look at alternate_title_form_facet
    Given I am on the advanced search page
    When I fill in "title" with "utne reader"
    And I press "advanced_search"
    Then I should get ckey u1627826 in the results
    
  Scenario: Journal searching
    Given I am on the advanced search page
    When I fill in "journal" with "time"
    And I press "advanced_search"
    Then I should get ckey u504272 in the first 10 results
    And I should see the keyword label "Journal Title"
    And I should not see the filter label "Format"
    
  Scenario: Make sure keyword label matches selected focus
    Given I am on the advanced search page
    When I fill in "title" with "women"
    And I press "advanced_search"
    Then I should see the keyword label "Title"
    
  Scenario: Subject searching on string with a stop word
    Given I am on the advanced search page
    When I fill in "subject" with "people with disabilities"
    And I press "advanced_search"
    Then I should get at least 6000 results
      
  Scenario: Search "thomas jefferson library personal copy" in a subject field
	  Given I am on the advanced search page
	  When I fill in "subject" with "thomas jefferson library personal copy"
    And I press "advanced_search"
	  Then I should get at least 300 results
	  And I should get at most 600 results
      
      
  Scenario: Search "kafka the decisive years" without quotes
	  Given I am on the advanced search page
	  When I fill in "title" with "kafka the decisive years"
	  And I press "advanced_search"
	  Then I should get ckey u4330166 in the results
	  And I should get at most 1 results
      
  Scenario:  Author search shouldn't be problematic if the author's name is a stopword
    Given I am on the advanced search page
    When I fill in "author" with "Will Eisner"
    And I press "Search"
    Then I should get ckey u4474645 in the results
    
  Scenario: Make sure range fields have appropriate label and value
    Given I am on the advanced search page
    And I fill in "publication_date_start" with "2000"
    And I fill in "publication_date_end" with "2005"
    And I press "advanced_search"
    Then I should get results
	  Then I should see the keyword label "Year Published"
    And I should see the keyword value "2000 - 2005"
    
  Scenario: Make sure range values can be removed
    Given I am on the advanced search page
    And I fill in "publication_date_start" with "2000"
    And I fill in "publication_date_end" with "2005"
    And I press "advanced_search"
    Then I should get results
    Then I should see the keyword label "Year Published"
    And I should see the keyword value "2000 - 2005"
    And I click the "x" link
    Then I should not see the keyword label "Year Published"
    
  Scenario: Non-range fields should be properly composed
    Given I am on the advanced search page
    And I fill in "author" with "jones"
    # that would fail if there is no "author" field
    
  Scenario: Range fields should be properly composed
    Given I am on the advanced search page
    And I fill in "publication_date_start" with "2000"
    And I fill in "publication_date_end" with "2005"
    # that would fail if there is no "publication_date_start" or "publication_date_end" field
  
  Scenario: Refine advanced search
    Given I am on the advanced search page
    And I fill in "author" with "Emerson"
    And I press "advanced_search"
    Then I should get results
    And I click the "refineSearchLink" link
		Then the "author" field within "body" should contain "Emerson"
    
  Scenario: Refine advanced search should repopulate range field
    Given I am on the advanced search page
    When I fill in "publication_date_start" with "1900"
    And I fill in "publication_date_end" with "1950"
    And I press "advanced_search"
    Then I should get results
    When I click the "refineSearchLink" link
		Then the "publication_date_start" field within "body" should contain "1900"
		Then the "publication_date_end" field within "body" should contain "1950"
		
	Scenario: Refine advanced search should repopulate sort field
		Given I am on the advanced search page
		And I fill in "author" with "Smith"
		And I select "Title" from "sort_key"
		And I press "advanced_search"
		And I click the "refineSearchLink" link
		Then I should see select list "select#sort_key" with "Title" selected
		
	Scenario: Refine advanced search should repopulate op field
		Given I am on the advanced search page
		And I fill in "author" with "Smith"
		And I select "any" from "op"
		And I press "advanced_search"
		And I click the "refineSearchLink" link
		Then I should see select list "select#op" with "any" selected
    
  Scenario: Perform advanced search and then select additional facets from search results
    Given I am on the advanced search page
    And I fill in "author" with "William Webb Pusey"
    And I press "advanced_search"
    Then I should get exactly 7 results
    When I follow "Special Collections"
    Then I should get exactly 6 results
    
  Scenario: Perform advanced search and then select additional facets from more link
    Given I am on the advanced search page
    And I fill in "author" with "William Webb Pusey"
    And I press "advanced_search"
    Then I should get exactly 7 results
    When I follow "Geographic Location"
    And I follow "Russia"
    Then I should get exactly 1 results
    
  Scenario: Select facets from advanced search, then supply keyword on search results
    Given I am on the advanced search page
    And I check "Alderman"
    And I press "advanced_search"
    And I fill in "q" with "corgi"
    And I press "Search"
    Then I should get at least 10 results
    Then I should get at most 20 results
  