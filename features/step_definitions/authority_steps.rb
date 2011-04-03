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

Given /^(?:|there is )a secure ([A-Za-z]+) "([^\"]+)"$/ do |class_name, label|
  class_name.downcase!
  klass = 'user' if class_name == 'item'
  item = Factory.create!(class_name.downcase.to_sym, :label => label, :is_authority_controlled => true)
  authority = Factory.create!(:authority, :item => item)
end

When /^(?:|I )(?:|try to )view the ([A-Za-z]+) "([^\"]+)"$/ do |class_name, label|
  item = item_from_class_and_item_strings(class_name, label)
  visit path_to(item)
end

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
