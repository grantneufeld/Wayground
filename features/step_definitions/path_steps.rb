# encoding: utf-8

# SETUP

Given /^there are no custom paths$/ do
  Path.delete_all
end

# Generate some number of paths, mixing public and private paths.
# Will default to creating 5 paths if “some” is specified as the number.
Given /^(?:|I )have (some|[0-9]+) custom paths$/ do |quantity|
  quantity = (quantity == 'some' ? 5 : quantity.to_i)
  existing_path_count = Path.count
  return if quantity <= existing_path_count
  quantity -= existing_path_count
  private_quantity = rand(quantity - 2) + 1
  public_quantity = quantity - private_quantity
  public_quantity.times do
    FactoryGirl.create(:path, :redirect => '/')
  end
  private_quantity.times do
    page = FactoryGirl.create(:page, :is_authority_controlled => true)
    FactoryGirl.create(:path, :item => page)
  end
end

Given /^(?:|I )have a custom path "([^\"]*)"(?:| pointing to "([^\"]*)")$/ do |sitepath, redirect|
  redirect ||= '/'
  FactoryGirl.create(:path, :sitepath => sitepath, :redirect => redirect)
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

When /^(?:|I )update the custom path "([^\"]*)" to "([^\"]*)"$/ do |sitepath, newpath|
  path = Path.find_by_sitepath(sitepath)
  visit edit_path_path(path)
  fill_in 'Sitepath', :with => newpath
  click_button 'Save Path'
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
  page.should have_selector('h1', :text => 'New Site Installation')
end

Then /^(?:|I )should just be able to see the public paths for the website$/ do
  public_paths = []
  Path.in_order.all.each do |path|
    public_paths << path unless path.is_authority_restricted?
  end
  total_public_paths = public_paths.count
  visit '/paths'
  page.should have_selector("tbody>tr", :count => total_public_paths)
end

Then /^(?:|I )should be able to see the all paths for the website$/ do
  total_paths = Path.count
  visit '/paths'
  page.should have_selector("tbody>tr", :count => total_paths)
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
    current_url.should eq redirect
  else
    # local path
    current_path.should match(redirect)
  end
end

