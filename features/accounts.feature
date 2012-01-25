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

	Scenario: Virginia Borrower login
		Given I am logged in as virginia borrower "VATEST" with pin "TEST"
		And I am on my account page
		Then I should see "Virginia Borrower"
		And I should not see "Request LEO delivery"
		And I should not see "Request interlibrary loan"
		And I should not see "Place course reserve request"
		
	Scenario: Virginia borrower PIN must be correct
		Given I am logged in as virginia borrower "FACTEST" with pin "fakepin"
		Then I should see "Incorrect user or pin"
		
	Scenario: Virginia borrow must not leave PIN blank
		Given I am logged in as virginia borrower "FACTEST" with pin ""
		Then I should see "Incorrect user or pin"
    
  Scenario: Account page
    Given I am viewing the stubbed account page for mst3k
    Then I should see the full name "Timothy Scott Stevens"
    And I should see the user id "tss6n"
    And I should see the working title "Systems Engineer – Employee"
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
		Given I am on the availability page for id u4215764
		And I follow "Request Unavailable Item"
	  Then I should see "Please sign in with NetBadge to request this item."
	
	Scenario: Make sure user initiating hold/recall has a SIRSI account
		Given I am logged in as "fakeuser"
		And I am on the availability page for id u4215764
		And I follow "Request Unavailable Item"
		Then I should see "No Account Found"
		
	Scenario: Make sure user initiating hold/recall is not barred
		Given I am viewing the stubbed account page for barred mst3k
		And I am on the availability page for id u4215764
		And I follow "Request Unavailable Item"
		Then I should see "Your library account is temporarily suspended due to overdue or recalled materials"
		
	Scenario: User initiating hold/recall should see request form
		Given I am logged in as "mjb7q"
		And I am on the availability page for id u4215764
		And I follow "Request Unavailable Item"
		Then I should see "Request this Item"
		And I should see "PR6057 .A623 O43 2004"
		And I should see the library list
		
	Scenario: Virginia Borrower should be able to initiate hold/recall if not already logged in
		Given I am on the availability page for id u4215764
		And I follow "Request Unavailable Item"
		And I follow "non-U.Va. user"
		And I fill in "login" with "VATEST"
		And I fill in "pin" with "TEST"
		And I press "Sign in"
		Then I should see "Request this Item"
		And I should see "PR6057 .A623 O43 2004"
		And I should see the library list		
		
	Scenario: User should be able to submit hold/recall and see flash message
		Given I am logged in as "mjb7q"
		And I am on the availability page for id u4215764
		And I follow "Request Unavailable Item"
		And I press "Place Request"
		Then I should see "Request Complete"
		
	Scenario: A logged-in user requesting account/renew should see checkouts
		Given I am logged in as "mpc3c"
		And I am on the account renew page
		Then I should see "Checked-out Items"
		
	Scenario: A user who is not logged in requesting account/renew should be presented with a login option
		Given I am on the account renew page
		Then I should see "Please sign in to view your account."
		When I follow "Non-U.Va. Users (Library ID)"
		And I fill in "login" with "VATEST"
		And I fill in "pin" with "TEST"
		And I press "Sign in"
		Then I should see "Checked-out Items"
		
	
	