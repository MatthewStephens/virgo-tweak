Given /^I am logged in as "([^\"]*)"$/ do |login|
  visit login_path(:login => login)
end

Given /^I am logged in as virginia borrower "([^\"]*)"$/ do |login|
  visit do_patron_login_path(:login => login)
end

Given /^I am viewing the stubbed account page for mst3k$/ do
  visit login_path(:login => "mst3k")
  FakeWeb.register_uri(:get, "#{FIREHOSE_URL}/firehose2/users/mst3k", 
    :body => File.read("#{RAILS_ROOT}/test/fixtures/mst3k_account.xml"))
  visit account_index_path
end

Given /^I am viewing the stubbed account page for barred mst3k$/ do
  visit login_path(:login => "mst3k")
  FakeWeb.register_uri(:get, "#{FIREHOSE_URL}/firehose2/users/mst3k", 
    :body => File.read("#{RAILS_ROOT}/test/fixtures/mst3k_barred.xml"))
  visit account_index_path
end

Given /^I am viewing the stubbed checkouts page for mst3k$/ do
  visit login_path(:login => "mst3k")
  FakeWeb.register_uri(:get, "#{FIREHOSE_URL}/firehose2/users/mst3k/checkouts",
    :body => File.read("#{RAILS_ROOT}/test/fixtures/mst3k_checkouts.xml"))
  visit checkouts_account_path
end

Given /^I am viewing the stubbed holds page for mst3k$/ do
  visit login_path(:login => "mst3k")
  FakeWeb.register_uri(:get, "#{FIREHOSE_URL}/firehose2/users/mst3k/holds",
    :body => File.read("#{RAILS_ROOT}/test/fixtures/mst3k_holds.xml"))
  visit holds_account_path
end

Given /^I am viewing the stubbed reserves page for mst3k$/ do
  visit login_path(:login => "mst3k")
  FakeWeb.register_uri(:get, "#{FIREHOSE_URL}/firehose2/users/mst3k/reserves",
    :body => File.read("#{RAILS_ROOT}/test/fixtures/mst3k_reserves.xml"))
  visit reserves_account_path
end

Then /^I should see a full name$/ do
  response.should have_tag("span.fn")
end

Then /^I should see the full name "([^\"]*)"$/ do |name|
  response.should have_tag("span.fn", :text => name)
end

Then /^I should see the user id "([^\"]*)"$/ do |uid|
  response.should have_tag("span.uid", :text => uid)
end

Then /^I should see the working title "([^\"]*)"$/ do |title|
  response.should have_tag("div.vcard p.title", :text => title)
end

Then /^I should see the organization "([^\"]*)"$/ do |org|
  response.should have_tag("p.org", :text => org)
end

Then /^I should see the address "([^\"]*)"$/ do |address|
  response.should have_tag("p.adr", :text => address)
end

Then /^I should see the email "([^\"]*)"$/ do |email|
  response.should have_tag("p.email", :text => email)
end

Then /^I should see the telephone number "([^\"]*)"$/ do |phone|
  response.should have_tag("p.tel", :text => phone)
end

Then /^I should see a checked out items count$/ do
  response.should have_tag("li.checkouts-nav")
end

Then /^I should see a requests count$/ do
  response.should have_tag("li.holds-nav")
end

Then /^I should see a reserves count$/ do
  response.should have_tag("li.reserves-nav")
end

Then /^I should see a notices count$/ do
  response.should have_tag("li.notices-nav")
end

Then /^I should see how many items I have checked out$/ do
  response.should have_tag("span.account-total")
end

Then /^I should see how many requested items I have$/ do
  response.should have_tag("span.account-total")
end

Then /^I should see how many reserves I have$/ do
  response.should have_tag("span.account-total")
end

Then /^I should see how many notices I have$/ do
  response.should have_tag("span.account-total")
end

Then /^I should see (\d+) items$/ do |num|
  response.should have_tag("span.account-total", :text => num)
end

Then /^I should see a recalled item$/ do
  response.should have_tag("span.recalled")
end

Then /^I should see an overdue item$/ do
  response.should have_tag("span.overdue")
end

Then /^I should see an item with no due date$/ do
  response.should have_tag("td.date", :text => "Never")
end

Then /^I should see the library list$/ do
  response.should have_tag("select#library_id option", :text => "Alderman")
end

Given /^I am viewing the stubbed status page for an item in ivy that is checked out$/ do
  visit login_path(:login => "mst3k")
  FakeWeb.register_uri(:get, "#{FIREHOSE_URL}/firehose2/items/751547", 
    :body => File.read("#{RAILS_ROOT}/test/fixtures/ivy_checked_out.xml"))
  visit status_catalog_path("u751547")
end
