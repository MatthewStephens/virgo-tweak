Feature: Display Accounts
  In order to get all relevant information about a patron
  As a user
  I want to see accurate account information
  
  Scenario: View account
    Given I am logged in as "mpc3c"
    And I am on my account page
    Then I should see a full name
  
  Scenario: View checkouts
    Given I am logged in as "mpc3c"
    And I am on the checkouts page
    Then I should see how many items I have checked out
    
  Scenario: View holds and recalls
    Given I am logged in as "mpc3c"
    And I am on the holds page
    Then I should see how many requested items I have
    
  Scenario: View reserves
    Given I am logged in as "mpc3c"
    And I am on the reserves page
    Then I should see how many reserves I have
    
  Scenario: View notices
    Given I am logged in as "mpc3c"
    And I am on the notices page
    Then I should see how many notices I have
    
  Scenario: User who has no account
    Given I am logged in as "fakeuser"
    And I am on my account page
    Then I should see "No Account Found"
    
  Scenario: Account page
    Given I am viewing the stubbed account page for mst3k
    Then I should see the full name "Timothy Scott Stevens"
    And I should see the user id "tss6n"
    And I should see the working title "Systems Engineer &ndash; Employee"
    And I should see the organization "Lb-Info Technology"
    And I should see the address "PO Box 400112"
    And I should see the email "tss6n@Virginia.EDU"
    And I should see the telephone number "+1 434-243-8733"
    
  Scenario: Checkouts page
    Given I am viewing the stubbed checkouts page for mst3k
    Then I should see 59 items
    And I should see a recalled item
    And I should see an overdue item
    And I should see an item with no due date
    
  Scenario: Holds page
    Given I am viewing the stubbed holds page for mst3k
    Then I should see 4 items
  
  Scenario: Reserves page
    Given I am viewing the stubbed reserves page for mst3k
    Then I should see 5 items

	Scenario: Make sure user is logged in before initiating a hold/recall
		Given I am on the status page for id u3766511
		And I follow "Request Unavailable Item"
	  Then I should see "Please sign in with NetBadge to request this item."
	
	Scenario: Make sure user initiating hold/recall has a SIRSI account
		Given I am logged in as "fakeuser"
		And I am on the status page for id u3766511
		And I follow "Request Unavailable Item"
		Then I should see "No Account Found"
		
	Scenario: Make sure user initiating hold/recall is not barred
		Given I am viewing the stubbed account page for barred mst3k
		And I am on the status page for id u3766511
		And I follow "Request Unavailable Item"
		Then I should see "Your library account is temporarily suspended due to overdue or recalled materials"
		
	Scenario: User initiating hold/recall should see request form
		Given I am logged in as "mjb7q"
		And I am on the status page for id u3766511
		And I follow "Request Unavailable Item"
		Then I should see "Request this Item"
		And I should see "PS3553 .H277 A8 2001"
		And I should see the library list
		
	Scenario: User should be able to submit hold/recall and see flash message
		Given I am logged in as "mjb7q"
		And I am on the status page for id u3766511
		And I follow "Request Unavailable Item"
		And I press "Place Request"
		Then I should see "Request Complete"
		
	
		
	
	