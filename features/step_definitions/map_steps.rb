Then /^I should see a map link of "([^\"]*)"$/ do |url|
 page.should have_selector("a[href='#{ url }']")
end

Then /^I should not see a map link$/ do
 page.should_not have_selector(".maplink")
end
