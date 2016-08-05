require 'rails_helper'
require_relative '../../app/models/test_model'

describe TestModel do
  it 'should have a testable method' do
    test_object = TestModel.new
    expect(test_object.testable_method).to eq 'Method tested.'
  end

  it 'should create a new from a factory' do
    expected_object = TestModel.new
    expected_object.test_attribute = 'something'
    test_object = FactoryGirl.create(:test_model, test_attribute: 'something')
    expect(expected_object).to eq test_object
  end
end
