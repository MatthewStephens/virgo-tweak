Feature: Display roman coins from the UVA art museum
  In order to wow people with our great coins
  I want to make sure the coins exist and that their data is showing up properly

  Scenario: search for stuff from the UVA art museum
	Given I am on the homepage
	When "source_facet":"U.Va. Art Museum" is applied
	Then I should get at least 570 results
	When "subject_facet":"Gallienus" is applied
	Then I should get at least 83 results

  Scenario: Search Gallienus
	Given I am on the homepage
    When I fill in "q" with "Gallienus 1991.17.69"
    And I press "Search"
    Then I should get ckey n1991_17_69 in the results

  Scenario: format coins display properly 
    Given I am on the document page for id n1990_18_1
	Then I should see a title of "Nero, A.D. 64-68"
	
  Scenario: Display hyperlinks
  	Given I am on the document page for id n1991_17_65 
  	When I follow "Lugdunensis"
  	Then I should get at least 12 results
  	
  Scenario: Display subject side bars
    Given I am on the document page for id n1991_17_65
    Then I should see "Related Subjects"

