Feature: Display Facets
  In order to select facets successfully
  As a user
  I want to see all of the facet values in the right order

  Scenario: facet sorting for a standard facet
    Given I am on the facet page for library_facet
	  Then facet entry 1 should be "Alderman"
	  And facet entry 2 should be "Ivy"
	  When I follow "A-Z"
	  Then facet entry 1 should be "Alderman"
    And facet entry 2 should be "Astronomy"
    When I follow "Number of Results"
	  Then facet entry 1 should be "Alderman"
	  And facet entry 2 should be "Ivy"
	  
	Scenario: facet sorting for call number
	  Given I am on the facet page for call_number_facet
	  Then facet entry 1 should be "B - Philosophy (General)"
	  And facet entry 2 should be "BX - Christian Denominations"
	  When I follow "Number of Results"
	  Then facet entry 1 should be "PS - American Literature"
	  And facet entry 2 should be "PQ - French, Italian, Spanish, Portuguese Literature"
	  When I follow "A-Z"
	  Then facet entry 1 should be "B - Philosophy (General)"
	  And facet entry 2 should be "BX - Christian Denominations"
	  
	  