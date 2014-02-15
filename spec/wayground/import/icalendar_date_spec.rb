require 'spec_helper'
require 'import/icalendar_date'

describe Wayground::Import::IcalendarDate do

  let(:parser) { $parser = Wayground::Import::IcalendarDate.new }

  describe "#to_datetime" do
    it "should handle a time string with no timezone" do
      parser = Wayground::Import::IcalendarDate.new("20010203T203000Z")
      expect( parser.to_datetime ).to eq '2001-02-03 13:30:00 MST'.to_datetime
    end
    it "should handle a time with timezone" do
      parser = Wayground::Import::IcalendarDate.new("TZID=America/Edmonton:20010203T133000")
      expect( parser.to_datetime ).to eq '2001-02-03 13:30:00 MST'.to_datetime
    end
    it "should handle a time with a different name for the same timezone" do
      parser = Wayground::Import::IcalendarDate.new("TZID=Canada/Mountain:20010607T080910")
      expect( parser.to_datetime ).to eq '2001-06-07 08:09:10 MDT'.to_datetime
    end
    it "should handle a time with a different timezone" do
      parser = Wayground::Import::IcalendarDate.new("TZID=Canada/Central:20010203T143000")
      expect( parser.to_datetime ).to eq '2001-02-03 14:30:00 CST'.to_datetime
    end
    it "should handle a time with an invalid timezone" do
      parser = Wayground::Import::IcalendarDate.new("TZID=invalid/timezone:20010203T153000")
      expect( parser.to_datetime ).to eq '2001-02-03 15:30:00 UTC'.to_datetime
    end
  end

end
