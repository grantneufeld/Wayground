require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the ApplicationHelper. For example:
#	describe ApplicationHelper do
#		describe "string concat" do
#			it "concats two strings with spaces" do
#				helper.concat_strings("this","that").should == "this that"
#			end
#		end
#	end
describe ApplicationHelper do
	describe "#show_errors" do
		it "displays errors (ActiveRecord-style) from an object" do
			item = User.new({:email => 'invalid'})
			item.valid?
			helper.show_errors(item).should match /[0-9]+ errors? prevented this User from being saved:/i
		end
	end
end
