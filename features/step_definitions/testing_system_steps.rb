When /^I test a feature$/ do
	test_object = TestModel.new
end

Then /^I should get "([^\"]*)"$/ do |a_string|
	test_object = TestModel.new
	test_result = test_object.testable_feature
	if test_result.respond_to? :should
		test_result.should == a_string
	else
		assert_equal(test_result, a_string)
	end
end

Then /^I should have ([0-9]+) [Tt]est[ _]?[Mm]odels?$/ do |quantity|
	actual_count = TestModel.length
	expected_count = quantity.to_i
	if actual_count.respond_to? :should
		actual_count.should == expected_count
	else
		assert_equal(actual_count, expected_count)
	end
end

Then /^I should have a [Tt]est[ _]?[Mm]odel with test_attribute "([^\"]*)"$/ do |expected_value|
	if expected_value.respond_to? :should
		TestModel.should include(expected_value)
	else
		assert(TestModel.include?(expected_value))
	end
end
