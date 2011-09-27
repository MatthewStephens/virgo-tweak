# Steps to check search results

#include Blacklight::SolrHelper

# TODO:  this is checking if the index URL is in stanford domain;  it
#   should be checking if there is particular content in the index that
#   identifies the data properly
#      more than 5,500,000  docs;  has certain docs(s) ...

Given /^I set "(.+)" as my sort option$/ do |sort|
  h = build_request_hash
  h[:controller] = 'catalog'
  h[:action] = 'index'
  h[:sort_key] = sort
  visit url_for(h)
end

Then /^I should get results$/ do 
  response.should have_selector("div#results") 
end

Then /^I should get (at least|at most|exactly) (\d+) results$/i do |comparator, comparison_num|
  results = get_num_results(response)
  case comparator
    when "at least"
      results.should >= comparison_num.to_i
    when "at most"
      results.should <= comparison_num.to_i
    when "exactly"
      results.should == comparison_num.to_i
  end
end

Then /^I should see no results$/i do
  response.should_not have_tag("#results")
end

Then /^I should get (the same number of|fewer|more) results (?:than|as) a search for "(.+)"$/i do |comparator, query|
  results = get_num_results(response)
  case comparator
    when "the same number of"
      results.should == get_num_results_for_query(query)
    when "fewer"
      results.should < get_num_results_for_query(query)
    when "more"
      results.should > get_num_results_for_query(query)
  end
end

Then /^I should get ckey (.+) in the results$/i do |ckey|
  response.should have_tag("a[href*=?]", /^.*#{ckey}.*$/)
end

Then /^I should not get ckey (.+) in the results$/i do |ckey|
  response.should_not have_tag("a[href*=?]", /^.*#{ckey}.*$/)
end

Then /^I should get ckey (.+) in the first (\d+) results$/i do |ckey, max_num|
  pos = get_position_in_result_page(response, ckey) 
  pos.should_not == -1
  pos.should < max_num.to_i
end

Then /^I should get ckey (.+) before ckey (.+)$/ do |ckey1, ckey2|
  pos1 = get_position_in_result_page(response, ckey1) 
  pos2 = get_position_in_result_page(response, ckey2)
  pos1.should_not == -1
  pos2.should_not == -1
  pos1.should < pos2
end

Then /^I should get ckey (.+) followed by ckey (.+)/ do |ckey1, ckey2|
  pos1 = get_position_in_result_page(response, ckey1)
  pos2 = get_position_in_result_page(response, ckey2)
  pos1.should_not == -1
  pos2.should_not == -1
  pos1.should == pos2 - 1
end

Then /^I should see multiple call numbers$/ do
  response.should have_tag("dd", :text => "Multiple call numbers")
end

Then /^I should see (\d+) results for the author (.+)$/ do |hits, author|
  response.should have_tag("dd.authorField", :text => /^.*#{author}.*$/, :minimum => 10)
end

Then /^I should see the keyword label "([^\"]*)"$/ do |arg1|
  response.should have_tag("span.queryName", :text => arg1)
end

Then /^I should see the keyword value "([^\"]*)"$/ do |arg1|
  response.should have_tag("span.appliedFilter span.first span", :text => arg1)
end

Then /^I should not see the keyword label "([^\"]*)"$/ do |arg1|
  response.should_not have_tag("span.queryName", :text => arg1)
end

Then /^I should see the filter label "([^\"]*)"$/ do |arg1|
  response.should have_tag("span.filterName", :text => arg1)
end

Then /^I should not see the filter label "([^\"]*)"$/ do |arg1|
  response.should_not have_tag("span.filterName", :text => arg1)
end

Then /^I should see the filter value "([^\"]*)"$/ do |arg1|
  response.should have_tag("span.filterValue", :text => arg1)
end

Then /^the page number should be (\d+)$/ do |page|
  response.should have_tag("div.pagination span.current", :text => page)
end

Then /^I should be in the (.+) portal$/ do |portal|
  response.should have_tag(".search-scope", :text => portal)
end

Then /^I should see select list "([^\"]*)" with "([^\"]*)" selected$/ do |list_css, label|
  response.should have_tag(list_css) do |e|
    with_tag("[selected=selected]", {:count => 1}) do
      with_tag("option", {:count => 1, :text => label})
    end
  end
end

Then /^I should see the facet "([^\""]*)"$/ do |facet|
  response.should have_tag("div.side_bar_heading", :text => "#{facet}")
end

# search X should have <,<=,=,>=,> results than search Y  (phrase!  boolean! parens! case sensitivity!)
# should get ckeys X and Y within Z positions of each other in the results
# should have results with search terms occurring in the title sorted first

def get_num_results(response)
  if response.body =~ /<strong>(.+)<\/strong> result/
    return $1.strip.gsub(/(,)/,'').to_i
  end
  return -1
end

def get_position_in_result_page(response, ckey)
#  <div class="document clearFix" id="Docu461865"> is the current format of a document div
  doc_links = response.body.scan(/<div class=\"document clearFix\" id=\"Doc(.*)\">/)
  
  doc_links.each_with_index do |doc_link, num|
    if doc_link.to_s.match(ckey) != nil
      return num
    end
  end
  -1 # ckey not found in page of results
end

def get_num_results_for_query(query) 
  visit root_path
  fill_in "q", :with => query 
  click_button "search"
  results = get_num_results(response)
end


