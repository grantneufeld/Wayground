require 'timecop'

Given /^no ([A-Z][A-Za-z]+) records exist$/ do |wipe_class|
	klass = eval(wipe_class)
	klass.destroy_all
end

Given /^the debugger is triggered$/ do
	debugger
	nil
end
When /^(?:|I )trigger the debugger$/ do
	debugger
	nil
end
Then /^trigger the debugger$/ do
	debugger
	nil
end

When /^(?:|I )wait for ([0-9]+) seconds?$/ do |seconds|
	sleep seconds.to_i
end

# Make the system pretend it’s a specific day.
# See the source url for usage:
# http://louismrose.tumblr.com/post/876230592/freezing-time-in-cucumber
Given /^the date is(?:| now) "([^\"]*)"$/ do |date_string|
	Timecop.travel Chronic.parse("#{date_string} at noon")
end
Then /^reset the date$/ do
	Timecop.return
end


Then /^(?:|I )should see error messages$/ do
	error_exp = '<div class="error_messages">'
	if response.respond_to? :should
    body.should match error_exp
	else
    assert_match error_exp, body
	end
end

# field_names is one or more field names, separated by commas and “and”s.
Then /^(?:|I )should see errors for (.+)$/ do |field_names|
  field_names = field_names.split(/(?:, *|,? and )/)
  field_names.each do |field_name|
    # <div class="error_messages"><ul><li>field_name...
    page.should have_selector('.error_messages > ul', :text => /^#{field_name} .*/)
  end
end

Then /^I should see a notice that "([^\"]*)"$/ do |notice|
  body.should match(/<p class="notice">#{notice}<\/p>/)
end
