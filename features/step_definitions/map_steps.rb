Then /^I should see a map link of "([^\"]*)"$/ do |url|
 response_body.should have_selector("a[href='#{ url }']")
end

Then /^I should not see a map link$/ do
 response_body.should_not have_selector(".maplink")
end
