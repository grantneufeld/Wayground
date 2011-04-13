# encoding: utf-8

def class_from_item_string(class_name)
  if class_name.downcase == 'item'
    User
  else
    eval class_name
  end
end
def item_from_class_and_item_strings(class_name, label)
  klass = class_from_item_string(class_name)
  return klass.find_by_label(label)
end

def action_type_from_label(action_label)
  case action_label.downcase
  when 'create' then :can_create
  when 'view'   then :can_view
  when 'edit'   then :can_edit
  when 'delete' then :can_delete
  when 'invite' then :can_invite
  when 'permit' then :can_permit
  when 'owner'  then :is_owner
  else
    raise 'invalid action label specified'
  end
end

def area_from_label(area_label)
  case area_label
  when /([Gg]lobal.*|anything)/
    'global'
  else
    area_label.singularize
  end
end


# Pre-setting authorities

Given /^there are no users or authorities$/ do
  User.delete_all
  Authority.delete_all
end

Given /^(?:|there is (?:|already ))an admin user "([^\"]*)"$/ do |user_name|
  user = users_named(user_name)[0]
  user.set_authority_on_area('global', :is_owner)
end

Given /^(?:|there is )a secure ([A-Za-z]+) "([^\"]+)"$/ do |class_name, label|
  class_name.downcase!
  klass = 'user' if class_name == 'item'
  item = Factory.create!(class_name.downcase.to_sym, :label => label, :is_authority_controlled => true)
  authority = Factory.create!(:authority, :item => item)
end

Given /^(?:|the user )"([^\"]*)" has (?:|the )authority to ([a-z]+) (.+)$/ do |user_name, action_label, area_label|
  user = users_named(user_name)[0]
  area = area_from_label(area_label)
  action_type = action_type_from_label(action_label)
  user.set_authority_on_area(area, action_type)
end

Given /^(?:|I )have signed in as an admin$/ do
  user = Factory.create(:user, :password => 'password')
  user.make_admin!
  When %{I sign in with email #{user.email} and password "#{user.password}"}
end

Given /^(?:|I am )authorized to manage web pages$/ do
  user = Factory.create(:user, :password => 'password')
  user.set_authority_on_area('Content', :is_owner)
  When %{I sign in with email #{user.email} and password "#{user.password}"}
end



# Assigning Authorities

When /^(?:|I )(?:|try to )add an authority for "([^\"]+)" to ([a-z]+) (.+)$/ do |user_name, action_label, area_label|
  user = users_named(user_name)[0]
  area = area_from_label(area_label)
  action_type = action_type_from_label(action_label)
  visit '/authorities/new'
  fill_in 'User', :with => user.id
  fill_in 'Area', :with => area
  check "authority_#{action_type}"
  click_button 'Save Authority'
end

When /^(?:|I )(?:|try to )add an authority with invalid settings$/ do
  visit '/authorities/new'
  fill_in 'User', :with => "non-existant-email@wayground.ca"
  # leave area blank
  # don’t check any action checkboxes
  click_button 'Save Authority'
end

When /^(?:|I )(?:|try to )remove (?:|the )authority to ([a-z]+) (.+) from (?:|the user )"([^\"]*)"$/ do |action_label, area_label, user_name|
  user = users_named(user_name)[0]
  area = area_from_label(area_label)
  action_type = action_type_from_label(action_label)
  authority = user.has_authority_for_area(area, action_type)
  visit "/authorities/#{authority.id}/edit"
  uncheck "authority_#{action_type}"
  click_button 'Save Authority'
end


# Reviewing Authorities

When /^(?:|I )(?:|try to )view the ([A-Za-z]+) "([^\"]+)"$/ do |class_name, label|
  item = item_from_class_and_item_strings(class_name, label)
  visit path_to(item)
end

Then /^(?:|I )should see the authorities index$/ do
  Then 'I should see "Authorities" within "title"'
  Then 'I should see "List of Authorities" within "h1"'
end


# Accessing Authority Controlled Items

Then /^(?:|I )should be able to access the ([A-Za-z]+) "([^\"]+)"$/ do |class_name, label|
  item = item_from_class_and_item_strings(class_name, label)
  visit path_to(item)
  # result is not error and result is not redirect
  redirected_to.should be_nil
  redirect?.should be_false
end

Then /^(?:|I )should be able to access the ([A-Za-z]+) "([^\"]+)"$/ do |class_name, label|
  item = item_from_class_and_item_strings(class_name, label)
  visit path_to(item)
  # result is error or redirect
  redirected_to.should_not be_nil
  redirect?.should be_true
end

Then /^(?:|I )should be denied access$/ do
  response.status.should eq 403 # "403 Forbidden"
  Then 'I should see "Unauthorized" within "title"'
end


# Checking Authorities

Then /^(?:|the user )"([^\"]*)" should be an admin$/ do |user_name|
  user = users_named(user_name)[0]
  user.has_authority_for_area('global', :is_owner).should_not be_nil
end
Then /^(?:|the user )"([^\"]*)" should not be an admin$/ do |user_name|
  user = users_named(user_name)[0]
  user.has_authority_for_area('global', :is_owner).should be_nil
end

Then /^(?:|the user )"([^\"]*)" should have authority to ([a-z]+) (.+)$/ do |user_name, action_label, area_label|
  user = users_named(user_name)[0]
  area = area_from_label(area_label)
  action_type = action_type_from_label(action_label)
  user.has_authority_for_area(area, action_type).should be_true
end
Then /^(?:|the user )"([^\"]*)" should not have authority to ([a-z]+) (.+)$/ do |user_name, action_label, area_label|
  user = users_named(user_name)[0]
  area = area_from_label(area_label)
  action_type = action_type_from_label(action_label)
  user.has_authority_for_area(area, action_type).should be_false
end
