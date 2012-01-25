Given /^I am logged in as "([^\"]*)"$/ do |login|
  visit login_path(:login => login)
end

Given /^I am logged in as virginia borrower "([^\"]*)" with pin "([^\"]*)"$/ do |login, pin|
  visit do_patron_login_path(:login => login, :pin => pin)
end

Given /^I am viewing the stubbed account page for mst3k$/ do
  visit login_path(:login => "mst3k")
  FakeWeb.register_uri(:get, "#{FIREHOSE_URL}/users/mst3k", 
    :body => File.read("#{Rails.root.to_s}/test/fixtures/mst3k_account.xml"))
  visit account_index_path
end

Given /^I am viewing the stubbed account page for barred mst3k$/ do
  visit login_path(:login => "mst3k")
  FakeWeb.register_uri(:get, "#{FIREHOSE_URL}/users/mst3k", 
    :body => File.read("#{Rails.root.to_s}/test/fixtures/mst3k_barred.xml"))
  visit account_index_path
end

Given /^I am viewing the stubbed checkouts page for mst3k$/ do
  visit login_path(:login => "mst3k")
  FakeWeb.register_uri(:get, "#{FIREHOSE_URL}/users/mst3k/checkouts",
    :body => File.read("#{Rails.root.to_s}/test/fixtures/mst3k_checkouts.xml"))
  visit checkouts_account_index_path
end

Given /^I am viewing the stubbed holds page for mst3k$/ do
  visit login_path(:login => "mst3k")
  FakeWeb.register_uri(:get, "#{FIREHOSE_URL}/users/mst3k/holds",
    :body => File.read("#{Rails.root.to_s}/test/fixtures/mst3k_holds.xml"))
  visit holds_account_index_path
end

Given /^I am viewing the stubbed reserves page for mst3k$/ do
  visit login_path(:login => "mst3k")
  FakeWeb.register_uri(:get, "#{FIREHOSE_URL}/users/mst3k/reserves",
    :body => File.read("#{Rails.root.to_s}/test/fixtures/mst3k_reserves.xml"))
  visit reserves_account_index_path
end

Then /^I should see a full name$/ do
  page.should have_selector("span.fn")
end

Then /^I should see the full name "([^\"]*)"$/ do |name|
  page.should have_selector("span.fn", :text => name)
end

Then /^I should see the user id "([^\"]*)"$/ do |uid|
  page.should have_selector("span.uid", :text => uid)
end

Then /^I should see the working title "([^\"]*)"$/ do |title|
  page.should have_selector("div.vcard p.title", :text => title)
end

Then /^I should see the organization "([^\"]*)"$/ do |org|
  page.should have_selector("p.org", :text => org)
end

Then /^I should see the address "([^\"]*)"$/ do |address|
  page.should have_selector("p.adr", :text => address)
end

Then /^I should see the email "([^\"]*)"$/ do |email|
  page.should have_selector("p.email", :text => email)
end

Then /^I should see the telephone number "([^\"]*)"$/ do |phone|
  page.should have_selector("p.tel", :text => phone)
end

Then /^I should see a checked out items count$/ do
  page.should have_selector("li.checkouts-nav")
end

Then /^I should see a requests count$/ do
  page.should have_selector("li.holds-nav")
end

Then /^I should see a reserves count$/ do
  page.should have_selector("li.reserves-nav")
end

Then /^I should see a notices count$/ do
  page.should have_selector("li.notices-nav")
end

Then /^I should see how many items I have checked out$/ do
  page.should have_selector("span.account-total")
end

Then /^I should see how many requested items I have$/ do
  page.should have_selector("span.account-total")
end

Then /^I should see how many reserves I have$/ do
  page.should have_selector("span.account-total")
end

Then /^I should see how many notices I have$/ do
  page.should have_selector("span.account-total")
end

Then /^I should see (\d+) items$/ do |num|
  page.should have_selector("span.account-total", :text => num)
end

Then /^I should see a recalled item$/ do
  page.should have_selector("span.recalled")
end

Then /^I should see an overdue item$/ do
  page.should have_selector("span.overdue")
end

Then /^I should see an item with no due date$/ do
  page.should have_selector("td.date", :text => "Never")
end

Then /^I should see the library list$/ do
  page.should have_selector("select#library_id option", :text => "Alderman")
end

Given /^I am viewing the stubbed status page for an item in ivy that is checked out$/ do
  visit login_path(:login => "mst3k")
  FakeWeb.register_uri(:get, "#{FIREHOSE_URL}/items/751547", 
    :body => File.read("#{Rails.root.to_s}/test/fixtures/ivy_checked_out.xml"))
  visit availability_path("u751547")
end
