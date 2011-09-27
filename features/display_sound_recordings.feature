Feature: Display Sound Recordings
	In order to get all relevant information about a sound recording
	As a user
	I want to see all of the proper fields from the marc record
		
	Scenario: formatted tracklists for items with multiple artists should display correctly  
		Given I am on the document page for id u4818603
		Then I should see a title of "Rebel music  [sound recording]."
		And I should see publication data of "[London] : Mojo, [2008]"
		And I should see a track list
		And the first track should be "Tommy gun (live from Shea Stadium) (The Clash)"
		And the last track should be "Clampdown (live from the Lewisham Odeon) (The Clash)"
		
	Scenario: formatted tracklists for items with a single artist should display correctly  
		Given I am on the document page for id u4814923
		Then I should see a title of "Hedwig and the angry inch  [sound recording] : original cast recording"
		And I should see publication data of "New York, NY : Atlantic, p1999."
		And I should see a track list
		And the first track should be "Tear me down"
		And the last track should be "Midnight radio"
		And I should see a performer named "John Cameron Mitchell (Hedwig, Tommy Gnosis, vocals)"
				
	Scenario: tracklists for items with concatenated track listings should display correctly
		Given I am on the document page for id u4814865
		Then I should see a title of "Atlantis Nath  [sound recording]"
		And I should see a track list
		And the first track should be "Crucifixion voices (5:43)"
		And the last track should be "The crucifixion of my humble self (9:22)"
		And I should see a related name of "Martinez, Luc" with no role
		
	Scenario: tracklists for items with 505 subfield g should display correctly 
		Given I am on the document page for id u4814872
		Then I should see a title of "Parade  [sound recording]"
		And I should see a track list
		And the first track should be "The old red hills of home (6:32)"
		And the last track should be "Finale (3:03)"
		And I should see "Label no." data of "09026-63378-2 RCA Victor"
		And I should see a related name of "Uhry, Alfred" with a role of "Librettist"
		And I should see a related name of "Prince, Harold, 1928-" with a role of "Other"
		And I should see a related name of "Stern, Eric" with a role of "Conductor"
		#I can't figure out how to get the parens to match properly in the test, so I'm commenting this out. --Bess
		#And I should see a related name of "Lincoln Center Theater (New York, NY)" with a role of "Other"
		
	Scenario: tracklist display should be suppressed if there is no track dispaly
	  Given I am on the document page for id u1919021  
	  Then I should not see a track list

	Scenario: Calexico Feast of Wire
	  Given I am on the document page for id u3964377
	  Then I should see a title of "Feast of wire  [sound recording]"
	  And the first track should be "Sunken waltz (2:27)"
	  And the last track should be "No doze (4:21)"
	  
	Scenario:  Display multiple 505 entries
	  Given I am on the document page for id u1945874
	  Then the first track should be "Reformation und Geschichte. Five views of history / Jong Sung Rhee"
	  And I should see the track "Calvin und seine Beziehungen. Johannes Calvin / Hans Scholl" as track 5
	  And I should see the track "Calvin's concept of the right of resistance - from the viewpoint of Asia / Nobuo Watanabe" as track 10
	  And I should see the track "'Es gat ein Christenman über fäld' / Helmut Feld" as track 16
	  And I should see the track "'...einander aufnehmen und vertratgen' / Michael Beintker" as track 26

  Scenario: Display Label no. for sound recordings
    Given I am on the document page for id u2959823
    Then I should see a title of "The Joshua tree  [sound recording]"
    And I should see publication data of "New York : Island Records, p1987."
    And I should see "Label no." data of "422 842 298-2 Island"
    
  Scenario: Display credits
    Given I am on the document page for id u4819080
    Then I should see "Credits" data of "Executive producer: Bradley Young ; produced by Matthias Winckelmann"
    
  Scenario: Display recording information
    Given I am on the document page for id u5057309
    Then I should see "Recording information" data of "Recorded live, 1974-1978."
    
  Scenario: Display Format
    Given I am on the document page for id u5279645
    Then I should see "Format" data of "Audio CD; Musical Recording"
    
  Scenario: Display Description
    Given I am on the document page for id u5279645
    Then I should see "Description" data of "3 sound discs : digital ; 4 3/4 in."



		
		