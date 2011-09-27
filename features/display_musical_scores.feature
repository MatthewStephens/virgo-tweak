Feature: Display Musical Scores
	In order to get all relevant information about a musical score
	As a user
	I want to see all of the proper fields from the marc record

	Scenario: related names should display correctly 
		Given I am on the document page for id u4368118
		Then I should see a title of "Incomplete operas"
		And I should see a related name of "Berlioz, Hector, 1803-1869." with no role
		And I should see a related name of "Ferrand, Humbert, 1805-1868." with a role of "Librettist"
		And I should see a related name of "Graebner, Ric" with no role
		
	Scenario: Publisher/plate no. should display correctly
	  Given I am on the document page for id u3949470
	  Then I should see a title of "The Godowsky collection"
	  And I should see "Published" data of "New York : C. Fischer, c2001-"
	  And I should see a Publisher/plate no. "ATF122 C. Fischer (v. 1)"
    And I should see a Publisher/plate no. "ATF123 C. Fischer (v. 2)"
    And I should see a Publisher/plate no. "ATF137 C. Fischer (v. 3)"
    