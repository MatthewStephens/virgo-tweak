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
    