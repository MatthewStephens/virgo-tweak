Then /^I should see a request button for item (.+)/i do |num|
  page.should have_selector("input#special_collections_request_submit_#{num}", :value => "Request")
end

Then /^I should see one filter for Special Collections/i do
  filter_text = response.body.scan(/<span class=\"filterValue\">Special Collections<\/span>/)
  filter_text.size.should == 1
end

Given /^I am logged in as a Special Collections administrator$/ do
  login = "BigWig"
  email = "bigwig@bigwig.com"
  user = User.find_or_create_by_login(:login => login, :email =>email, :password => "password", :password_confirmation => "password")
  superuser = SpecialCollectionsUser.create(:id => user.id, :computing_id => user.login)
  visit user_sessions_path(:user_session => {:login => login, :password => "password"}), :post
  visit special_collections_requests_path
end


When /^I am in the Special Collections lens$/ do
  visit root_path
  h = build_request_hash
  h[:controller] = 'catalog'
  h[:action] = 'index'
  h[:special_collections] = 'true'
  visit url_for(h)
end
