Feature: Vernacular Script Display
  In order to be a part of a global world of information
  I want to see the original script when it exists

  Scenario: Display Chinese language title, responsibility statement, and related names
    Given I am on the document page for id u4802090 
	Then I should see a title of "Taiwan dian ying bai nian shi hua"
	And I should see a title of "台灣電影百年史話"
	And I should see a related name of "Huang, Ren" with no role
	And I should see a responsibility statement of "編著黃仁, 王唯 ; 撰述委員王清華 ... [et al.]"

	Scenario: Display Chinese language fields in search results
	 Given I am on the homepage
     When I fill in "q" with "Taiwan cinema"
     And I press "Search"
     Then I should get ckey u4802090 in the results

	Scenario: Search for Chinese titles
	 Given I am on the homepage
     When I fill in "q" with "台灣電影百年史話"
     And I press "Search"
     Then I should get ckey u4802090 in the results
	 And the result display for ckey u4802090 should have a title of "台灣電影百年史話"
	 And the result display for ckey u4802090 should have a title of "Taiwan dian ying bai nian shi hua"