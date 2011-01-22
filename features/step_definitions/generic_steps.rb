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
Given /^the date is "([^\"]*)"$/ do |date_string|
	Timecop.travel Chronic.parse("#{date_string} at noon")
end
Then /^reset the date$/ do
	Timecop.return
end