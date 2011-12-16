Then /^I should see a login link$/ do
  page.should have_selector("a#login")
end

When /^I click the "([^\"]*)" link$/ do |link_name|
  click_link(link_name)
end

When /^I click the "([^\"]*)" link for ckey "([^\"]*)"$/ do |arg1, arg2|
  pending
end

Then /^I should be logged in$/ do
  page.should have_selector("ul.account_links li a", :text => "Sign out")
end

Then /^I should not be logged in$/ do
  page.should_not have_selector("p.login", :text => /^Logged in as(.*)/)
end

Then /^I should see an add to favorites link$/ do
  page.should have_selector("a.submitForm.iconHeartSmall", :text => "Add to Favorites")
end

Then /^I should see an add to favorites link for ckey "([^\"]*)"$/ do |arg1|
  page.should have_selector("div#Doc#{arg1} a.submitForm.iconHeartSmall", :text => "Add to Favorites")
end

Then /^none of the results should be in my favorites$/ do
  page.should_not have_selector("div.tools form.addUserBookmarkForm", :text => /^This is in your(.*)/)
end

Then /^I should see that an item has been added to my favorites$/ do
  page.should have_selector("div.tools", :text => /^This is in your(.*)/)
end

