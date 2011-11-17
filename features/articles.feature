Feature: Display Articles
  In order to get all relevant information about articles
  As a user
  I want to search articles and see meaningful results

	Scenario: Use query term
		Given I am on the homepage
		And I choose "catalog_select_articles"
		And I fill in "q" with "global warming"
		And I press "search"
		Then I should get at least 150000 results
		And I should see the keyword label "Keyword"
		And I should see the keyword value "global warming"
		
	Scenario: Use facet input
		Given I am on the homepage
		And I choose "catalog_select_articles"
		And I fill in "q" with "benthic detritus odom"
		And I press "search"
		And I follow "Articles"
		Then I should get at least 5 results
		And I should see the filter label "Format"
		And I should see the filter value "articles"
				
	Scenario: Article pagination
		Given I am on the homepage
		And I choose "catalog_select_articles"
		And I fill in "q" with "global warming"
		And I press "search"
		Then the page number should be 1
		When I follow "Next »"
		Then the page number should be 2
		When I follow "Next »"
		Then the page number should be 3
		When I follow "« Previous"
		Then the page number should be 2
		
	Scenario: Sorting
		Given I am on the homepage
		And I choose "catalog_select_articles"
		And I fill in "q" with "global warming"
		And I press "search"
		When I select "Date" from "sort_key"
		And I press "sort results"
		Then I should see select list "select#sort_key" with "Date" selected			
		When I select "Relevancy" from "sort_key"
		And I press "sort results"
		Then I should see select list "select#sort_key" with "Relevancy" selected			
		
	Scenario: Use query term from articles advanced search
		Given I am on the articles advanced search page
		Then I should see "Article Advanced Search"
		When I fill in "author" with "Pickral"
		And I press "Search"
		Then I should get at least 5 results
		And I should get at most 20 results
		And I should see the keyword label "Author"
		And I should see the keyword value "Pickral"
		
	Scenario: Date range searching for articles advanced search
		Given I am on the articles advanced search page
		Then I should see "Article Advanced Search"
		When I fill in "author" with "Pickral"
		And I fill in "publication_date_start" with "1970"
		And I fill in "publication_date_end" with "1980"
		And I press "Search"
		Then I should get at least 2 results
		And I should get at most 10 results
		And I should see the keyword label "Year Published"
		And I should see the keyword value "1970 - 1980"
		
	Scenario: Removing query inputs
		Given I am on the articles advanced search page
		When I fill in "author" with "jones"
		And I press "Search"
		Then I should get results
		When I follow "Online Resources"
		Then I should get results
		And I should see the keyword label "Author"
		When I follow "x"
		Then I should not see the keyword label "Author"

