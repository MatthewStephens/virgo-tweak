Then /^I should see an add to folder form for ckey "([^\"]*)"$/ do |arg1|
  response.should have_selector("form.addFolderForm input", :id=>"id#{arg1}")
end

Then /^I (should|should not) see ckey "([^\"]*)" in the folder$/ do |comparator, arg1|
  case comparator
    when "should"
      response.should have_selector("tr", :id => "#{arg1}")
    when "should not"
      response.should_not have_selector("tr", :id => "#{arg1}")
    end
end

When /^I add ckey "([^\"]*)" to my folder$/ do |arg1|
  click_button("submitFolderForm_#{arg1}")
end

Given /^I have ckey "([^\"]*)" in my folder$/ do |arg1|
  visit catalog_path(arg1)
  click_button("Add Star")
  click_link("Starred Items")
end

Given /^I am logged in$/ do
  visit root_path
  click_link("Login using NetBadge")
end

When /^I visit the folder page$/ do
  visit folder_index_path
end


Then /^I (should|should not) see the Starred Items tools$/ do |comparator|
  case comparator
    when "should"
      response.should have_selector("ul#markedListTools")
    when "should not"
      response.should_not have_selector("ul#markedListTools")
    end
end 