# encoding: utf-8
require 'spec_helper'
require 'import/icalendar_reader'

describe Wayground::Import::IcalendarReader do
  let(:data) { '' }
  let(:io) { nil }
  let(:ical_reader) { $ical_reader = Wayground::Import::IcalendarReader.new(io: io, data: data) }

  describe "initialization" do
    let(:data) { $data = "BEGIN:VCALENDAR\nA:1\nEND:VCALENDAR\n" }
    it "should take a String with the iCalendar data" do
      expect( ical_reader.io.read ).to eq data
    end
    context "with io" do
      let(:io) { $io = StringIO.new(data) }
      it "should take an IO object with the iCalendar data" do
        expect( ical_reader.io.read ).to eq data
      end
    end
  end

  describe "#parse" do
    it "should return an Array" do
      expect( ical_reader.parse ).to eq []
    end
    context "with vcalendar data" do
      let(:data) { $data = "BEGIN:VCALENDAR\nA:1\nEND:VCALENDAR\n" }
      it "should read through all of the lines in the source" do
        ical_reader.parse
        expect( ical_reader.io.gets ).to be_nil
      end
      it "should parse VCALENDAR sub-elements" do
        expect( ical_reader.parse ).to eq([{'A' => {value: '1'}}])
      end
    end
    context "with folded lines" do
      let(:data) { $data = "BEG\n IN:VCA\n LENDAR\nA\n :So\n me fo\n lded l\n ines.\nEND:VCALE\n NDAR\n" }
      it "should unfold folded lines (linebreak followed by space)" do
        expect( ical_reader.parse ).to eq([{'A' => {value: 'Some folded lines.'}}])
      end
    end
    context "with excess lines to be ignored" do
      let(:data) { $data = "\n\nA:1\nIgnore\nBEGIN:VCALENDAR\nB:2\nEND:VCALENDAR\n\n ignore\nC:3\n\n" }
      it "should ignore anything not in a VCALENDAR" do
        expect( ical_reader.parse ).to eq([{'B' => {value: '2'}}])
      end
    end
  end

  describe "#parse_vcalendar" do
    let(:io) { $io = StringIO.new("A:1\nB:2\nEND:VCALENDAR\nC:3\nD:4\n") }
    it "should bump the icalendar reader’s io to the end of the vcalendar element" do
      ical_reader.parse_vcalendar
      expect( ical_reader.line_buffer ).to match /^C:3$/
    end
    it "should return a hash" do
      expect( ical_reader.parse_vcalendar ).to eq({'A' => {value: '1'}, 'B' => {value: '2'}})
    end
    context "with a VEVENT" do
      let(:io) { $io = StringIO.new("BEGIN:VEVENT\nA:1\nEND:VEVENT\nEND:VCALENDAR\n") }
      it "should parse VEVENT sub-elements" do
        expect( ical_reader.parse_vcalendar ).to eq({'VEVENT' => [{'A' => {value: '1'}}]})
      end
    end
    context "with a VTIMEZONE" do
      let(:io) { $io = StringIO.new("BEGIN:VTIMEZONE\nTZID:Test\nEND:VTIMEZONE\nEND:VCALENDAR\n") }
      it "should parse VTIMEZONE sub-elements" do
        hash = ical_reader.parse_vcalendar
        expect( hash ).to eq({'VTIMEZONE' => {'Test' => {'TZID' => {value: 'Test'}}}})
      end
    end
    context "with unrecognized sub-elements" do
      let(:io) { $io = StringIO.new("A:1\nBEGIN:TEST\nB:2\nEND:TEST\nC:3\nEND:VCALENDAR\n") }
      it "should ignore unrecognized sub-elements" do
        expect( ical_reader.parse_vcalendar ).to eq({'A' => {value: '1'}, 'C' => {value: '3'}})
      end
    end
    context "with a multi-parameter values" do
      let(:io) { $io = StringIO.new("TEST;KEY=value;TEST=yes:SUCCESS\nEND:VCALENDAR\n") }
      it "should handle multi-parameter values" do
        hash = ical_reader.parse_vcalendar
        expect( hash ).to eq({'TEST' => {value: 'SUCCESS', 'KEY' => 'value', 'TEST' => 'yes'}})
      end
    end
  end

  describe "#parse_vevent" do
    let(:io) { $io = StringIO.new("A:1\nB:2\nEND:VEVENT\nC:3\n") }
    it "should bump the icalendar reader’s io to the end of the vevent element" do
      ical_reader.parse_vevent
      expect( ical_reader.line_buffer ).to match /^C:3$/
    end
    it "should return a hash" do
      expect( ical_reader.parse_vevent ).to eq({'A' => {value: '1'}, 'B' => {value: '2'}})
    end
    context "with sub-elements" do
      let(:io) { $io = StringIO.new("A:1\nBEGIN:TEST\nB:2\nEND:TEST\nC:3\nEND:VEVENT\n") }
      it "should ignore sub-elements" do
        expect( ical_reader.parse_vevent ).to eq({'A' => {value: '1'}, 'C' => {value: '3'}})
      end
    end
    context "with dates" do
      let(:io) { $io = StringIO.new(
        "DTSTART;TZID=Canada/Central:20010203T143000\n" +
        "DTEND;TZID=America/Edmonton:20010607T133000\n" +
        "DTSTAMP:20010203T133000\n" +
        "LAST-MODIFIED:20010203T133000\n" +
        "CREATED:20010203T133000\n" +
        "\nEND:VEVENT\n"
      )}
      it "should parse dates" do
        expect( ical_reader.parse_vevent ).to eq({
          'DTSTART' => {value: '2001-02-03 14:30:00 CST'.to_datetime},
          'DTEND' => {value: '2001-06-07 13:30:00 MDT'.to_datetime},
          'DTSTAMP' => {value: '2001-02-03 13:30:00 UTC'.to_datetime},
          'LAST-MODIFIED' => {value: '2001-02-03 13:30:00 UTC'.to_datetime},
          'CREATED' => {value: '2001-02-03 13:30:00 UTC'.to_datetime}
        })
      end
    end
    context "with sequence" do
      let(:io) { $io = StringIO.new("SEQUENCE:123\nEND:VEVENT\n") }
      it "should treat sequence as an integer" do
        expect( ical_reader.parse_vevent ).to eq({'SEQUENCE' => {value: 123}})
      end
    end
    context "with multi-parameter values" do
      let(:io) { $io = StringIO.new("TEST;KEY=value;TEST=yes:SUCCESS\nEND:VEVENT\n") }
      it "should handle multi-parameter values" do
        expect( ical_reader.parse_vevent ).to eq(
          {'TEST' => {value: 'SUCCESS', 'KEY' => 'value', 'TEST' => 'yes'}}
        )
      end
    end
  end

  describe "#parse_vtimezone" do
    let(:io) { $io = StringIO.new("A:1\nB:2\nEND:VTIMEZONE\nC:3\n") }
    it "should bump the icalendar reader’s io to the end of the timezone element" do
        ical_reader.parse_vtimezone
        expect( ical_reader.line_buffer ).to match /^C:3$/
    end
    it "should return a hash" do
      expect( ical_reader.parse_vtimezone ).to eq({'A' => {value: '1'}, 'B' => {value: '2'}})
    end
    context "with sub-elements" do
      let(:io) { $io = StringIO.new("A:1\nBEGIN:TEST\nB:2\nEND:TEST\nC:3\nEND:VTIMEZONE\n") }
      it "should handle sub-elements" do
        expect( ical_reader.parse_vtimezone ).to eq(
          {'A' => {value: '1'}, 'TEST' => {'B' => {value: '2'}}, 'C' => {value: '3'}}
        )
      end
    end
  end

  describe "#parse_vtimezone_element" do
    let(:io) { $io = StringIO.new("A:1\nB:2\nEND:TEST\nC:3\n") }
    it "should bump the icalendar reader’s io to the end of the element" do
      ical_reader.parse_vtimezone_element('TEST')
      expect( ical_reader.line_buffer ).to match /^C:3$/
    end
    it "should return a hash" do
      hash = ical_reader.parse_vtimezone_element('TEST')
      expect( hash ).to eq({'A' => {value: '1'}, 'B' => {value: '2'}})
    end
  end

  describe "#parse_unrecognized_element" do
    let(:io) { $io = StringIO.new("A:1\nB:2\nEND:TEST\nC:3\n") }
    it "should return nil" do
      expect( ical_reader.parse_unrecognized_element('TEST') ).to be_nil
    end
    context "with a sub-element" do
      let(:io) { $io = StringIO.new("BEGIN:SUB\nA:1\nEND:SUB\nB:2\nEND:TEST\nC:3\n") }
      it "should bump the icalendar reader’s io to the end of the element" do
        ical_reader.parse_unrecognized_element('TEST')
        expect( ical_reader.line_buffer ).to match /^C:3$/
      end
    end
  end

  # Helpers

  describe "#clean_string" do
    it "should un-escape newlines" do
      expect( ical_reader.clean_string("Test\\nLine") ).to eq "Test\nLine"
    end
    it "should un-escape tabs" do
      expect( ical_reader.clean_string("Test\\tTab") ).to eq "Test\tTab"
    end
    it "should un-escape slashes" do
      expect( ical_reader.clean_string("Test\\\\Slash") ).to eq "Test\\Slash"
    end
    it "should un-escape assorted other characters" do
      expect( ical_reader.clean_string("Test\\,\\;\\:Chars") ).to eq "Test,;:Chars"
    end
  end

  describe "#parse_multivalue_line_chunks" do
    it "should generate a hash" do
      hash = ical_reader.parse_multivalue_line_chunks("KEY=thekey", "value")
      expect( hash ).to eq({value: 'value', 'KEY' => 'thekey'})
    end
    it "should handle multiple keyed values" do
      hash = ical_reader.parse_multivalue_line_chunks("A=1;B=2", "value")
      expect( hash ).to eq({value: 'value', 'A' => '1', 'B' => '2'})
    end
  end

end
