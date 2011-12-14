Then /^the index display for "([^\"]*)" should have a title of "([^\"]*)"$/ do |ckey, title|
  page.should have_selector("div#Doc#{ckey} div dl dd a", :text => title )
end

Then /^I should see publication data of "([^\"]*)"$/ do |arg1|
  page.should have_selector("dt", :text => "Publication")
  page.should have_selector("dd", :text => arg1)
end

Then /^I should see a track list$/ do
  page.should have_selector("dt", :text => "Track list")
end

Then /^I should not see a track list$/ do
  page.should_not have_selector("dt", :text => "Track list")
end

Then /^the first track should be "([^\"]*)"$/ do |track|
  page.should have_selector("dd ul li:first-of-type", :text => track)
end

Then /^the last track should be "([^\"]*)"$/ do |track|
  page.should have_selector("dd ul li:last-of-type", :text => track)
end

Then /^I should see the track "([^\"]*)" as track ([^\"]*)$/ do |track, track_no|
  page.should have_selector("dd ul li:nth-child(#{track_no})", :text => track)
end

Then /^I should see a related name of "([^\"]*)" with a role of "([^\"]*)"$/ do |name, role|
  page.should have_selector("div#relatedNames ul li a", :text => /#{name}( +)\(#{role}\)/)  
end

Then /^I should see a related name of "([^\"]*)" with no role$/ do |name|
  page.should have_selector("div#relatedNames ul li a", :text => "#{name}")
end

Then /^I should see a performer named "([^\"]*)"$/ do |name|
  page.should have_selector("dt", :text => "Performer(s)")
  page.should have_selector("dd ul li", :text => name)
end

Then /^I should see a Publisher\/plate no. "([^\"]*)"$/ do |name|
  page.should have_selector("dt", :text => "Publisher/plate no.")
  page.should have_selector("dd ul li", :text => name)
end
