Feature: Display Books
  In order to get all relevant information about a book
  As a user
  I want to see all of the proper fields from the marc record

  Scenario: formatting for a typical book
    Given I am on the document page for id u4856159
	  Then I should see a title of "Appropriation"
	  And I should see a related name of "Evans, David" with no role
	  And it should have a valid link to delicious bookmarks for id "u4856159"
	  
	Scenario: display part from MARC 245 n
	  Given I am on the document page for id u4248946
	  Then I should see a part of "The complete fourth season"
	  
	Scenario: display part from MARC 245 p
	  Given I am on the document page for id u4027731
	  Then I should see a part of "The complete second season"
	  
	Scenario: display part from both MARC 245 n and p
	  Given I am on the document page for id u28639
	  Then I should see a part of "Part I, From the mid-nineteenth century to the First World War. Series B, The Near and Middle East, 1856-1914"
	
  Scenario: tell the difference between original materials and photocopies 
    Given I am on the document page for id u2101338 
	  Then I should see a title of "Bright leaf, an account of a Virginia farm [manuscript] 1971"
	  And I should see a related name of "Garnett, Mary Ella Carr Brumfield, 1902-" with no role
	  And I should see "Reproduction Notes" data of "Photocopy."
	
  Scenario: format tables of contents properly
    Given I am on the document page for id u4391482
	  Then I should see a title of "The Golem"
	  And I should see a related name of "Neugroschel, Joachim" with no role
	  And I should see a table of contents
	  And the first item in the table of contents should be "The Golem or the miraculous deeds of Rabbi Leyb / Yudl Rosenberg"
  	And the last item in the table of contents should be "The Golem / H. Leivick"

#	Scenario: make sure book covers and their titles are appearing
#	  Given I am on the image page for id u4853537
#    Then I should see an image attribute "src" of "/catalog/u4853537/image.jpg"
#	  And I should see an image attribute "title" of "The last Divine office"
#	  And I should see an image attribute "alt" of "Cover image for The last Divine office"
	
	Scenario: make sure reproduction notes display
		Given I am on the document page for id u2109243
	  Then I should see "Reproduction Notes" data of "Also available on microfilm as Manuscript Division reel #M686.."
	  
	Scenario: reproduction notes should be joined into one line instead of split out as multiple lines
	  Given I am on the document page for id u4375173
	  Then I should see "Reproduction Notes" data of "Microfilm. London : British Library Reference Division, Reproduction Section, 2006. 1 microfilm reel; 35 mm."
	  
	Scenario: make sure related names appear correctly with MARC 710
	  Given I am on the document page for id u4482328
	  Then I should see a related name "Columbia University School of Law"

  Scenario: make sure related names appear correctly with MARC 110 and MARC 700
    Given I am on the document page for id u1939418
	  Then I should see a related name "University of Virginia Director of Student Affairs and Admissions"
	  And I should see a related name "Bice, Raymond C, b. 1896."
	  
	Scenario: make sure related names appear correctly with MARC 100 and MARC 240
	  Given I am on the document page for id u1225142
	  Then I should see a related name "Bach, Johann Sebastian, 1685-1750."
	  And I should see a related name "Bach, Johann Sebastian, 1685-1750. Kunst der Fuge; arr."
	  
	Scenario: related names
	  Given I am on the document page for id u4883220
	  Then I should see a related name "Sibelius, Jean, 1865-1957."
	  And I should see a related name "Sibelius, Jean, 1865-1957. Concerto, violin, orchestra, op. 47, D minor."
	  And I should see a related name "Tchaikovsky, Peter Ilich, 1840-1893."
	  And I should see a related name "Tchaikovsky, Peter Ilich, 1840-1893. Concertos, violin, orchestra, op. 35, D major."
	  
	Scenario: related names should include 711-c
	  Given I am on the document page for id u3647875
      Then I should see a related name "International Conference on Primary Care (Alma Ata, USSR : 1978)"
    
    Scenario: related names should include 240 o
	  Given I am on the document page for id u2114442
      Then I should see a related name "Beethoven, Ludwig van, 1770-1827. Symphonies; arr."
  
 # data has changed.  Unable to locate comparable example  
 #   Scenario: related names should include 240 f
 #	  Given I am on the document page for id u2140007
 #     Then I should see a related name "Beethoven, Ludwig van, 1770-1827. Works. 1949"
    
    Scenario: related names should include 240 l,s
	  Given I am on the document page for id u3785251
      Then I should see a related name "Verdi, Giuseppe, 1813-1901. Rigoletto. Libretto. French"
      
    Scenario: related names should include 100 c
	  Given I am on the document page for id u1792787
      Then I should see a related name "Thomas (Anglo-Norman poet)"
                                      
	Scenario: make sure Publisher no. appears correctly
	  Given I am on the document page for id u3916445
	  Then I should see a title of "Buffy, the vampire slayer [videorecording] : the complete first season on DVD"
	  And I should see "Publisher no." data of "2000828 Twentieth Century Fox Home Entertainment"
	  
	Scenario: make sure Cartographic Math Data appears correctly
	  Given I am on the document page for id u3523973
	  Then I should see "Mathematical info" data of "Scale [ca. 1:630,000]."
	  
	Scenario: show original version information
	  Given I am on the document page for id u4758292
	  Then I should see "Original version" data of "Original version appeared in : Relation of Maryland : together with a map of the countrey the conditions of plantation  his majesties charter to the Lord Baltemore translated into English. London: master William Peasley Esq. ... 1635. p. 12."
	  
	Scenario: do not show ISBN for musical scores
	  Given I am on the document page for id u220329
	  Then I should not see "ISBN"
	  
	Scenario: show full ISBN values in display (including 020a)
	  Given I am on the document page for id u5169872
	  Then I should see "9780521767088 (hardback), 0521767083 (hardback)"
	  
	Scenario: do not show 020c in ISBN
	  Given I am on the document page for id u4375080
	  Then I should see "0307275558 (pbk.),"
	  
	Scenario: show organization/arrangement
	  Given I am on the document page for id u4009841
	  Then I should see "Organization / Arrangement" data of "I. Literary manuscripts. -- II. Correspondence. -- III. Correspondence and documents pertaining to Kokoon Art Club Show. -- IV. Miscellany."
	  
	Scenario: show with note
	  Given I am on the document page for id u301933
	  Then I should see a note "With: Monteverdi, C.  Madrigals. Selections."
	  
	Scenario: show cited in
	  Given I am on the document page for id u4856074
	  Then I should see "Cited in" data of "Cross, W.L., Hist. of Henry Fielding, v. 3, p. 291."
  
  Scenario: show other forms
    Given I am on the document page for id u2105231
    Then I should see "Other forms" data of "Also available on microfilm as Manuscript Division reel #M-1319."
    
  Scenario: show location of originals
    Given I am on the document page for id u4229000
    Then I should see "Location of originals" data of "Originals privately owned."
    
  Scenario: show language
    Given I am on the document page for id u4758292
    Then I should see "Language" data of "In Latin and English ; Coat of arm banners in Italian and French."
  
  Scenario: make sure uniform title appears correctly
    Given I am on the document page for id u2057213
    Then I should see "Uniform title" data of "Bible. English. Authorized 1748."
    Given I am on the document page for id u2499441
    Then I should see "Uniform title" data of "Symphonies, no. 1, op. 21, C major."
    Given I am on the document page for id u2114442
    Then I should see "Uniform title" data of "Symphonies; arr."
  
  Scenario: Display Title history note
    Given I am on the document page for id u4318366
    Then I should see "Title history note" data of "Merger of: The Museum of the Confederacy newsletter and Dispatches."
    
  Scenario: Display Previous title
    Given I am on the document page for id u504272
    Then I should see "Previous title" data of "Literary digest"
    
  Scenario: Display Later title
    Given I am on the document page for id u4215661
    Then I should see "Later title" data of "Museum of the Confederacy. Magazine"
    
  Scenario: Display access restriction
    Given I am on the document page for id u1749211
    Then I should see "Access restriction" data of "No access without written permission of Garrett Epps."
    
  Scenario: Display biographical note
    Given I am on the document page for id u1749211
    Then I should see "Biographical note" data of "American author."
    
  Scenario: Make sure related name doesn't appear twice
    Given I am on the document page for id u4884553
    Then the first related name should be "Turrentine, Stanley (Performer)"
    And the second related name should be "Scott, Shirley, 1934-2002. (Performer)"
    
  Scenario: Display series title facet
    Given I am on the document page for id u1180846
    Then I should see "Series" data of "The Hale memorial sermon"

#  this record doesn't exist in the index anymore    
#  Scenario: Display "Access online" for MARC 856, Indicator 1 = "4", Indicator 2 = " "
#    Given I am on the document page for id u4879544
#    Then I should see "Access Online"
 
#  this record doesn't exist in the index anymore    
#  Scenario: Display "Access online" for MARC 856, Indicator 1 = "4", Indicator 2 = "0"
#    Given I am on the document page for id u4764243
#    Then I should see "Access Online"
    
  Scenario: Display related resources for MARC 856, Indicator 1 = "4", Indicator 2 = "2"
    Given I am on the document page for id u2397693
    Then I should see "Related resources" data of "GUIDE TO THE COLLECTION AVAILABLE ONLINE"
            
  Scenario: show related resources" for MARC 856, Indicator 1 = " ", Indicator 2 = "7"
    Given I am on the document page for id u1749045
    Then I should see "Related resources" data of "GUIDE TO THE COLLECTION AVAILABLE ONLINE"    

	Scenario: show related resources and make sure label uses subfields 3 and z
		Given I am on the document page for id u3712091
		Then I should see "Related resources" data of "V. 1, PDF version: Adobe Acrobat Reader required"
        
  Scenario: show related resources for MARC 856, Indicator 1 = "7", Indicator 2 = " "
    Given I am on the document page for id u2645641
    Then I should see "Related resources" data of "Contains updates and articles supplemental to print version"
  
  Scenario: do not do a z3950 lookup for online-only items (location_facet = "Internet materials")
    Given I am on the document page for id u4998050
    Then I should not see z3950 availability
    
  Scenario: do not do a z3950 lookup for online-only items (source_facet = "Digital Library")
    Given I am on the document page for id uva-lib:120848
    Then I should not see z3950 availability
    
  Scenario: Make sure items with no MARC-245 display without error
    Given I am on the document page for id u4878185
    Then I should see "Tales from five thousand years of Chinese history"
    
  Scenario: Include zotero citation
    Given I am on the document page for id u696734
    Then I should see a zotero citation

  Scenario: Do not display HIDDEN records
    Given I am on the document page for id u63
    Then I should see "Sorry, you seem to have encountered an error."
    
  Scenario: Do not display HIDDEN_OVERRIDE records
    Given I am on the document page for id u200
    Then I should see "Sorry, you seem to have encountered an error."
    
  Scenario: Display error for documents that don't exist
    Given I am on the document page for id asdfasdf
    Then I should see "Sorry, you seem to have encountered an error."
    
  Scenario: Include Google Preview javascript
    Given I am on the document page for id u5057315
    Then I should see "api_url"
    And I should see "ISBN:9780772720351"
    And I should see "ISBN:0772720355"
    And I should see "LCCN:2008371187"
    And I should see "OCLC:145429254"
        
  Scenario: Include technical details
    Given I am on the document page for id u5057315
    And I should see "Access in Virgo Classic"
    And subfield "001" should have a value of "u5057315"
  
  Scenario: Include Format
    Given I am on the document page for id u1990144
    Then I should see "Format" data of "Book"
  
  Scenario: Include Description
    Given I am on the document page for id u1990144
    Then I should see "Description" data of "224 p. ; 22 cm."
    
  Scenario: Include target audience
    Given I am on the document page for id u5067630
    Then I should see "Target audience" data of "For primary school children."

   Scenario: Make sure all related subfields included for conference papers(c)
     Given I am on the document page for id u14285 
     Then I should see a related name "Symposium on Rheumatic Diseases (1964 : Delhi)"

   Scenario: Make sure all related subfields included for conference papers(q)
   Given I am on the document page for id u22877
   Then I should see a related name "National Conference on Microcomputers in Civil Engineering (1st : 1983 Nov 1-3 : Orlando, Fla.)"
   And I should see a related name "Carroll, Wayne E (Wayne Edward), 1945-"

  Scenario: Make sure html title is set to document title
    Given I am on the document page for id u1914097
    Then I should see the title "The papers of William H. Seward - University of Virginia Library"
  
  Scenario: Make sure html title includes document subtitle
    Given I am on the document page for id u5006681
    Then I should see the title "Literary research and British modernism: strategies and sources - University of Virginia Library"
    
  Scenario: Make sure we can view the item as xml
    Given I am on the xml page for id u5006681
    Then I should see "SIRSI"
    
  Scenario: Make sure contents (MARC 505) is formatted properly, with no trailing periods
    Given I am on the document page for id u5188121
    Then I should see "1891: Ashby, N.B. Riddle of the Sphinx. Des Moines, Iowa, Industrial Publishing Company"
    And I should see "1898: Keenan, H.F. Conflict with Spain. [S.l., s.n.]"
    
  Scenario: Make sure citation renders properly even if primary author isn't right in MARC record
    # the code expects a subfield "a", which this record doesn't have
    # <datafield tag="100" ind1=" " ind2=" ">
    #   <subfield code=" "> A. </subfield>
    #   <subfield code="q"> (Henry Arthington</subfield>
    # </datafield>
    Given I am on the citation page for id u3869450
    # that's all that is needed for this test -- if it doesn't work, the page won't render
    
  Scenario: Make sure citation renders properly even if name isn't right in MARC record
    # the code expects there to be content in subfield a, which this record doesn't
    # <datafield tag="100" ind1=" " ind2=" ">
    #   <subfield code="a"/>
    # </datafield>
    Given I am on the citation page for id u5074985
    # that's all that is needed for this test -- if it doesn't work, the page won't render
    
  Scenario: Make sure zotero inclusion doesn't break the page if the document has no format_facet
    Given I am on the document page for id u3615944
    # that's all that is needed for this test -- if it doesn't work, the page won't render
    
  Scenario: display date coverage from MARC 245 f
	  Given I am on the document page for id u3833912
	  Then I should see date coverage of "1904-1915."
	  
  Scenario: display date bulk coverage from MARC 245 g
	  Given I am on the document page for id u4298149
	  Then I should see date bulk coverage of "(bulk 2002-2003)"
	  
  Scenario: display form from MARC 245 k
	  Given I am on the document page for id u1748792
	  Then I should see form of "typescript and proofs"
	  
	Scenario: Include Publication History
	  Given I am on the document page for id u235
	  Then I should see "Publication history" data of "Vol. 154, no. 1 (Jan. 1984)-"
  
  Scenario: Convert < and > to appropriate HTML entities
    Given I am on the document page for id u3342479
    Then I should see "<Oct. 8, 1990->"
    
  Scenario: display responsibility statement from MARC 100 a b & c
	Given I am on the document page for id u558482 
	Then I should see a responsibility statement of "Melville, Herman,"
	
  Scenario: display responsibility statement from MARC 110 a b
	Given I am on the document page for id u1599649  
	Then I should see a responsibility statement of "United States. Congress. Joint Committee on the Library."

  Scenario: Display MARC 730 fields in one line
	Given I am on the document page for id u5336635
	Then I should see "Related title" data of "Architekt. Supplement."
	
 Scenario: show format for dl_books
    Given I am on the document page for id uva-lib:602113
    Then I should see "Format" data of "Online; Book"	
