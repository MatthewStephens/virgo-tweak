Then /^I should see availability data of "([^\"]*)"$/ do |status|
  page.should have_selector("span", :text => "#{status}")
end

Then /^I should see online availability of "([^\"]*)"$/ do |availability|
  page.should have_selector("div#onlineAvailability a", :text => "#{availability}")
end

Then /^I should see a library "([^"]*)"$/ do |arg1|
  page.should have_selector("td.holding_data.library_name", :text => /#{arg1}/)
end

Then /^I should not see a library "([^"]*)"$/ do |arg1|
  page.should_not have_selector("td.holding_data.library_name", :text => /#{arg1}/)
end

Then /^I should see a current location "([^\"]*)"$/ do |arg1|
  page.should have_selector("td.holding_data.location_name", :text => /#{arg1}/)
end

Then /^I should not see a current location "([^\"]*)"$/ do |arg1|
  page.should_not have_selector("td.holding_data.location_name", :text => arg1)
end

Then /^I should see the availability value"([^\"]*)"$/ do |arg1|
  page.should have_selector("td.holding_data.availability", :text => /#{arg1}/)
end

Then /^I should not see the availability value "([^\"]*)"$/ do |arg1|
  page.should_not have_selector("td.holding_data.availability", :text => arg1)
end

Then /^I should not see a holding call number "([^\"]*)"$/ do |arg1|
  page.should_not have_selector("td.holding_data.call_number", :text => arg1)
end

Then /^I should see a summary text "([^\"]*)"$/ do |arg1|
  page.should have_selector("div.summaryText", :text => arg1)
end

Then /^I should see a summary note "([^\"]*)"$/ do |arg1|
  page.should have_selector("div.summaryNote", :text => arg1)
end

Then /^I should see a holding header "([^\"]*)"$/ do |arg1|
  page.should have_selector("div.holdingHeader", :text => arg1)
end

Then /^the first holding library should be "([^\"]*)"$/ do |arg1|
  page.should have_selector("div.first h3", :text => arg1)
end


When /^I visit the status page for the first item$/ do
  #  <div class="document clearFix" id="Docu461865"> is the current format of a document div
    first_doc_link = response.body.scan(/<div class=\"document clearFix\" id=\"Doc(.*)\">/)[0]
    visit status_catalog_path(first_doc_link)
end
