# encoding: utf-8
require 'spec_helper'

describe "calendar/month.html.erb" do
  before(:all) do
    @date = assign(:date, Date.new(2013, 3, 1))
    @user = User.first || FactoryGirl.create(:user)
    @event = FactoryGirl.create(:event,
      start_at: Time.zone.parse('2013-03-14 6pm'), title: 'Test Event', user: @user
    )
    @events = assign(:events, [@event])
  end
  context "with no user" do
    before(:all) do
      assign(:user, nil)
    end
    it "should assign the main section class to calendar" do
      view.should_receive(:set_main_section_class).with('calendar')
      render
    end
    it "should render a link to the previous month" do
      render
      expect( rendered ).to match /<a [^>]*href="\/calendar\/2013\/02"[^>]*>/
    end
    it "should render a link to the next month" do
      render
      expect( rendered ).to match /<a [^>]*href="\/calendar\/2013\/04"[^>]*>/
    end
    it "should render the calendar heading" do
      render
      expect( rendered ).to match /<h1>March .*2013.*<\/h1>/
    end
    it "should render the event on the 14th" do
      render
      expect( rendered ).to match /<a href="\/events\/#{@event.id}" title="6pm: Test Event">6pm: Test Event<\/a>/
    end
  end
  context "with a user" do
    it "should show the new event link" do
      assign(:user, @user)
      render
      expect( rendered ).to match /<a (?:|[^>]+ )href="\/events\/new"/
    end
  end
end
