Feature: Display Videos
	In order to get all relevant information about a video
	As a user
	I want to see all of the proper fields from the marc record
	
	Scenario: Search "boston legal" without quotes
	  Given I am on the homepage
    When I fill in "q" with "boston legal"
    And I press "search"
    Then I should get ckey u4679968 in the results
	  And the index display for "u4679968" should have a title of "Boston legal. Season two [videorecording]"
	 
	Scenario: Display variant title
	  Given I am on the document page for id u4855921
	  Then I should see "Variant title" data of "Title on set box: Documentaries of Louis Malle"
	  
	Scenario: Display title, part, medium and subtitle
	  Given I am on the document page for id u4354753
	  Then I should see a title of "Berserk. Season one [videorecording] : complete collection"