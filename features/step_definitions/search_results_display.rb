Then /^the result display for ckey (.+) should have a title of "([^\"]*)"$/ do |ckey, value|
  page.should have_selector("div#Doc#{ckey} div dl.metadata dd.titleField a", :text => value)
end

Then /^the result display for ckey (.+) should have a location of "([^\"]*)"$/ do |ckey, value|
  string = "div#Doc#{ckey} div dl.metadata dd.locationField"
  page.should have_selector(string, :text => value)
end

Then /^the result display for ckey (.+) should have an online access link of "([^\"]*)"$/ do |ckey, value|
  string = "div#Doc#{ckey} div dl.metadata dd.onlineAccessField"
  page.should have_selector(string, :text => /^.*#{value}.*$/)
end

Then /^the result display should have the full text view link of (.+)$/i do |value|
  page.should have_selector("a[href*=?]", /^.*#{value}.*$/)
end

Then /^the result display for ckey (.+) should have the call number "([^\"]*)"$/ do |ckey, value|
  string = "div#Doc#{ckey} div dl.metadata dd.callNumberField"
  page.should have_selector(string, :text => /^.*#{value}.*$/)
end

Then /^the result display for ckey (.+) should not have the call number "([^\"]*)"$/ do |ckey, value|
  string = "div#Doc#{ckey} div dl.metadata dd.callNumberField"
  page.should_not have_selector(string, :text => /^.*#{value}.*$/)
end

Then /^the result display for ckey (.+) should not have a call number$/ do |ckey|
  string = "div#Doc#{ckey} div dl.metadata dd.callNumberField"
  page.should_not have_selector(string)
end

Then /^the result display for ckey (.+) should have availability$/ do |ckey|
  string = "div#Doc#{ckey} div dl.metadata dd.availability"
  page.should have_selector(string)
end

Then /^the result display for ckey (.+) should not have availability$/ do |ckey|
  string = "div#Doc#{ckey} div dl.metadata dd.availability"
  page.should_not have_selector(string)
end

Then /^I should see a publication date of (.+) for ckey (.+)$/ do |date, ckey|
  string = "div#Doc#{ckey} div dl.metadata dd.formatField"
  page.should have_selector(string, :text => date)
end

Then /^I should not see a publication date for ckey (.+)$/ do |ckey|
  string = "div#Doc#{ckey} div dl.metadata dt"
  page.should_not have_selector(string, :text => 'Publication Date')
end


