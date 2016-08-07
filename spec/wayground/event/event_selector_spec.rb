require 'rails_helper'
require 'event/event_selector'
require 'event'
require 'user'

describe Wayground::Event::EventSelector do

  describe "initialization" do
    context 'with a “range” parameter' do
      it 'should accept “all” as the “range” parameter' do
        selector = Wayground::Event::EventSelector.new(range: 'all')
        expect(selector.range).to eq 'all'
      end
      it 'should accept “past” as the “range” parameter' do
        selector = Wayground::Event::EventSelector.new(range: 'all')
        expect(selector.range).to eq 'all'
      end
      it 'should default to “upcoming” for the range value' do
        selector = Wayground::Event::EventSelector.new(range: nil)
        expect(selector.range).to eq 'upcoming'
      end
    end
    context 'with a “tag” parameter' do
      it 'should accept an arbitrary string as the “tag” parameter' do
        selector = Wayground::Event::EventSelector.new({ tag: 'sometag' })
        expect(selector.tag).to eq 'sometag'
      end
      it 'should default to nil for the tag value' do
        selector = Wayground::Event::EventSelector.new({ tag: nil })
        expect(selector.tag).to eq nil
      end
    end
    context 'with a “user” parameter' do
      it 'should accept a User object as the “user” parameter' do
        user = User.new
        selector = Wayground::Event::EventSelector.new({ user: user })
        expect(selector.user).to eq user
      end
      it 'should not accept an ID value as the “user” parameter' do
        user = User.first || FactoryGirl.create(:user)
        selector = Wayground::Event::EventSelector.new({ user: user.id })
        expect(selector.user).to eq nil
      end
      it 'should default to nil for the user value' do
        selector = Wayground::Event::EventSelector.new({ user: nil })
        expect(selector.user).to eq nil
      end
    end
  end

  describe '#events' do
    context 'with “all” range' do
      it 'should select all events that are approved' do
        selector = Wayground::Event::EventSelector.new(range: 'all')
        expect(selector.events).to eq Event.all.approved
      end
    end
    context 'with “past” range' do
      it 'should select all past events that are approved' do
        selector = Wayground::Event::EventSelector.new(range: 'past')
        expect(selector.events).to eq Event.past.approved
      end
    end
    context 'with “upcoming” range' do
      it 'should select all upcoming events that are approved' do
        selector = Wayground::Event::EventSelector.new
        expect(selector.events).to eq Event.upcoming.approved
      end
    end
    context 'with an admin user' do
      it 'should not restrict the events to approved ones' do
        user = User.first || FactoryGirl.create(:user)
        selector = Wayground::Event::EventSelector.new({ user: user })
        expect(selector.events).to eq Event.upcoming
      end
    end
    context 'with a tag' do
      it 'should select all upcoming events that are approved and tagged with “a tag”' do
        selector = Wayground::Event::EventSelector.new({ tag: 'a tag' })
        expect(selector.events).to eq Event.upcoming.approved.tagged('a tag')
      end
    end
  end

  describe '#title' do
    context 'with “all” range' do
      it 'should just be “Events”' do
        selector = Wayground::Event::EventSelector.new(range: 'all')
        expect(selector.title).to eq 'Events'
      end
    end
    context 'with “past” range' do
      it 'should be “Events: Past”' do
        selector = Wayground::Event::EventSelector.new(range: 'past')
        expect(selector.title).to eq 'Events: Past'
      end
    end
    context 'with “upcoming” range' do
      it 'should be “Events: Upcoming”' do
        selector = Wayground::Event::EventSelector.new
        expect(selector.title).to eq 'Events: Upcoming'
      end
    end
    context 'with a tag' do
      it 'should identify the tag at the end of the title' do
        selector = Wayground::Event::EventSelector.new({ tag: 'a tag' })
        expect(selector.title).to match /\(tagged “a tag”\)\z/
      end
    end
  end

end
