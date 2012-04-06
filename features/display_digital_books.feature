Feature: Display Digital Books

	Scenario: Display dl_book items that are marc-based
		Given I am on the document page for id uva-lib:1002988
		Then I should see a title of "The life of John Randolph of Roanoke"
		Then I should see "Format" data of "Online; Book"
		And I should see "Description" data of "2 v. in 1. fronts. (ports.) 24 cm."
		And I should see "Edition" data of "13th ed."
		And I should see "Published" data of "New York,D. Appleton & company,1840."
		And I should see "Notes" data of "Vols. 1 and 2 have also special title-pages."
		And I should see "Local Notes" data of "SPECIAL COLLECTIONS: Ms. letter of John Randolph tipped in."
		And I should see a related name of "Garland, Hugh A, 1805-1854." with no role
		
	Scenario: Display dl_book items that are not marc-based
		Given I am on the document page for id uva-lib:1051794
		Then I should see a title of "Untitled; Holsinger Studio Collection, 1889 - 1939"
		And I should see a responsibility statement of "Holsinger, Ralph W."
		And I should see "Format" data of "Online; Photographs"
		And I should see "Title" data of "Untitled"
		And I should see "Series" data of "Holsinger Studio Collection, 1889 - 1939"
		And I should see "Creator" data of "Holsinger, Ralph W."

	Scenario: Do not show "Access in Virgo Classic" for dl_book items that are marc-based
	 	Given I am on the document page for id uva-lib:1002988
		Then I should not see "Access in Virgo Classic"
		
	Scenario: Search results display for dl_book items
		Given I am on the homepage
		When I fill in "q" with "M1 .S445 v. 175 no. 13 online"
		And I press "Search"
		Then I should get exactly 1 results
		And I should see "Then you'll remember me : ballad"
		And I should see "M1 .S445 v. 175 no. 13"
		And I should see "1895"
		And I should not see "Availability"
		And I should see "View online"
		