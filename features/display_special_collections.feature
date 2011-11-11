Feature: Display Special Collections Lens
  In order to get only the relevant information for Special Collections items
  As a user
  I want to see accurate information
	
  Scenario: do not display non-Special Collections holdings on availability
    Given I am in the Special Collections lens
  	And I am on the status page for id u2243187
  	Then I should not see a library "Alderman"
    
  Scenario: Do not show request link if the item has no holdings
    Given I am in the Special Collections lens
    And I am on the status page for id holsinger:1
    Then I should not see "Request this Item"
    
  Scenario: Do not show request link if the item is only in SC-IVY
    Given I am in the Special Collections lens
    And I am on the status page for id u5492
    Then I should not see "Request this Item"

	Scenario: Do not show request link if the item has home location SC-IVY and is IN-PROCESS
		Given I am in the Special Collections lens
		And I am on the status page for id u1896264
		Then I should not see "Request this Item"
    
  Scenario: Present login options
    Given I am in the Special Collections lens
    And I am on the status page for id u3572181
    And I follow "Request this Item"
    Then I should see "UVa login"
    And I should see "Non-UVa login"
    
  Scenario: Allow non-UVa login
    Given I am in the Special Collections lens
    And I am on the status page for id u3572181
    And I follow "Request this Item"
    And I follow "Non-UVa login"
    And I fill in "user_id" with "A61221042"
    And I press "Request"
    Then I should see "Request for Papers of Henry James"
    
  Scenario: Require that a user_id be entered for non-UVa login
    Given I am in the Special Collections lens
    And I am on the status page for id u3572181
    And I follow "Request this Item"
    And I follow "Non-UVa login"
    And I press "Request"
    Then I should see "You must establish your identify before making a request."

  Scenario: If a user picks a non-UVa login, don't let them enter a UVa ID
    Given I am in the Special Collections lens
    And I am on the status page for id u3572181
    And I follow "Request this Item"
    And I follow "Non-UVa login"
    And I fill in "user_id" with "mpc3c"
    And I press "Request"
    Then I should see "UVa members should use NetBadge to authenticate"
    
  Scenario: Allow UVa login
    Given I am in the Special Collections lens
    And I am on the status page for id u3572181
    And I follow "Request this Item"
    And I follow "UVa login"
    Then I should see "Request for Papers of Henry James"
    
  Scenario: Allow items with a single selection to work without checking a checkbox
    Given I am in the Special Collections lens
    And I am on the status page for id u507022
    And I follow "Request this Item"
    And I follow "UVa login"
    And I press "Request"
    Then I should see "Request successfully submitted"
    
  Scenario: For multiple-selection items, complain if no option is selected (UVa-login)
    Given I am in the Special Collections lens
    And I am on the status page for id u3572181
    And I follow "Request this Item"
    And I follow "UVa login"
    And I press "Request"
    Then I should see "You must select at least one item"
  
  Scenario: For multiple-selection items, complain if no option is selected (non UVa-login)
    Given I am in the Special Collections lens
    And I am on the status page for id u3572181
    And I follow "Request this Item"
    And I follow "Non-UVa login"
    And I fill in "user_id" with "A61221042"
    # request on the form where you enter your id
    And I press "Request"
    # request on the form where you select your items
    And I press "Request"
    Then I should see "You must select at least one item"
    
  Scenario: Show success message when multiple items are selected
    Given I am in the Special Collections lens
    And I am on the status page for id u3572181
    And I follow "Request this Item"
    And I follow "UVa login"
    And I check "location_plus_call_number[BARR-VAULT][X004958781][]"
    And I check "location_plus_call_number[BARR-VAULT][X004958780][]"
    And I press "Request"
    Then I should see "Request successfully submitted"
  
  Scenario:  Do not show Special Collections library facet twice
    Given I am in the Special Collections lens
    And I fill in "q" with "Papers of Henry James"
    And I press "search"
    Then I should see one filter for Special Collections
    
	Scenario: Display location notes without Z39.50
	  Given I am in the Special Collections lens
	  Given I am logged in as "xw5d"
	  And I am on the status page for id u3811764
	  And I follow "Request this Item"
		And I check "location_plus_call_number_ARCHV-STKS_X030080645_"
	  And I press "Request"
	  Then I should see "Request successfully submitted"
	  Given I am logged in as a Special Collections administrator
	  And I follow "View"
	  Then I should see "SPECIAL COLLECTIONS: @ RG."
   
	Scenario: Display name from LDAP
		Given I am in the Special Collections lens
	  Given I am logged in as "mpc3c"
	  And I am on the status page for id u2434648
	  And I follow "Request this Item"
	  And I press "Request"
	  Then I should see "Request successfully submitted"
	  Given I am logged in as a Special Collections administrator	
		Then I should see "Pickral, Mary Hope"
		
	Scenario: If no name in LDAP, display name from SIRSI
   	Given I am in the Special Collections lens
	  Given I am logged in as "A61221042"
	  And I am on the status page for id u2434648
	  And I follow "Request this Item"
	  And I press "Request"
	  Then I should see "Request successfully submitted"
	  Given I am logged in as a Special Collections administrator
		Then I should see "BRICKHOUSE, E N"
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
  