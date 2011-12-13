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
  page.should have_selector("div#results") 
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
  page.should_not have_selector("#results")
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
  page.should have_selector("a[href*=\"#{ckey}\"]")
end

Then /^I should not get ckey (.+) in the results$/i do |ckey|
  page.should_not have_selector("a[href*=?]", /^.*#{ckey}.*$/)
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
  page.should have_selector("dd", :text => "Multiple call numbers")
end

Then /^I should see (\d+) results for the author (.+)$/ do |hits, author|
  page.should have_selector("dd.authorField", :text => /^.*#{author}.*$/, :minimum => 10)
end

Then /^I should see the keyword label "([^\"]*)"$/ do |arg1|
  page.should have_selector("span.queryName", :text => arg1)
end

Then /^I should see the keyword value "([^\"]*)"$/ do |arg1|
  page.should have_selector("span.appliedFilter span.first span", :text => arg1)
end

Then /^I should not see the keyword label "([^\"]*)"$/ do |arg1|
  page.should_not have_selector("span.queryName", :text => arg1)
end

Then /^I should see the filter label "([^\"]*)"$/ do |arg1|
  page.should have_selector("span.filterName", :text => arg1)
end

Then /^I should not see the filter label "([^\"]*)"$/ do |arg1|
  page.should_not have_selector("span.filterName", :text => arg1)
end

Then /^I should see the filter value "([^\"]*)"$/ do |arg1|
  page.should have_selector("span.filterValue", :text => arg1)
end

Then /^the page number should be (\d+)$/ do |page|
  page.should have_selector("div.pagination span.current", :text => page)
end

Then /^I should be in the (.+) portal$/ do |portal|
  page.should have_selector(".search-scope", :text => portal)
end

Then /^I should see select list "([^\"]*)" with "([^\"]*)" selected$/ do |list_css, label|
  page.should have_selector(list_css) do |e|
    with_tag("[selected=selected]", {:count => 1}) do
      with_tag("option", {:count => 1, :text => label})
    end
  end
end

Then /^I should see the facet "([^\""]*)"$/ do |facet|
  page.should have_selector("div.side_bar_heading", :text => "#{facet}")
end

#When "library_facet":"Special Collections" is applied
When /^"([^\"]*)":"([^\"]*)" is applied$/ do |facet_name, facet_value|
  h = build_request_hash
 
  #Assemble a hash of the values that url_for needs to construct the url
  #e.g., url_for(:controller => 'catalog', :action => 'index', facet_name.to_sym => facet_value)  
  h[:controller] = 'catalog'
  h[:action] = 'index'  
    
  if h.has_key?(facet_name.to_sym) # tack on additional values
    h[facet_name.to_sym] = h[facet_name.to_sym] + "&f[#{facet_name.to_sym}][]=#{facet_value}"
  else
    h["f[#{facet_name.to_sym}][]"] = facet_value
  end
  visit url_for(h)  
end


# search X should have <,<=,=,>=,> results than search Y  (phrase!  boolean! parens! case sensitivity!)
# should get ckeys X and Y within Z positions of each other in the results
# should have results with search terms occurring in the title sorted first

def get_num_results(response)
  if page.body =~ /<strong>(.+)<\/strong> result/
    return $1.strip.gsub(/(,)/,'').to_i
  end
  return -1
end

def get_position_in_result_page(response, ckey)
#  <div class="document clearFix" id="Docu461865"> is the current format of a document div
  doc_links = page.body.scan(/<div class=\"document clearFix\" id=\"Doc(.*)\">/)
  
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

def build_request_hash
  #If there are existing QUERY_STRING or REQUEST_URI values, we don't want to lose them  
  if @env == nil 
    # do nothing
  elsif @env['QUERY_STRING'] =~ /\&/
    request_params = @env['QUERY_STRING'].split('&')
  elsif @env['REQUEST_URI'] =~ /\?/
    request_params = request.env['REQUEST_URI'].split('?')[1].split('&')
  end
  h = {}
  # split up request_params to make key and value pairs.  symbolize the key.
  unless request_params == nil
    request_params.each do |param|
      pair = param.split('=')  # e.g. subject_facet=American+poetry
      key = CGI::unescape(pair[0]).to_sym
      h[key] = CGI::unescape(pair[1]) unless pair[1] == nil 
    end
  end
  h[:only_path] = true
  h[:escape] = true
  h
end
