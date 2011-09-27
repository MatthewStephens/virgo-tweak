require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

# Commonly used webrat steps
# http://github.com/brynary/webrat


When /^I am in the Special Collections lens$/ do
  visit root_path
  h = build_request_hash
  h[:controller] = 'catalog'
  h[:action] = 'index'
  h[:special_collections] = 'true'
  visit url_for(h)
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

When /^I apply the "(.*)" "(.*)" facet$/ do |arg1, arg2|
  #puts response.query_parameters
  puts url_for(:controller => 'catalog', :action => 'index')
  puts response.public_methods
  puts "<br/>***"
  puts "<br/>***"
  
  #visit path_to(current_url)
end

def build_request_hash
  #If there are existing QUERY_STRING or REQUEST_URI values, we don't want to lose them
  if request.env['QUERY_STRING'] =~ /\&/
    request_params = request.env['QUERY_STRING'].split('&')
  elsif request.env['REQUEST_URI'] =~ /\?/
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