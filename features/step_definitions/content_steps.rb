# encoding: utf-8

When /^(?:|I )create a web page as "([^\"]+)"$/ do |filename|
  visit new_page_path
  fill_in 'Filename', :with => filename
  fill_in 'Title', :with => 'Feature Created Page'
  fill_in 'Description', :with => 'This page created by a cucumber feature.'
  fill_in 'Content', :with => '<p>Page created by feature.</p>'
  click_button 'Save Page'
end

When /^(?:|I )look at "([^\"]+)"$/ do |sitepath|
  visit sitepath
end

Then /^(?:|I )should see the web page for "([^\"]+)"$/ do |filename|
  path = Path.find_for_path(filename)
  page = path.item
  within('title') do |content|
    content.should contain(page.title)
  end
end
