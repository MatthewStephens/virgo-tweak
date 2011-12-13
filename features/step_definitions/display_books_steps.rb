Then /^I should see a title of "([^\"]*)"$/ do |title|
  response.should have_selector("h1#titleField", :text => title)
end

Then /^I should see a part of "([^\"]*)"$/ do |title|
  response.should have_selector("span.documentPart", :text => title)
end

Then /^I should see a table of contents$/ do
  has_details_label?("Contents")
end

Then /^the first item in the table of contents should be "([^\"]*)"$/ do |toc_item|
  response.should have_selector("dd ul li:first-of-type", :text => toc_item)
end

Then /^the last item in the table of contents should be "([^\"]*)"$/ do |toc_item|
  response.should have_selector("dd ul li:last-of-type", :text => toc_item)
end

Then /^the first related name should be "([^\"]*)"$/ do |name|
  response.should have_selector("div#relatedNames ul li:first-of-type", :text => name)
end

Then /^the second related name should be "([^\"]*)"$/ do |name|
  response.should have_selector("div#relatedNames ul li:nth-of-type(2)", :text => name)
end

Then /^it should have a valid link to delicious bookmarks for id "([^\"]*)"$/ do |id|
  item_path = url_for(:controller => 'catalog', :action => 'show', :id => id, :only_path => false)
  url = "http://del.icio.us/post?url=#{item_path}&title=Appropriation"
  response.should have_selector("li.delicious a", :text => "Export (Delicious)")
  #response.should have_selector("a[href=#{url}]")
end

Then /^I should see an image attribute "([^\"]*)" of "([^\"]*)"$/ do |attribute, value|
  response.should have_selector("img[#{attribute}=#{value}]")
end

Then /^I should see a responsibility statement of "([^\"]*)"$/ do |arg1|
  response.should have_selector("div#respStmtField div", :text => arg1)
end

Then /^I should see a related name "([^\"]*)"$/ do |name|
  response.should have_selector("div#relatedNames ul li", :text => name)
end

Then /^I should see a note "([^\"]*)"$/ do |arg1|
  has_details_label_and_list_value?("Notes", arg1).should be_true
end

Then /^I should see a textual holdings "([^\"]*)"$/ do |arg1|
  has_details_label_and_list_value?("Textual Holdings", arg1).should be_true
end

# this doesn't really test to see that the dt and dd go together
Then /^I should see a Publisher no. "([^\"]*)"$/ do |name|
  has_details_label_and_list_value?("Publisher no.", name).should be_true
end

Then /^I should not see a call number "([^\"]*)"$/ do |arg1|
  response.should_not have_selector("div.holdingCallNumber", :text => "Call #: #{arg1}")
end

# this doesn't really test to see that the dt and dd go together
Then /^I should see "([^\"]*)" data of "([^\"]*)"$/ do |label, value|
  has_details_label_and_value?(label, value).should be_true
end

Then /^I should not see z3950 availability$/ do
  response.should_not have_selector("div#physicalAvailability")
end

Then /^I should see a zotero citation$/ do
  response.should have_selector("span.Z3988")
end

# this doesn't really test that the subfield and value are paired together
# it just tests that both are present
Then /^subfield "([^\"]*)" should have a value of "([^\"]*)"$/ do |arg1, arg2|
  response.should have_selector("span.tag", arg1)
  response.should have_selector("span.control_field_values", arg2)
end

Then /^I should see the title "([^\"]*)"$/ do |arg1|
  response.should have_selector("title", arg1)
end

Then /^I should see date coverage of "([^\"]*)"$/ do |title|
  response.should have_selector("span.documentDate_coverage", :text => title)
end

Then /^I should see date bulk coverage of "([^\"]*)"$/ do |title|
  response.should have_selector("span.documentDate_bulk_coverage", :text => title)
end

Then /^I should see form of "([^\"]*)"$/ do |title|
  response.should have_selector("span.documentForm", :text => title)
end

# determines if the details section includes the specified label
def has_details_label?(label)
  details_hash.has_key?(label) rescue false
end

# determines if the details section has the specified label with the specified value
def has_details_label_and_value?(label, value)
  details_hash[label].include?(value) rescue false
end

# determines if the details section has a label with a list that contains the specified value
def has_details_label_and_list_value?(label, value)
  details_hash[label].first =~ /#{value}/ ? true : false
end


# use tableish to parse dl; format will be [[dt, dd, dd], [dt2, dd, dd, dd]]
# then turn that into a hash of format { dt => [dd, dd], dt2 => [dd, dd, dd]}
def details_hash
  t = tableish("div#details dl dt", lambda{|dt| [dt, dt.next.next]})
  t = tableish("dl.metadata dt", lambda{|dt| [dt, dt.next.next]}) if t.empty?
  hash = {}
  t.each do |dd|
    dd.each { |val| 
      val.strip!
      # clean off tabs so that it reads better
      val.tr!("\\\t", '')
    }
    key = dd.shift
    hash[key] = dd
  end
  return hash
end