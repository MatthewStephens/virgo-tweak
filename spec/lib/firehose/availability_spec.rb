require 'spec_helper'

describe Firehose::Availability do
  
  class FakeAvailability < Firehose::Availability
    def initialize(document, catalog_item)
      @document, @_catalog_item = document, catalog_item
      @_summary_libraries = []
      set_summary_holdings
    end
  end
  
  describe "set_summary_holdings" do
    it "should initialize summaries as an array" do
      document = mock("Document")
      document.stubs(:values_for).returns([])
      catalog_item = mock("CatalogItem")
      a = FakeAvailability.new(document, catalog_item)
      a._summary_libraries.should == []
    end
    it "should create the summaries" do
      document = mock("Document")
      # u1306920
      document.stubs(:values_for).returns(["Alderman|Stacks||CURRENT ISSUES HELD IN PERIODICALS ROOM|", "Alderman|Stacks|v.1-10  (1923-1927)||Library has", "Alderman|Stacks|v.11:no.1-8,10-17,20-23,26  (1928)||Library has", "Alderman|Stacks|v.12-33  (1928-1939),||Library has", "Alderman|Stacks|v.34  (1939:July-Sept.),||Library has", "Alderman|Stacks|v.35-167  (1940-2006 Jun)||Library has", "Alderman|Stacks|v.168:no.1-11,13-26  (2006: Jul.-Sept.11,Sep.25-2007:Jan.1),||Library has", "Alderman|Stacks|v.169-174  (2007:Jan.15-2010:Jan.4)||Library has", "Alderman|Stacks|v.175  (2010:Jan.11-June 28)||Library has", "Alderman|Stacks|v.176:no.1-26  (2010:July 5-2011:Jan.3)||Library has", "Alderman|Stacks|v.177:no.1-8  (2011:Jan.10-Feb.(||Library has", "Alderman|Stacks|v.177, no.9-v.178, no.8 (2011:Mar 07-Aug 29)||Library has", "Clemons|Current Journals||3 months kept.  For earlier issues see other                 locations/holdings.|", "Clemons|Current Journals|v.176, no.26-v.178, no.8||Library has", "Ivy|Stacks|v.17-32  (1931-1938),||Library has", "Ivy|Stacks|v.33/34   (1939:June-Dec.),||Library has", "Ivy|Stacks|v.35-44  (1940-1944),||Library has", "Ivy|Stacks|v.45/46  (1945:Jan.-Sept.),||Library has", "Ivy|Stacks|v.47/48  (1946:Jun.-Dec.),||Library has", "Ivy|Stacks|v.49/50  (1947),||Library has", "Ivy|Stacks|v.51  (1948:Jan.-Mar.),||Library has", "Ivy|Stacks|v.52   (1948:July-Dec.),||Library has", "Ivy|Stacks|v.53-68  (1949-1956),||Library has", "Ivy|Stacks|v.69/70  (1957:Apr.-Dec.),||Library has", "Ivy|Stacks|v.71-74  (1958-1959),||Library has", "Ivy|Stacks|v.75/76   (1960:June-Dec.),||Library has", "Ivy|Stacks|v.77-80  (1961-1962),||Library has", "Ivy|Stacks|v.81  (1963:Jan.-June),||Library has", "Ivy|Stacks|v.83-93  (1964-1969),||Library has", "Ivy|Stacks|v.96  (1971:Oct.-Dec.),||Library has", "Ivy|Stacks|v.97/100  (1972),||Library has", "Ivy|Stacks|v.101-106  (1973-1975),||Library has", "Ivy|Stacks|v.107/108  (1976: Apr.-Dec.),||Library has", "Ivy|Stacks|v.110   (1977:July-Dec.),||Library has", "Ivy|Stacks|v.111  (1978: Jan.-Mar.)||Library has"])
      catalog_item = mock("CatalogItem")
      a = FakeAvailability.new(document, catalog_item)
      a._summary_libraries.length.should == 3
      a._summary_libraries[0].name.should == 'Alderman'
      a._summary_libraries[0].summary_locations[0].name.should == 'Stacks'
      a._summary_libraries[0].summary_locations[0].summaries[0].text.should == ''
      a._summary_libraries[0].summary_locations[0].summaries[0].note.should == 'CURRENT ISSUES HELD IN PERIODICALS ROOM'
      a._summary_libraries[0].name.should == 'Alderman'
      a._summary_libraries[0].summary_locations[0].name.should == 'Stacks'
      a._summary_libraries[0].summary_locations[0].summaries[1].text.should == 'v.1-10  (1923-1927)'
      a._summary_libraries[0].summary_locations[0].summaries[1].note.should == ''
      a._summary_libraries[1].name.should == 'Clemons'
      a._summary_libraries[1].summary_locations[0].name.should == 'Current Journals'
      a._summary_libraries[1].summary_locations[0].summaries[0].text.should == ''
      a._summary_libraries[1].summary_locations[0].summaries[0].note.should == '3 months kept.  For earlier issues see other                 locations/holdings.'
    end
  end
  describe "summary libraries" do
    it "should put ivy, blandy, mt. lake, and at sea after others" do
      document = mock("Document")
      #u50581
      document.stubs(:values_for).returns(["Brown SEL|Journals|v.42-85  (1961-2004)||Library has", "Blandy Experimental Farm|Farm Library|v.6-13  (1925-1932),||Library has", "Blandy Experimental Farm|Farm Library|v.27-48  (1946-1967),||Library has", "Blandy Experimental Farm|Farm Library|v.49 no.2,4  (1968),||Library has", "Blandy Experimental Farm|Farm Library|v.50  (1969),||Library has", "Blandy Experimental Farm|Farm Library|v.51 no.1-2,4  (1970),||Library has", "Blandy Experimental Farm|Farm Library|v.56  (1975),||Library has", "Blandy Experimental Farm|Farm Library|v.64-69  (1983-1988),||Library has", "Blandy Experimental Farm|Farm Library|v.70 no.2-4  (1989),||Library has", "Blandy Experimental Farm|Farm Library|v.71  (1990)||Library has", "Blandy Experimental Farm|Farm Library|INDEXES:v.1/20-41/50  (1919/1939-1960/1969)||Library has", "Mountain Lake|Biological Station Library|v.7-17  (1926-1936)||Library has", "Mountain Lake|Biological Station Library|v.19:no.2-4  (1938)||Library has", "Mountain Lake|Biological Station Library|v.26:no.1-2,4  (1945)||Library has", "Mountain Lake|Biological Station Library|v.27  (1947)||Library has", "Mountain Lake|Biological Station Library|v.28:no.1-2,4  (1947)||Library has", "Mountain Lake|Biological Station Library|v.29:no.1  (1948)||Library has", "Mountain Lake|Biological Station Library|v.30-82  (1949-2001),||Library has", "Mountain Lake|Biological Station Library|v.83:no.2-4  (2002),||Library has", "Mountain Lake|Biological Station Library|v.84:no.1-4  (2003),||Library has", "Mountain Lake|Biological Station Library|v.85:no.1-3  (2004),||Library has", "Mountain Lake|Biological Station Library|v.86  (2005)||Library has", "Mountain Lake|Biological Station Library|TEN YEAR INDEX VOL 71-80 (1990-1999)||Index text holdings", "Mountain Lake|Biological Station Library|v.85, no.4 (2004:Aug)||Library has", "Mountain Lake|Biological Station Library|v.85, no.5-v.87, no.1 (2004:Oct-2006:Feb)||Library has", "Ivy|Stacks|v.1-25  (1919/1920-1944)||Library has", "Ivy|Stacks|v.25-35 (1944-1954)||Library has"])
      catalog_item = mock("CatalogItem")
      a = FakeAvailability.new(document, catalog_item)
      a.summary_libraries[0].name.should == "Brown SEL"
      a.summary_libraries[1].name.should == "Ivy"
      a.summary_libraries[2].name.should == "Blandy Experimental Farm"
      a.summary_libraries[3].name.should == "Mountain Lake"
    end
    it "should alphabetize the libraries" do
      document = mock("Document")
      # u505266
      document.stubs(:values_for).returns(["Clemons|Stacks|v.12-14  (1983-1985),||Library has", "Clemons|Stacks|v.15:no.3-4 (1986)||Library has", "Clemons|Stacks|v.16-33  (1987-2004)||Library has", "Alderman|Stacks|v.9-11  (1980-1982)||Library has", "Alderman|Stacks|v.34-37 (2005-2008)||Library has"])
      catalog_item = mock("CatalogItem")
      a = FakeAvailability.new(document, catalog_item)
      a.summary_libraries[0].name.should == "Alderman"
      a.summary_libraries[1].name.should == "Clemons"
    end
  end

  
end