Feature: Display digital texts
  In order to get all relevant information about a digital text
  I want to see all of the proper fields from the XML record

	Scenario: make sure digital texts are appearing
	  Given I am on the document page for id uva-lib:15295
	  Then I should see a title of "The frontier in American history"
	  And I should see online availability of "http://xtf.lib.virginia.edu/xtf/view?docId=2003_Q3/uvaBook/tei/b000337236.xml"
	  
	Scenario: Use main title display if it is available
	  Given I am on the document page for id uva-lib:3388
	  Then I should see a title of "The story of the Negro ; the rise of the race from slavery. Vol. 1"

	Scenario: If main title display isn't available, use title display
	  Given I am on the document page for id uva-lib:123321
	  Then I should see a title of "The Cavalier daily - Wednesday, January 5, 1972"