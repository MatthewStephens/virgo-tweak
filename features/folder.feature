Feature: User Folder
  In order to keep track of items
  As a user
  I want to be able to store items in my folder

  Scenario: Ensure "Add to Folder" form is present in search results
	  Given I am on the homepage
    When I fill in "q" with "calamity jane the woman and the legend"
    And I choose "catalog_select_catalog"
    And I press "search"
	  And I should get ckey u4322506 in the results
 	  And I should see an add to folder form for ckey "u4322506"
 	  
 	Scenario: Ensure "Add to Folder" form is present on individual record
 	  Given I am on the document page for id u4322506
 	  Then I should see an add to folder form for ckey "u4322506"

	Scenario:  Ensure "Add to Folder" form is present in article search results
		Given I am on the homepage
		When I fill in "q" with "pickral odum benthic detritus"
		And I choose "catalog_select_articles"
		And I press "search"
		Then I should see an add to folder form for ckey "idpubtecumrsmas/bullmar/1984/00000035/00000003/art00022"
 	  
 	Scenario: Adding an item to the folder should produce a status message
 	  Given I am on the homepage
 	  When I fill in "q" with "calamity jane the woman and the legend"
 	  And I choose "catalog_select_catalog"
 	  And I press "search"
 	  And I add ckey "u4322506" to my folder
 	  Then I should see "Added to Starred Items"
 	  
 	Scenario: Add items to folder, then view folder items
    Given I am on the homepage
    When I fill in "q" with "calamity jane the woman and the legend"
    And I choose "catalog_select_catalog"
    And I press "search"
    And I add ckey "u4322506" to my folder
    And I visit the folder page
	  Then I should see ckey "u4322506" in the folder
	  Given I am on the homepage
	  When I fill in "q" with "Appius Claudius Pulcher"
	  And I choose "catalog_select_catalog"
	  And I press "search"
	  And I add ckey "n14_1989_9" to my folder
		Given I am on the homepage
		When I fill in "q" with "pickral odum benthic detritus"
		And I choose "catalog_select_articles"
		And I press "search"
		And I add ckey "pubtecumrsmas/bullmar/1984/00000035/00000003/art00022" to my folder
	  Given I am on the homepage
	  When I fill in "q" with "A 2d. set of six sonatas for two violins"
	  And I choose "catalog_select_catalog"
	  And I press "search"
	  And I add ckey "uva-lib:610693" to my folder
	  Given I am on the homepage
	  When I fill in "q" with "Second April"
	  And I choose "catalog_select_catalog"
	  And I press "search"
	  And I add ckey "uva-lib:477191" to my folder
	  Given I am on the homepage
	  When "digital_collection_facet":"Holsinger Studio Collection" is applied
	  And I add ckey "uva-lib:1051794" to my folder
	  Given I am on the homepage
	  When I fill in "q" with "Bentivar"
	  And I choose "catalog_select_catalog"
	  And I press "search"
	  And I add ckey "uva-lib:84948" to my folder
	  Given I am on the homepage
	  When I fill in "q" with "Silver jubilee commemoration volume"
	  And I choose "catalog_select_catalog"
	  And I press "search"
	  And I add ckey "000000635" to my folder
	  Given I am on the homepage
	  When I fill in "q" with "How to train your dragon"
	  And I choose "catalog_select_catalog"
	  And I press "search"
	  And I add ckey "u5255974" to my folder
	  Given I am on the homepage
	  When I fill in "q" with "Map of Poor Mountain iron lands"
	  And I choose "catalog_select_catalog"
	  And I press "search"
	  And I add ckey "uva-lib:743707" to my folder
	  Given I am on the homepage
	  When I fill in "q" with "Valentinian II"
	  And I choose "catalog_select_catalog"
	  And I press "search"
	  And I add ckey "n1989_19_23" to my folder
	  Given I am on the homepage
	  When I fill in "q" with "Old times and hard times"
	  And I choose "catalog_select_catalog"
	  And I press "search"
	  And I add ckey "u5408148" to my folder
	  
	  
	  And I visit the folder page
	  Then I should see ckey "u4322506" in the folder
	  And I should see ckey "n14_1989_9" in the folder
	  And I should see ckey "pubtecumrsmas/bullmar/1984/00000035/00000003/art00022" in the folder
	  And I should see ckey "uva-lib:610693" in the folder
	  And I should see ckey "uva-lib:477191" in the folder
	  And I should see ckey "uva-lib:1051794" in the folder
	  And I should see ckey "uva-lib:84948" in the folder
	  And I should see ckey "uva-lib:477191" in the folder
	  And I should see ckey "000000635" in the folder
	  And I should see ckey "u5255974" in the folder
	  And I should see ckey "uva-lib:743707" in the folder
	  And I should see ckey "n1989_19_23" in the folder
	  And I should see ckey "u5408148" in the folder
	      
  Scenario: Remove an item from the folder
    Given I have ckey "u5076740" in my folder
    When I follow "Remove"
    Then I should see "Removed from Starred Items"
    And I should not see ckey "u5076740" in the folder
    
  Scenario: Clearing folder should mean you don't see items in the folder
    Given I have ckey "u4322506" in my folder
	  And I have ckey "u5075136" in my folder
	  And I follow "Clear Starred Items"
	  Then I should see "Cleared Starred Items"
	  And I should not see ckey "u4322506" in the folder
	  And I should not see ckey "u5075136" in the folder
	  
	Scenario: Do multiple citations when the folder has multiple items
	  Given I have ckey "u5076740" in my folder
	  And I have ckey "u5077466" in my folder
	  And I follow "Cite"
 	  Then I should see "Goldman, Jane. The Feminist Aesthetics of Virginia Woolf : Modernism, Post-impressionism and the Politics of the Visual. 1st pbk. ed. Cambridge, U.K.: Cambridge University Press, 2001."
 	  And I should see "Rhyner, Paula M. Emergent Literacy and Language Development : Promoting Learning In Early Childhood. New York: Guilford Press, 2009."
 	  
 	Scenario: Make sure the folder page doesn't bomb if there is no search session
 	  Given I am on the folder page
 	  # That's all that is needed -- it will fail to render if it's not right
 	  
 	Scenario: Don't show the tools if there are no items in the folder
 	  Given I am on the folder page
 	  Then I should not see the Starred Items tools

  Scenario: Show the tools if there are items in the folder
    Given I have ckey "u5076997" in my folder
 	  And I visit the folder page
 	  Then I should see the Starred Items tools

	Scenario: Cite article from folder
		Given I am on the homepage
		When I fill in "q" with "pickral odum benthic detritus"
		And I choose "catalog_select_articles"
		And I press "search"
		And I add ckey "pubtecumrsmas/bullmar/1984/00000035/00000003/art00022" to my folder
		And I visit the folder page
		And I follow "Cite"
		Then I should see "Odum, William E."
