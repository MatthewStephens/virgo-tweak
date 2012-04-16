Feature: Display Hathi materials
  In order to get all relevant information about Hathi items
  As a user
  I want to see appropriate Hathi data elements
	
  Scenario: find Hathi materials
		Given I am on the homepage
		When "library_facet":"Hathi Trust Digital Library" is applied
		And I fill in "q" with "transactions metallurgical"
		And I press "Search"
		Then I should get ckey 000046596 in the results

  Scenario: View Hathi item
		Given I am on the document page for id 000046596
		Then I should see "Transactions"
		
	Scenario: Display "Published"
		Given I am on the document page for id 000000040
		Then I should see "Published" data of "New York, Walker [1968]"
		
	Scenario: Display "Content"
		Given I am on the document page for id 000000040
    Then the first track should be "v. 1. From mannerism to romanticism."
		And the last track should be "v. 2. Victorian and after."
		
	Scenario: Display "Notes"
		Given I am on the document page for id 000000040		
		Then I should see "Notes" data of "Includes bibliographical references."
		
	Scenario:  Display series statement
		Given I am on the document page for id 000000862
		Then I should see "Series statement" data of "National Bureau of Standards miscellaneous publication 284"