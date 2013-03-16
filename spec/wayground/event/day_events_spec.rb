# encoding: utf-8
require 'spec_helper'
require 'event/day_events'

describe Wayground::Event::DayEvents do

  describe "initialization" do
    it "should accept a day parameter" do
      events = Wayground::Event::DayEvents.new(day: 23)
      expect( events.instance_variable_get(:@day) ).to eq 23
    end
    it "should accept an events parameter" do
      events = Wayground::Event::DayEvents.new(events: [:event])
      expect( events.events ).to eq( [:event] )
    end
    it "should default events to an empty array" do
      events = Wayground::Event::DayEvents.new({})
      expect( events.events ).to eq( [] )
    end
    it "should accept a multiday parameter" do
      events = Wayground::Event::DayEvents.new(multiday: [:event])
      expect( events.multiday ).to eq( [:event] )
    end
    it "should default multiday to an empty array" do
      events = Wayground::Event::DayEvents.new({})
      expect( events.multiday ).to eq( [] )
    end
  end

  describe "#count" do
    it "should get the sum of the counts of the events and multiday arrays" do
      events = Wayground::Event::DayEvents.new(events: [1, 2, 3], multiday: [4, 5, 6])
      expect( events.count ).to eq 6
    end
  end

  describe "#all" do
    it "should merge the events and multiday arrays, sorted by start time" do
      event1 = Event.new(start_at: Time.zone.parse('12am'))
      event2 = Event.new(start_at: Time.zone.parse('12:00:01am'))
      event3 = Event.new(start_at: Time.zone.parse('6am'))
      event4 = Event.new(start_at: Time.zone.parse('7am'))
      event5 = Event.new(start_at: Time.zone.parse('8am'))
      event6 = Event.new(start_at: Time.zone.parse('12pm'))
      event7 = Event.new(start_at: Time.zone.parse('1pm'))
      event8 = Event.new(start_at: Time.zone.parse('11:59:59pm'))
      events = [event1, event3, event5, event7]
      multiday = [event2, event4, event6, event8]
      day_events = Wayground::Event::DayEvents.new(events: events, multiday: multiday)
      expect( day_events.all ).to eq [event1, event2, event3, event4, event5, event6, event7, event8]
    end
  end

  describe "#carryover" do
    it "should retun an empty array when there are no events going for more than one day" do
      now = Time.zone.now
      events = [Event.new(start_at: now)]
      day_events = Wayground::Event::DayEvents.new(day: now.to_date, events: events)
      expect( day_events.carryover ).to eq []
    end
    it "should return an empty array when there are no multi-day events going past the current day" do
      now = Time.zone.now
      multiday = [Event.new(start_at: 1.week.ago, end_at: now)]
      day_events = Wayground::Event::DayEvents.new(day: now.to_date, multiday: multiday)
      expect( day_events.carryover ).to eq []
    end
    it "should return an array of the events that go past the day" do
      now = Time.zone.now
      event = Event.new(start_at: now, end_at: 1.day.from_now)
      day_events = Wayground::Event::DayEvents.new(day: now.to_date, events: [event])
      expect( day_events.carryover ).to eq [event]
    end
    it "should return an array of the multiday events that go past the day" do
      now = Time.zone.now
      event = Event.new(start_at: 1.day.ago, end_at: 1.day.from_now)
      day_events = Wayground::Event::DayEvents.new(day: now.to_date, multiday: [event])
      expect( day_events.carryover ).to eq [event]
    end
    it "should return a combined array of the events and multiday events that go past the day" do
      now = Time.zone.now
      event1 = Event.new(start_at: 2.days.ago, end_at: 1.day.from_now)
      event2 = Event.new(start_at: 1.day.ago, end_at: 2.days.from_now)
      day_events = Wayground::Event::DayEvents.new(day: now.to_date, events: [event1], multiday: [event2])
      expect( day_events.carryover ).to eq [event1, event2]
    end
  end

end
