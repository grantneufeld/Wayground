# encoding: utf-8
require 'spec_helper'
require 'make_db_array_field'
require 'db_array'
# use the Person model for testing since it uses make_db_array_field
require 'person'

describe "make_db_array_field" do
  describe "setter method" do
    it "should accept a String value" do
      person = Person.new
      person.aliases = '{"A","B"}'
      expect( person.aliases ).to eq ['A','B']
    end
    it "should accept an Array value" do
      person = Person.new
      person.aliases = ['C','D']
      expect( person.aliases.to_s ).to eq '{"C","D"}'
    end
  end
  describe "getter method" do
    it "should wrap the value in a DbArray object" do
      person = FactoryGirl.create(:person, aliases: ['E', 'F'], filename: 'make_db_array_getter')
      person = Person.find(person.id)
      expect( person.aliases.is_a? DbArray ).to be_true
    end
  end
  it "should accept multiple field names" do
    # TODO: implement a class that has at least 2 Array fields
    #person = Person.new
    #person.aliases = ['G', 'H']
    #person.??? = ['I', 'J']
    #expect( [person.aliases.to_s, person.???.to_s] ).to eq ['{"G","H"}', '{"I","J"}']
  end
end
