# encoding: utf-8

# SETUP

Given /^there are no custom paths$/ do
  Path.delete_all
end

# will default to creating 5 paths if “some” is specified as the number
Given /^(?:|I )have (some|[0-9]+) custom paths$/ do |quantity|
  (quantity == 'some' ? 5 : quantity.to_i).times do
    Factory(:path, :redirect => '/')
  end
end

Given /^(?:|I )have a custom path "([^\"]*)"$/ do |sitepath|
  Factory(:path, :sitepath => sitepath, :redirect => '/')
end

# ACTIONS

When /^(?:|I )(?:|try to )use the custom path "(\/[^\"]*)"$/ do |sitepath|
  visit sitepath
end

When /^(?:|I )create a custom path "([^\"]*)" that redirects to "([^\"]*)"$/ do |sitepath, redirect|
  visit '/paths/new'
  fill_in 'Sitepath', :with => sitepath
  fill_in 'Redirect', :with => redirect
  click_button 'Save Path'
end
When /^(?:|I )try to create a custom path "([^\"]*)" that redirects to "([^\"]*)"$/ do |sitepath, redirect|
  visit paths_path, :post, :path => {:sitepath => sitepath, :redirect => redirect}
end

When /^(?:|I )update the custom path "([^\"]*)" to "([^\"]*)"$/ do |sitepath, newpath|
  path = Path.find_by_sitepath(sitepath)
  visit edit_path_path(path)
  fill_in 'Sitepath', :with => newpath
  click_button 'Save Path'
end
When /^(?:|I )try to update the custom path "([^\"]*)" to "([^\"]*)"$/ do |sitepath, newpath|
  path = Path.find_by_sitepath(sitepath)
  visit path_path(path), :put, :path => {:sitepath => newpath}
end

When /^(?:|I )fill out the form to edit a custom path "([^\"]*)" with invalid data$/ do |sitepath|
  path = Path.find_by_sitepath(sitepath)
  visit edit_path_path(path)
  fill_in 'Sitepath', :with => 'invalid path'
  fill_in 'Redirect', :with => 'invalid url'
  click_button 'Save Path'
end

When /^(?:|I )delete the custom path "([^\"]*)"$/ do |sitepath|
  path = Path.find_by_sitepath(sitepath)
  visit delete_path_path(path)
  click_button 'Delete Path'
end
When /^(?:|I )try to delete the custom path "([^\"]*)"$/ do |sitepath|
  path = Path.find_by_sitepath(sitepath)
  visit path_path(path), :delete
end

# RESULTS

Then /^(?:|I )should see the default home page$/ do
  #response.should render_template("paths/default_home")
  response.should match("<h1>New Site Installation</h1>")
end

Then /^(?:|I )should see just the public paths for the website$/ do
  public_paths = []
  Path.in_order.all.each do |path|
    public_paths << path unless path.is_authority_restricted?
  end
  total_public_paths = public_paths.count
  pending # express the regexp above with the code you wish you had
end

Then /^(?:|I )should see the all paths for the website$/ do
  total_paths = Path.count
  pending # express the regexp above with the code you wish you had
end

Then /^(?:|I )should not have a custom path "([^\"]*)"$/ do |sitepath|
  path = Path.find_by_sitepath(sitepath) rescue ActiveRecord::RecordNotFound
  path.should be_nil
end

Then /^(?:|I )should have a custom path "([^\"]*)"$/ do |sitepath|
  path = Path.find_by_sitepath(sitepath)
  path.sitepath.should eq sitepath
end

Then /^(?:|I )should be redirected to "([^\"]*)"$/ do |redirect|
  if redirect.match /^https?:.*/
    # redirected to an url
    response.location.should eq redirect
  else
    # local path
    current_path = URI.parse(current_url).path
    current_path.should match(redirect)
  end
end

