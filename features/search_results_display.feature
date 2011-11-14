Feature: Everything (Default) Search Results Display
  In order to get fantastic search results presentation
  As an end user
  I want to enter search terms, click the search button, and see awesome results

  Scenario: Display all 1xx subfields for author information
    Given I am on the homepage
    When I fill in "q" with "The first edition of the one inch Ordnance Survey : a reprint covering England and Wales in 97 sheets"
    And I press "search"
    Then I should see "Author" data of "Great Britain. Ordnance Survey"
    
  Scenario: Display availability link if there are multiple copies
    Given I am on the homepage
    When I fill in "q" with "da vinci code videorecording 2006"
    And I press "search"
		Then I should see "View Locations and Availability "
		
  Scenario: Suppress call number display if there are multiple locations and multiple call numbers
    Given I am on the homepage
    When I fill in "q" with "da vinci code"
    And I press "search"
    Then I should get ckey u4442841 in the results
    And the result display for ckey u4442841 should not have a call number

  Scenario: Suppress call number display for items that are online only
    Given I am on the homepage
    When "format_facet":"Online" is applied
    And I fill in "q" with "Cell motility in the cytoskeleton"
    And I press "search"
    Then I should get ckey u5016479 in the results
    And the result display for ckey u5016479 should not have a call number

  Scenario: Don't display shadowed call number in search results
    Given I am on the homepage
    When I fill in "q" with "mss 7443"
    And I press "search"
    Then the result display for ckey u3901921 should not have the call number "MSS7443-f VOID"
    And the result display for ckey u832529 should not have the call number "MSS7443-b VOID"

  Scenario: Musical recordings should have label for "Composer/Performer"
    Given I am on the homepage
    And I fill in "q" with "edwin dugger 1940 germany"
    And I press "search"
    Then I should see "Composer/Performer"
    And I should see "Dugger, Edwin, 1940-"

  Scenario: Display Access Online links if they are available
    Given I am on the homepage
    When I fill in "q" with "worried sick"
    And I press "search"
    Then the result display for ckey u4669504 should have an online access link of "Access online"

  Scenario: Display link text for Access Online links if link text is available
    Given I am on the homepage
    When I fill in "q" with "worried sick"
    And I press "search"
    Then the result display for ckey u4652571 should have an online access link of "Connect to low resolution streaming video"
    And the result display for ckey u4652571 should have an online access link of "Connect to high resolution streaming video"

  Scenario: Show availability link
    Given I am on the homepage
    When I fill in "q" with "JAMA"
    And I press "search"
    Then I should get ckey u992386 in the results
    And the result display for ckey u992386 should have availability

  Scenario: Suppress availability lookup if the item is online only and has a url display
    Given I am on the homepage
    When I fill in "q" with "JAMA"
    And I press "search"
    Then I should get ckey u4490381 in the results
    And the result display for ckey u4490381 should not have availability

  Scenario:  Make sure Access online links and availability display for items that have both
    Given I am on the homepage
    When I fill in "q" with "The chancery of God"
    And I press "search"
    When "library_facet":"Alderman" is applied
    Then I should get ckey u4772806 in the results
    And the result display for ckey u4772806 should have an online access link of "Table of contents only"
    And the result display for ckey u4772806 should have availability
    
  Scenario: Display publication date if it's not a Journal or Magazine
    Given I am on the homepage
    When I fill in "q" with "Time"
    And I press "search"
    Then I should see a publication date of 1972 for ckey u5147849
  
  Scenario: Do not display publication date if it's a Journal or Magazine
    Given I am on the homepage
    When I fill in "q" with "Time"
    And I press "search"
    Then I should get ckey u4000704 in the results
    And I should not see a publication date for ckey u4000704
    
  Scenario: Display complete title or statement of responsibility field
    Given I am on the homepage
    When I fill in "q" with "i believe wholey"
    And I press "search"
    Then I should get ckey u4823577 in the results
    And the result display for ckey u4823577 should have a title of "I believe. Hinduism [videorecording]"
    
  Scenario: Display complete title or statement of responsibility field
    Given I am on the homepage
    When I fill in "q" with "war on terrorism and iraq human rights"
    And I press "search"
    Then I should get ckey u4020156 in the results
    And the result display for ckey u4020156 should have a title of "Wars on terrorism and Iraq : human rights, unilateralism, and U.S. foreign policy"
   
 Scenario: Display complete title or statement of responsibility field
    Given I am on the homepage
    When I fill in "q" with "Papers of the President of the University of Virginia"
    And I press "search"
    Then I should get ckey u4298149 in the results
    And the result display for ckey u4298149 should have a title of "Papers of the University of Virginia President's Office [manuscript] 1987-2003 (bulk 2002-2003)"
    
 Scenario: Display complete title or statement of responsibility field
    Given I am on the homepage
    When I fill in "q" with "Dust jacket blurb"
    And I press "search"
    Then I should get ckey u2042892 in the results
    And the result display for ckey u2042892 should have a title of "Dust jacket blurb [manuscript] 1992 January 15 typescript signed"
    


   
        
#	 Facets trail and search box no longer visible on item record display    
#  Scenario: Facet stickiness
#    Given I am on the homepage
#    And "library_facet":"Alderman" is applied
#    And I fill in "q" with "blah blah blah"
#    And I press "search"
#    And I follow "Chapala's Khasi self teacher"
#    Then I should see the filter "Alderman"
#    When I fill in "q" with "test"
#    And I press "search"
#    Then I should see the filter "Alderman"
    