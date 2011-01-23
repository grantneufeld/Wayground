require 'spec_helper'

describe TestModel do
	it "should have a testable method" do
		test_object = TestModel.new
		test_object.testable_method.should == 'something.'
	end
	
	it "should create a new from a factory" do
		expected_object = TestModel.new
		expected_object.test_attribute = 'something'
		test_object = Factory.create(:test_model, :test_attribute => 'something')
		expected_object.should == test_object
	end
end
