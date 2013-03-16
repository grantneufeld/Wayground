# encoding: utf-8
require 'spec_helper'
require 'event/events_by_date'
require 'event'

describe Wayground::Event::EventsByDate do

  describe "initialization" do
    it "should accept an array of events" do
      start_at = Time.zone.now
      event = Event.new(start_at: start_at)
      events = Wayground::Event::EventsByDate.new([event])
      expect( events.events_by_date ).to eq({start_at.to_date => [event]})
    end
    it "should default to an empty array" do
      events = Wayground::Event::EventsByDate.new
      expect( events.events_by_date ).to eq({})
    end
  end

  describe "#[]" do
    it "should return an array of the events on the given day" do
      time1 = 1.week.ago
      time_today = Time.zone.now
      time3 = 1.month.from_now
      array_of_events = []
      array_of_events << Event.new(start_at: time1, title: 'First')
      array_of_events << Event.new(start_at: time1, title: 'Second')
      array_of_events << Event.new(start_at: time_today, title: 'Third')
      array_of_events << Event.new(start_at: time_today, title: 'Fourth')
      array_of_events << Event.new(start_at: time3, title: 'Fifth')
      array_of_events << Event.new(start_at: time3, title: 'Sixth')
      events_today = array_of_events[2..3]
      events = Wayground::Event::EventsByDate.new(array_of_events)
      expect( events[time_today.to_date] ).to eq( events_today )
    end
  end

end
