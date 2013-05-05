# encoding: utf-8
require 'spec_helper'
require 'import/icalendar_reader'

describe IcalendarReader do
  let(:ical_reader) { $ical_reader = IcalendarReader.new }

  describe "#parse" do
    it "should take a String with the iCalendar data" do
      calendars = ical_reader.parse("BEGIN:VCALENDAR\nA:1\nEND:VCALENDAR\n")
      calendars.should eq [{'A' => {:value => '1'}}]
    end
    it "should take an IO object with the iCalendar data" do
      io = StringIO.new("BEGIN:VCALENDAR\nA:1\nEND:VCALENDAR\n")
      calendars = ical_reader.parse(io)
      calendars.should eq [{'A' => {:value => '1'}}]
    end
    it "should unfold folded lines (linebreak followed by space)" do
      result = ical_reader.parse(
        "BEG\n IN:VCA\n LENDAR\nA\n :So\n me fo\n lded l\n ines.\nEND:VCALE\n NDAR\n"
      )
      result.should eq([{'A' => {:value => 'Some folded lines.'}}])
    end
    it "should return an Array" do
      ical_reader.parse("").should eq []
    end
    it "should read through all of the lines in the source" do
      ical_reader.parse("BEGIN:VCALENDAR\nA:1\nEND:VCALENDAR\n")
      ical_reader.io.gets.should be_nil
    end
    it "should parse VCALENDAR sub-elements" do
      result = ical_reader.parse("BEGIN:VCALENDAR\nA:1\nEND:VCALENDAR\n")
      result.should eq([{'A' => {:value => '1'}}])
    end
    it "should ignore anything not in a VCALENDAR" do
      result = ical_reader.parse(
        "\n\nA:1\nIgnore\nBEGIN:VCALENDAR\nB:2\nEND:VCALENDAR\n\n ignore\nC:3\n\n"
      )
      result.should eq([{'B' => {:value => '2'}}])
    end
  end

  describe "#parse_vcalendar" do
    it "should bump the icalendar reader’s io to the end of the vcalendar element" do
      ical_reader.io = StringIO.new("A:1\nB:2\nEND:VCALENDAR\nC:3\n")
      ical_reader.parse_vcalendar
      ical_reader.io.gets.should match /^C:3$/
    end
    it "should return a hash" do
      ical_reader.io = StringIO.new("A:1\nB:2\nEND:VCALENDAR\nC:3\n")
      ical_reader.parse_vcalendar.should eq(
        {'A' => {:value => '1'}, 'B' => {:value => '2'}}
      )
    end
    it "should parse VEVENT sub-elements" do
      ical_reader.io = StringIO.new("BEGIN:VEVENT\nA:1\nEND:VEVENT\nEND:VCALENDAR\n")
      ical_reader.parse_vcalendar.should eq(
        {'VEVENT' => [{'A' => {:value => '1'}}]}
      )
    end
    it "should parse VTIMEZONE sub-elements" do
      ical_reader.io = StringIO.new("BEGIN:VTIMEZONE\nTZID:Test\nEND:VTIMEZONE\nEND:VCALENDAR\n")
      ical_reader.parse_vcalendar.should eq(
        {'VTIMEZONE' => {'Test' => {'TZID' => {:value => 'Test'}}}}
      )
    end
    it "should ignore unrecognized sub-elements" do
      ical_reader.io = StringIO.new("A:1\nBEGIN:TEST\nB:2\nEND:TEST\nC:3\nEND:VCALENDAR\n")
      ical_reader.parse_vcalendar.should eq(
        {'A' => {:value => '1'}, 'C' => {:value => '3'}}
      )
    end
    it "should handle multi-parameter values" do
      ical_reader.io = StringIO.new("TEST;KEY=value;TEST=yes:SUCCESS\nEND:VCALENDAR\n")
      ical_reader.parse_vcalendar.should eq(
        {'TEST' => {:value => 'SUCCESS', 'KEY' => 'value', 'TEST' => 'yes'}}
      )
    end
  end

  describe "#parse_vevent" do
    it "should bump the icalendar reader’s io to the end of the vevent element" do
      ical_reader.io = StringIO.new("A:1\nB:2\nEND:VEVENT\nC:3\n")
      ical_reader.parse_vevent
      ical_reader.io.gets.should match /^C:3$/
    end
    it "should return a hash" do
      ical_reader.io = StringIO.new("A:1\nB:2\nEND:VEVENT\nC:3\n")
      ical_reader.parse_vevent.should eq(
        {'A' => {:value => '1'}, 'B' => {:value => '2'}}
      )
    end
    it "should ignore sub-elements" do
      ical_reader.io = StringIO.new("A:1\nBEGIN:TEST\nB:2\nEND:TEST\nC:3\nEND:VEVENT\n")
      ical_reader.parse_vevent.should eq(
        {'A' => {:value => '1'}, 'C' => {:value => '3'}}
      )
    end
    it "should parse dates" do
      ical_reader.io = StringIO.new(
        "DTSTART;TZID=Canada/Central:20010203T143000\n" +
        "DTEND;TZID=America/Edmonton:20010607T133000\n" +
        "DTSTAMP:20010203T133000\n" +
        "LAST-MODIFIED:20010203T133000\n" +
        "CREATED:20010203T133000\n" +
        "\nEND:VEVENT\n"
      )
      ical_reader.parse_vevent.should eq({
        'DTSTART' => {:value => '2001-02-03 14:30:00 CST'.to_datetime},
        'DTEND' => {:value => '2001-06-07 13:30:00 MDT'.to_datetime},
        'DTSTAMP' => {:value => '2001-02-03 13:30:00 UTC'.to_datetime},
        'LAST-MODIFIED' => {:value => '2001-02-03 13:30:00 UTC'.to_datetime},
        'CREATED' => {:value => '2001-02-03 13:30:00 UTC'.to_datetime}
      })
    end
    it "should treat sequence as an integer" do
      ical_reader.io = StringIO.new("SEQUENCE:123\nEND:VEVENT\n")
      ical_reader.parse_vevent.should eq(
        {'SEQUENCE' => {:value => 123}}
      )
    end
    it "should handle multi-parameter values" do
      ical_reader.io = StringIO.new("TEST;KEY=value;TEST=yes:SUCCESS\nEND:VEVENT\n")
      ical_reader.parse_vevent.should eq(
        {'TEST' => {:value => 'SUCCESS', 'KEY' => 'value', 'TEST' => 'yes'}}
      )
    end
  end

  describe "#parse_vtimezone" do
    it "should bump the icalendar reader’s io to the end of the timezone element" do
        ical_reader.io = StringIO.new("A:1\nB:2\nEND:VTIMEZONE\nC:3\n")
        ical_reader.parse_vtimezone
        ical_reader.io.gets.should match /^C:3$/
    end
    it "should return a hash" do
      ical_reader.io = StringIO.new("A:1\nB:2\nEND:VTIMEZONE\nC:3\n")
      ical_reader.parse_vtimezone.should eq(
        {'A' => {:value => '1'}, 'B' => {:value => '2'}}
      )
    end
    it "should handle sub-elements" do
      ical_reader.io = StringIO.new("A:1\nBEGIN:TEST\nB:2\nEND:TEST\nC:3\nEND:VTIMEZONE\n")
      ical_reader.parse_vtimezone.should eq(
        {'A' => {:value => '1'}, 'TEST' => {'B' => {:value => '2'}}, 'C' => {:value => '3'}}
      )
    end
  end

  describe "#parse_vtimezone_element" do
    it "should bump the icalendar reader’s io to the end of the element" do
      ical_reader.io = StringIO.new("A:1\nB:2\nEND:TEST\nC:3\n")
      ical_reader.parse_vtimezone_element('TEST')
      ical_reader.io.gets.should match /^C:3$/
    end
    it "should return a hash" do
      ical_reader.io = StringIO.new("A:1\nB:2\nEND:TEST\nC:3\n")
      ical_reader.parse_vtimezone_element('TEST').should eq(
        {'A' => {:value => '1'}, 'B' => {:value => '2'}}
      )
    end
  end

  describe "#parse_unrecognized_element" do
    it "should bump the icalendar reader’s io to the end of the element" do
      ical_reader.io = StringIO.new("BEGIN:SUB\nA:1\nEND:SUB\nB:2\nEND:TEST\nC:3\n")
      ical_reader.parse_unrecognized_element('TEST')
      ical_reader.io.gets.should match /^C:3$/
    end
    it "should return nil" do
      ical_reader.io = StringIO.new("A:1\nB:2\nEND:TEST\nC:3\n")
      ical_reader.parse_unrecognized_element('TEST').should be_nil
    end
  end

  describe "#clean_string" do
    it "should un-escape newlines" do
      ical_reader.clean_string("Test\\nLine").should eq "Test\nLine"
    end
    it "should un-escape tabs" do
      ical_reader.clean_string("Test\\tTab").should eq "Test\tTab"
    end
    it "should un-escape slashes" do
      ical_reader.clean_string("Test\\\\Slash").should eq "Test\\Slash"
    end
    it "should un-escape assorted other characters" do
      ical_reader.clean_string("Test\\,\\;\\:Chars").should eq "Test,;:Chars"
    end
  end

  describe "#parse_date_value" do
    it "should handle a time string with no timezone" do
      time = ical_reader.parse_date_value("20010203T203000Z")
      time.should eq '2001-02-03 13:30:00 MST'.to_datetime
    end
    it "should handle a time with timezone" do
      time = ical_reader.parse_date_value("TZID=America/Edmonton:20010203T133000")
      time.should eq '2001-02-03 13:30:00 MST'.to_datetime
    end
    it "should handle a time with a different name for the same timezone" do
      time = ical_reader.parse_date_value("TZID=Canada/Mountain:20010607T080910")
      time.should eq '2001-06-07 08:09:10 MDT'.to_datetime
    end
    it "should handle a time with a different timezone" do
      time = ical_reader.parse_date_value("TZID=Canada/Central:20010203T143000")
      time.should eq '2001-02-03 14:30:00 CST'.to_datetime
    end
  end

  describe "#parse_multivalue_line_chunks" do
    it "should generate a hash" do
      hash = ical_reader.parse_multivalue_line_chunks("KEY=thekey", "value")
      hash.should eq({:value => 'value', 'KEY' => 'thekey'})
    end
    it "should handle multiple keyed values" do
      hash = ical_reader.parse_multivalue_line_chunks("A=1;B=2", "value")
      hash.should eq({:value => 'value', 'A' => '1', 'B' => '2'})
    end
  end

end
