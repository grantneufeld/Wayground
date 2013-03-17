require 'spec_helper'

describe "calendar/year.html.erb" do
  before(:all) do
    @date = assign(:date, Date.new(2013, 1, 1))
    @user = User.first || FactoryGirl.create(:user)
    @total_event_count = assign(:total_event_count, 30)
    @event_counts = assign(:event_counts,
      {
        1 => 1, 2 => 14, 3 => 15, 4 => 16, 5 => 17, 6 => 18,
        7 => 19, 8 => 20, 9 => 21, 10 => 22, 11 => 23, 12 => 24
      }
    )
  end
  context "with no user" do
    before(:all) do
      assign(:user, nil)
    end
    it "should render a link to the previous year" do
      render
      expect( rendered ).to match /<a [^>]*href="\/calendar\/2012"[^>]*>/
    end
    it "should render a link to the next month" do
      render
      expect( rendered ).to match /<a [^>]*href="\/calendar\/2014"[^>]*>/
    end
    it "should render the calendar heading" do
      render
      expect( rendered ).to match /<h1>.*2013.*<\/h1>/
    end
    it "should render the event total count for the year" do
      render
      expect( rendered ).to match /[^0-9]30 events/
    end
    it "should render the months" do
      render
      expect( rendered ).to match /<a href="\/calendar\/2013\/01"[^>]*>January<\/a>.* 1 event[^s]/
      expect( rendered ).to match /<a href="\/calendar\/2013\/12"[^>]*>December<\/a>.* 24 events/
    end
  end
  context "with a user" do
    it "should show the new event link" do
      assign(:user, @user)
      render
      expect( rendered ).to match /<a href="\/events\/new"/
    end
  end
end
