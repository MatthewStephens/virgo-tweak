Given /^a blank search$/ do
  catalog_index_path
end

When /^I search for "([^\"]*)"$/ do |arg1|
  pending
end

Then /^I should see record "([^\"]*)" first$/ do |arg1|
  pending
end

Then /^I should see the filter "([^\"]*)"$/ do |filter|
  response.should have_tag("span.filterValue", :text => "#{filter}")
end
