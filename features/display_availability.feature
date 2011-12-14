Feature: Display Availability
  In order to get all relevant information about availability
  As a user
  I want to see accurate availability information from firehose2
	
  Scenario: display full name of location within library
  	When I am on the availability page for id u212980
  	Then I should see a current location "Stacks"
	
  Scenario: do not show LOST items
    When I am on the availability page for id u2443277
    Then I should not see a current location "ZZZ Item is lost"
    
  Scenario: do not show LOST items
    When I am on the availability page for id u4027731
    Then I should not see a holding call number "Call #: VIDEO .DVD15059 pt.2"
    
  Scenario: do not show Semester at Sea items
    When I am on the availability page for id u3774279
    Then I should not see a current location "Semester at Sea Collection"
    
  Scenario: do not show Semester at Sea videos
    When I am on the availability page for id u3988279
    Then I should not see a current location "ATSEA-VID"
    
  Scenario: do not show Semester at Sea reference items
    When I am on the availability page for id u4886544
    Then I should not see a current location "REFERENCE"
    
  Scenario: when the item is Semester at Sea only, display text that says so
    When I am on the availability page for id u5076588
    Then I should see "This item is only available to Semester At Sea participants."

  Scenario: when the item has Semester at Sea as one of its set of holdings (more than 1), then display text that says it is also available through Semester at Sea
    When I am on the availability page for id u5170596
    Then I should see "Semester at Sea"

  Scenario: do not show withdrawn items
    When I am on the availability page for id u207929
    Then I should not see a library "Clemons"
  
  Scenario: do not show ORD-CANCLD items
    When I am on the availability page for id u525979
    Then I should not see a current location "ZZZ Canceled order"
    
  Scenario: do not show shadowed call number entries
    When I am on the availability page for id u269882
    Then I should not see a holding call number "Call #: E-18-Wha-ObsMoG"
    
  Scenario: do not show shadowed item entrieds
    When I am on the availability page for id u163770
    Then I should not see a holding call number "Call #: I-1BC-Vi-DixLiA"
  
  Scenario: do not show VOID call numbers
    When I am on the availability page for id u832529
    Then I should not see a holding call number "Call #: MSS 7443-b VOID"

	Scenario: Show current location for "DEC-IND-RM" current locations
		Given I am on the availability page for id u201044
		Then I should see a current location "Declaration of Independence Room"
	
	Scenario: Don't show current location of "Special Collections" for Special Collections items
		Given I am on the availability page for id u5346880
		Then I should see a current location "Special Collections"

  Scenario: show firehose results
    When I am on the firehose page for id u4899865
    Then I should see "VIDEO .DVDTV000406 PT. 000001"
    
  Scenario: Do not show link to Virgo request when in special collections lens
    Given I am in the Special Collections lens
    And I am on the availability page for id u3572181
    Then I should not see "LEO delivery (faculty/SCPS)"

	Scenario: Show "LEO delivery (faculty/SCPS)" when item is in Special Collections but user is not in Special Collections lens
	  When I am on the availability page for id u3572181
    Then I should see "LEO delivery (faculty/SCPS)"

	Scenario: Show "Request Unavailable Item" if the only copy is unavailable
		Given I am on the availability page for id u4215764
		Then I should see "Request Unavailable Item"
	
	Scenario: Do not show "Request Unavailable Item" if a copy is available
		Given I am on the availability page for id u611539
		Then I should not see "Request Unavailable Item"

	Scenario: Do not show "LEO delivery (faculty/SCPS)" for an item whose only holding is on Semester at Sea
	  When I am on the availability page for id u2380852
	  Then I should see "This item is only available to Semester At Sea participants."
		And I should not see "LEO delivery (faculty/SCPS)"

	Scenario: Show "LEO delivery (faculty/SCPS)" if only one of the holdings is on Semester at Sea
	  When I am on the availability page for id u19017
	  Then I should see "LEO delivery (faculty/SCPS)"
	
	Scenario: Do not show "LEO delivery (faculty/SCPS)" for an item whose only holding is at Blandy
	  When I am on the availability page for id u5226735
		And I should not see "LEO delivery (faculty/SCPS)"
		
	Scenario: Show "LEO delivery (faculty/SCPS)" if only one of the holdings is at Blandy
	  When I am on the availability page for id u131949
	  Then I should see "LEO delivery (faculty/SCPS)"

	Scenario: Do not show "LEO delivery (faculty/SCPS)" for an item whose only holding is at Mt. Lake
	  When I am on the availability page for id u5353971
		And I should not see "LEO delivery (faculty/SCPS)"

	Scenario: Show "LEO delivery (faculty/SCPS)" if only one of the holdings is at Mt. Lake
	  When I am on the availability page for id u145947
	  Then I should see "LEO delivery (faculty/SCPS)"
	        
  Scenario: Show number of copies for SAS but not whether they are available
    When I am on the availability page for id u5238302
    And I should not see "Available"
        
  Scenario: Display summary holding text
    When I am on the availability page for id u1614058
    Then I should see a summary text "no.1875-2051,2053-2065  (2007:Nov.5-2011:July 3),"
    
  Scenario: Display summary holding note
    When I am on the availability page for id u1614058
    Then I should see a summary note "*Scattered articles originally censored under Franco"
    
  Scenario: Use library order keys for summary holdings
    When I am on the availability page for id u365158
    Then the first holding library should be "Brown SEL"
    
  Scenario: Show Ivy request link if item is in IVY
    When I am on the availability page for id u49
    Then I should see "Request Item from Ivy"

  Scenario: Show Ivy request link if item is in Law Ivy Storage
    When I am on the availability page for id u272843
    Then I should see "Request Item from Ivy"
  
  Scenario: Do not show Ivy request link if item isn't in Ivy
    When I am on the availability page for id u5289479
    Then I should not see "Request Item from Ivy"
  
    