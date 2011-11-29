Then /^the result display for ckey (.+) should have a title of "([^\"]*)"$/ do |ckey, value|
  response.should have_tag("div#Doc#{ckey} div dl.metadata dd.titleField a", :text => value)
end

Then /^the result display for ckey (.+) should have a location of "([^\"]*)"$/ do |ckey, value|
  string = "div#Doc#{ckey} div dl.metadata dd.locationField"
  response.should have_tag(string, :text => value)
end

Then /^the result display for ckey (.+) should have an online access link of "([^\"]*)"$/ do |ckey, value|
  string = "div#Doc#{ckey} div dl.metadata dd.onlineAccessField"
  response.should have_tag(string, :text => /^.*#{value}.*$/)
end

Then /^the result display should have the full text view link of (.+)$/i do |value|
  response.should have_tag("a[href*=?]", /^.*#{value}.*$/)
end

Then /^the result display for ckey (.+) should have the call number "([^\"]*)"$/ do |ckey, value|
  string = "div#Doc#{ckey} div dl.metadata dd.callNumberField"
  response.should have_tag(string, :text => /^.*#{value}.*$/)
end

Then /^the result display for ckey (.+) should not have the call number "([^\"]*)"$/ do |ckey, value|
  string = "div#Doc#{ckey} div dl.metadata dd.callNumberField"
  response.should_not have_tag(string, :text => /^.*#{value}.*$/)
end

Then /^the result display for ckey (.+) should not have a call number$/ do |ckey|
  string = "div#Doc#{ckey} div dl.metadata dd.callNumberField"
  response.should_not have_tag(string)
end

Then /^the result display for ckey (.+) should have availability$/ do |ckey|
  string = "div#Doc#{ckey} div dl.metadata dd.availability"
  response.should have_tag(string)
end

Then /^the result display for ckey (.+) should not have availability$/ do |ckey|
  string = "div#Doc#{ckey} div dl.metadata dd.availability"
  response.should_not have_tag(string)
end

Then /^I should see a publication date of (.+) for ckey (.+)$/ do |date, ckey|
  string = "div#Doc#{ckey} div dl.metadata dd.formatField"
  response.should have_tag(string, :text => date)
end

Then /^I should not see a publication date for ckey (.+)$/ do |ckey|
  string = "div#Doc#{ckey} div dl.metadata dt"
  response.should_not have_tag(string, :text => 'Publication Date')
end


