require 'spec_helper'
require 'calendar_controller'
require 'event'
require 'user'

describe CalendarController do
  before(:all) do
    Event.destroy_all
    creator = User.first || FactoryGirl.create(:user, :name => 'Event Creator')
    # create some events
    @e1 = FactoryGirl.create(:event, user: creator,
      start_at: '2003-12-31 11:00PM', end_at: '2003-12-31 11:59:59PM')
    @e2 = FactoryGirl.create(:event, user: creator,
      start_at: '2004-01-01 00:00AM', end_at: '2004-01-01 01:00AM')
    @e3 = FactoryGirl.create(:event, user: creator,
      start_at: '2004-02-28 11:00PM', end_at: '2004-02-28 11:59:59PM')
    @e4 = FactoryGirl.create(:event, user: creator,
      start_at: '2004-02-29 00:00AM', end_at: '2004-02-29 01:00AM')
    @e5 = FactoryGirl.create(:event, user: creator,
      start_at: '2004-02-29 11:00PM', end_at: '2004-02-29 11:59:59PM')
    @e6 = FactoryGirl.create(:event, user: creator,
      start_at: '2004-03-01 00:00AM', end_at: '2004-03-01 01:00AM')
    @e97 = FactoryGirl.create(:event, user: creator,
      start_at: '2004-12-31 11:00PM', end_at: '2004-12-31 11:59:59PM')
    @e98 = FactoryGirl.create(:event, user: creator,
      start_at: '2005-01-01 00:00AM', end_at: '2005-01-01 01:00AM')
    @e99 = FactoryGirl.create(:event, user: creator,
      start_at: '2005-02-28 00:00AM', end_at: '2005-02-28 01:00AM')
  end

  describe 'GET "index"' do
    it 'redirects to the current calendar month' do
      get 'index'
      date = Date.today
      expect( response ).to redirect_to(calendar_month_url(date.year, date.strftime('%m')))
    end
  end

  describe 'GET "subscribe"' do
    it 'should return http success' do
      get 'subscribe'
      expect( response ).to be_success
    end
    it 'should use the subscribe view' do
      get 'subscribe'
      expect( response ).to render_template('subscribe')
    end
  end

  describe "GET 'year'" do
    it "should return http success" do
      get 'year', year: '2000'
      expect( response ).to be_success
    end
    it "should use the year view" do
      get 'year', year: '2000'
      expect( response ).to render_template("year")
    end
    it "should set the date" do
      get 'year', year: '2000'
      expect( assigns(:date).year ).to eq 2000
    end
    it "should set the page title" do
      get 'year', year: '2000'
      expect( assigns(:page_metadata).title ).to eq '2000'
    end
    it "should set the total number of events occuring in the year" do
      get 'year', year: '2004'
      expect( assigns(:total_event_count) ).to eq 6
    end
    it "should set the event counts for each month in the year" do
      get 'year', year: '2004'
      expect( assigns(:event_counts) ).to eq(
        {1 => 1, 2 => 3, 3 => 1, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 1}
      )
    end
    context "with an invalid date" do
      it "should return a 404 for a year too far in the future" do
        get 'year', year: '3000'
        expect( response.status ).to eq 404
      end
    end
  end

  describe "GET 'month'" do
    it "should return http success" do
      get 'month', year: '2000', month: '04'
      expect( response ).to be_success
    end
    it "should use the month view" do
      get 'month', year: '2000', month: '04'
      expect( response ).to render_template("month")
    end
    it "should set the year" do
      get 'month', year: '2000', month: '04'
      expect( assigns(:date).year ).to eq 2000
    end
    it "should set the month" do
      get 'month', year: '2000', month: '05'
      expect( assigns(:date).month ).to eq 5
    end
    it "should set the page title" do
      get 'month', year: '2000', month: '04'
      expect( assigns(:page_metadata).title ).to eq 'April 2000'
    end
    it "should grab all the relevant events" do
      get 'month', year: '2004', month: '02'
      expect( assigns(:events) ).to eq [@e3, @e4, @e5]
    end
  end

  describe "GET 'day'" do
    it "should return http success" do
      get 'day', year: '2000', month: '01', day: '01'
      expect( response ).to be_success
    end
    it "should use the day view" do
      get 'day', year: '2000', month: '01', day: '01'
      expect( response ).to render_template("day")
    end
    it "should set the year" do
      get 'day', year: '2000', month: '01', day: '01'
      expect( assigns(:date).year ).to eq 2000
    end
    it "should set the month" do
      get 'day', year: '2000', month: '04', day: '01'
      expect( assigns(:date).month ).to eq 4
    end
    it "should set the day" do
      get 'day', year: '2000', month: '01', day: '06'
      expect( assigns(:date).day ).to eq 6
    end
    it "should set the page title" do
      get 'day', year: '2000', month: '01', day: '01'
      expect( assigns(:page_metadata).title ).to eq 'January 1, 2000'
    end
    it "should grab all the relevant events" do
      get 'day', year: '2004', month: '02', day: '29'
      expect( assigns(:events) ).to eq [@e4, @e5]
    end
    it "should handle a day in February on a leap year" do
      get 'day', year: '2004', month: '02', day: '29'
      expect( response ).to be_success
    end
    it "should handle a day in February on a non-leap year" do
      get 'day', year: '2005', month: '02', day: '28'
      expect( response ).to be_success
    end
    it "should handle a day in a month with just 30 days" do
      get 'day', year: '2004', month: '06', day: '30'
      expect( response ).to be_success
    end
    context "with an invalid date" do
      it "should return a 404 for April 31" do
        get 'day', year: '2004', month: '04', day: '31'
        expect( response.status ).to eq 404
      end
      it "should return a 404 for February 29, 2005" do
        get 'day', year: '2005', month: '02', day: '29'
        expect( response.status ).to eq 404
      end
    end
  end

end
