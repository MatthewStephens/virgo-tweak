Then /^facet entry (\d+) should be "([^\"]*)"$/ do |digit, text|
  response.should have_tag("#left_column ul > li:nth-of-type(#{digit}) > a", :text => text)
end

When /^a facet limit of (\d+) is applied to ([^\"]*)$/ do |digit, facet|
  visit catalog_facet_path(:facet => facet, "facet.limit" => digit)
end