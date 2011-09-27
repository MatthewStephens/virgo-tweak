Then /^I should see a login link$/ do
  response.should have_tag("a#login")
end

When /^I click the "([^\"]*)" link$/ do |link_name|
  click_link(link_name)
end

When /^I click the "([^\"]*)" link for ckey "([^\"]*)"$/ do |arg1, arg2|
  pending
end

Then /^I should be logged in$/ do
  response.should have_tag("ul.account_links li a", :text => "Sign out")
end

Then /^I should not be logged in$/ do
  response.should_not have_tag("p.login", :text => /^Logged in as(.*)/)
end

Then /^I should see an add to favorites link$/ do
  response.should have_tag("a.submitForm.iconHeartSmall", :text => "Add to Favorites")
end

Then /^I should see an add to favorites link for ckey "([^\"]*)"$/ do |arg1|
  response.should have_tag("div#Doc#{arg1} a.submitForm.iconHeartSmall", :text => "Add to Favorites")
end

Then /^none of the results should be in my favorites$/ do
  response.should_not have_tag("div.tools form.addUserBookmarkForm", :text => /^This is in your(.*)/)
end

Then /^I should see that an item has been added to my favorites$/ do
  response.should have_tag("div.tools", :text => /^This is in your(.*)/)
end

Then /^print$/ do
  puts response.body
end

