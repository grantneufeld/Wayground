require 'spec_helper'
require 'calendar_month_presenter'
require 'event'
require 'event/day_events'
require_relative 'view_double'

describe CalendarMonthPresenter do

  let(:view) { $view = ViewDouble.new }

  describe "initialization" do
    it "should accept a view parameter" do
      presenter = CalendarMonthPresenter.new(view: :view, events: [])
      expect( presenter.view ).to eq :view
    end
    it "should accept a month parameter" do
      presenter = CalendarMonthPresenter.new(month: 12, events: [])
      expect( presenter.month ).to eq 12
    end
    it "should accept a year parameter" do
      presenter = CalendarMonthPresenter.new(year: 2002, events: [])
      expect( presenter.year ).to eq 2002
    end
    it "should accept a user parameter" do
      presenter = CalendarMonthPresenter.new(user: :user, events: [])
      expect( presenter.user ).to eq :user
    end
    it "should accept an events parameter and turn it into an EventsByDate" do
      time = Time.zone.parse('2000-01-02 03:04')
      event = Event.new(start_at: time)
      presenter = CalendarMonthPresenter.new(events: [event])
      expect( presenter.events_by_date[time.to_date] ).to eq([event])
    end
  end

  describe "#weeks" do
    it "should handle February in a leap year correctly" do
      start_date = Date.new(2004, 2, 1)
      end_date = Date.new(2004, 3, 6)
      # offset with a nil at the start so d[1] is feb 1
      d = [nil] + (start_date..end_date).to_a
      expected_weeks = [
        [d[1], d[2], d[3], d[4], d[5], d[6], d[7]],
        [d[8], d[9], d[10], d[11], d[12], d[13], d[14]],
        [d[15], d[16], d[17], d[18], d[19], d[20], d[21]],
        [d[22], d[23], d[24], d[25], d[26], d[27], d[28]],
        [d[29], d[30], d[31], d[32], d[33], d[34], d[35]]
      ]
      presenter = CalendarMonthPresenter.new(month: 2, year: 2004, events: [])
      expect( presenter.weeks ).to eq expected_weeks
    end
    it "should handle February in a non-leap year correctly" do
      start_date = Date.new(2010, 1, 31)
      end_date = Date.new(2010, 3, 6)
      d = (start_date..end_date).to_a
      expected_weeks = [
        [d[0], d[1], d[2], d[3], d[4], d[5], d[6]],
        [d[7], d[8], d[9], d[10], d[11], d[12], d[13]],
        [d[14], d[15], d[16], d[17], d[18], d[19], d[20]],
        [d[21], d[22], d[23], d[24], d[25], d[26], d[27]],
        [d[28], d[29], d[30], d[31], d[32], d[33], d[34]]
      ]
      presenter = CalendarMonthPresenter.new(month: 2, year: 2010, events: [])
      expect( presenter.weeks ).to eq expected_weeks
    end
    it "should handle when February 1 is a Sunday in a non-leap year correctly" do
      start_date = Date.new(2009, 2, 1)
      end_date = Date.new(2009, 2, 28)
      # offset with a nil at the start so d[1] is feb 1
      d = [nil] + (start_date..end_date).to_a
      expected_weeks = [
        [d[1], d[2], d[3], d[4], d[5], d[6], d[7]],
        [d[8], d[9], d[10], d[11], d[12], d[13], d[14]],
        [d[15], d[16], d[17], d[18], d[19], d[20], d[21]],
        [d[22], d[23], d[24], d[25], d[26], d[27], d[28]]
      ]
      presenter = CalendarMonthPresenter.new(month: 2, year: 2009, events: [])
      expect( presenter.weeks ).to eq expected_weeks
    end
  end

  describe "#present_weeks" do
    let(:presenter) { $presenter = CalendarMonthPresenter.new(view: view, year: 2013, month: 3, events: []) }
    it "should call through to present_week 6 times" do
      presenter.should_receive(:present_week).exactly(6).times.and_return('present_week'.html_safe)
      expect( presenter.present_weeks ).to match /(?:present_week){6}/
    end
    it "should return an html safe string" do
      presenter.stub(:present_week).and_return('present_week'.html_safe)
      expect( presenter.present_weeks.html_safe? ).to be_true
    end
  end

  describe "#present_week" do
    let(:presenter) { $presenter = CalendarMonthPresenter.new(view: view, events: []) }
    before(:all) do
      @week = ((Date.parse('2013-02-24'))..(Date.parse('2013-03-02'))).to_a
    end
    it "should wrap the result in a tr element" do
      presenter.stub(:present_day).and_return('present_day'.html_safe)
      expect( presenter.present_week(@week) ).to match /\A<tr>.*<\/tr>[\r\n]*\z/
    end
    it "should call through to present_day 7 times" do
      presenter.should_receive(:present_day).exactly(7).times.and_return('present_day'.html_safe)
      expect( presenter.present_week(@week) ).to match /(?:present_day){7}/
    end
    it "should return an html safe string" do
      presenter.stub(:present_day).and_return('present_day'.html_safe)
      expect( presenter.present_week(@week).html_safe? ).to be_true
    end
  end

  describe "#present_day" do
    let(:presenter) { $presenter = CalendarMonthPresenter.new(view: view, month: 8, events: []) }
    context "in the presenter’s month" do
      before(:all) do
        @day = Date.parse '2006-08-14'
      end
      it "should wrap the result in a td element" do
        presenter.stub(:present_day_elements).with(@day).and_return('present_day_elements'.html_safe)
        result = presenter.present_day(@day)
        expect( result ).to match /\A<td(?:| [^>]*)>/
        expect( result ).to match /<\/td>[\r\n]*\z/
      end
      it "should call through to present_day_elements" do
        presenter.should_receive(:present_day_elements).with(@day).
          and_return('present_day_elements'.html_safe)
        result = presenter.present_day(@day)
        expect( result ).to match /present_day_elements/
      end
      it "should return an html safe string" do
        presenter.stub(:present_day_elements).with(@day).and_return('present_day_elements'.html_safe)
        result = presenter.present_day(@day)
        expect( result.html_safe? ).to be_true
      end
    end
    context "outside the presenter’s month" do
      it "should set the class of the td element to outside_month" do
        day = Date.parse '2006-09-01'
        presenter.stub(:present_day_elements).with(day).and_return('present_day_elements'.html_safe)
        result = presenter.present_day(day)
        expect( result ).to match /\A<td (?:|[^>]* )class="(?:|[^"]* )outside_month(?:| [^"]*)"/
      end
    end
  end

  describe "#present_day_elements" do
    it "should call through to present_day_num and present_day_content" do
      presenter = CalendarMonthPresenter.new(view: view, events: [])
      presenter.stub(:present_day_num).with(:day).and_return('present_day_num')
      presenter.stub(:present_day_content).with(:day).and_return('present_day_content')
      expect( presenter.present_day_elements(:day) ).to eq 'present_day_numpresent_day_content'
    end
  end

  describe "#present_day_num" do
    context "with events" do
      before(:all) do
        @day = Date.parse '2007-09-27'
      end
      before(:each) do
        @presenter = CalendarMonthPresenter.new(view: ViewDouble.new, year: 2007, month: 9, events: events)
      end
      let(:result) { @presenter.present_day_num(@day) }
      let(:events) { [] }
      context 'with an event on the day' do
        before(:each) do
          Event.stub(:earliest_date).and_return(@day)
          Event.stub(:last_date).and_return(@day)
        end
        let(:events) { [Event.new(start_at: Time.zone.parse('2007-09-27 1pm'))] }
        it 'should not include the empty class in the anchor' do
          expect(result).not_to match(/ class="(?:|[^"]* )empty(?:| [^"]*)"/)
        end
      end
      context 'with no events on the day' do
        before(:each) do
          Event.stub(:earliest_date).and_return(@day)
          Event.stub(:last_date).and_return(@day)
        end
        it 'should include the empty class in the anchor' do
          expect(result).to match(/ class="(?:|[^"]* )empty(?:| [^"]*)"/)
        end
      end
      context 'with the only event on the day' do
        before(:each) do
          Event.stub(:earliest_date).and_return(@day)
          Event.stub(:last_date).and_return(@day)
          Event.stub(:count).and_return(1)
        end
        let(:events) { [Event.new(start_at: Time.zone.parse('2007-09-27 1pm'))] }
        it 'should return an anchor element' do
          expect(result).to match /\A<a [^>]*href="\/calendar\/2007\/09\/27"[^>]*>.*<\/a>\z/
        end
        it 'should have the date as the title of the anchor element' do
          expect(result).to match /\A<a [^>]*title="September 27, 2007"/
        end
        it 'should have the day number as the content with the anchor element' do
          expect(result).to match /\A<a [^>]*>27<\/a>\z/
        end
        it 'should return an html safe string' do
          expect(result.html_safe?).to be_true
        end
      end
      context 'with the day before the earliest event' do
        before(:each) do
          Event.stub(:earliest_date).and_return(Date.parse('2007-09-28'))
          Event.stub(:last_date).and_return(Date.parse('2008-09-10'))
        end
        it 'should return the unanchored date' do
          expect(result).to match /\A<span [^>]+>27<\/span>\z/
        end
        it 'should have the date as the title of the span element' do
          expect(result).to match /\A<span [^>]*title="September 27, 2007"/
        end
        it 'should return an html safe string' do
          expect(result.html_safe?).to be_true
        end
      end
      context 'with the day after the last event' do
        before(:each) do
          Event.stub(:earliest_date).and_return(Date.parse('2007-01-01'))
          Event.stub(:last_date).and_return(Date.parse('2007-09-26'))
        end
        it 'should return the unanchored date' do
          expect(result).to match /\A<span [^>]+>27<\/span>\z/
        end
        it 'should have the date as the title of the span element' do
          expect(result).to match /\A<span [^>]*title="September 27, 2007"/
        end
        it 'should return an html safe string' do
          expect(result.html_safe?).to be_true
        end
      end
      context 'with no events' do
        before(:each) do
          Event.stub(:count).and_return(0)
        end
        it 'should return the unanchored date' do
          expect(result).to match /\A<span [^>]+>27<\/span>\z/
        end
        it 'should have the date as the title of the span element' do
          expect(result).to match /\A<span [^>]*title="September 27, 2007"/
        end
        it 'should return an html safe string' do
          expect(result.html_safe?).to be_true
        end
      end
    end
  end

  describe "#present_day_content" do
    context "with events on the day" do
      before(:all) do
        @event = Event.new(start_at: Time.zone.parse('2011-07-13 12:11pm'))
        presenter = CalendarMonthPresenter.new(view: ViewDouble.new, year: 2011, month: 7, events: [@event])
        day = Date.parse '2011-07-13'
        @result = presenter.present_day_content(day)
      end
      it "should include the events count for the day" do
        expect( @result ).to match /<p>1 event<\/p>/
      end
      it "should include the list of events" do
        expect( @result ).to match /<div class="date_content">/
      end
      it "should return an html safe string" do
        expect( @result.html_safe? ).to be_true
      end
    end
    context "with no events on the day" do
      before(:all) do
        presenter = CalendarMonthPresenter.new(year: 1987, month: 2, events: [])
        @result = presenter.present_day_content(Date.parse('1987-02-21'))
      end
      it "should return an empty string" do
        expect( @result ).to eq ''
      end
      it "should return an html safe string" do
        expect( @result.html_safe? ).to be_true
      end
    end
  end

  describe "#get_day_events" do
    context "with an event" do
      before(:all) do
        @event = Event.new(start_at: Time.zone.parse('2013-04-17 1:23pm'))
        presenter = CalendarMonthPresenter.new(year: 2013, month: 4, events: [@event])
        @day = Date.parse '2013-04-17'
        @result = presenter.get_day_events(@day)
      end
      it "should have the event as its list of events" do
        expect( @result.all ).to eq [@event]
      end
      it "should have no carryover" do
        expect( @result.carryover ).to eq []
      end
    end
    context "with events to carryover" do
      before(:all) do
        @e1 = Event.new(start_at: Time.zone.parse('2003-01-01 1pm'))
        @e2 = Event.new(
          start_at: Time.zone.parse('2003-01-01 2pm'), end_at: Time.zone.parse('2003-01-03 3pm')
        )
        @e3 = Event.new(
          start_at: Time.zone.parse('2003-01-02 3pm'), end_at: Time.zone.parse('2003-01-03 4pm')
        )
        @e4 = Event.new(start_at: Time.zone.parse('2003-01-03 4pm'))
        presenter = CalendarMonthPresenter.new(year: 2003, month: 1, events: [@e1, @e2, @e3, @e4])
        @first_day_events = presenter.get_day_events(Date.parse('2003-01-01'))
        @second_day_events = presenter.get_day_events(Date.parse('2003-01-02'))
        @third_day_events = presenter.get_day_events(Date.parse('2003-01-03'))
      end
      context "for the first day" do
        it "should list the first and second event" do
          expect( @first_day_events.all ).to eq [@e1, @e2]
        end
        it "should carry over the second event" do
          expect( @first_day_events.carryover ).to eq [@e2]
        end
      end
      context "for the second day" do
        it "should list the second and third events" do
          expect( @second_day_events.all ).to eq [@e2, @e3]
        end
        it "should carry over the second and third events" do
          expect( @second_day_events.carryover.sort_by! {|e| e.start_at } ).to eq [@e2, @e3]
        end
      end
      context "for the third day" do
        it "should list the second, third and fourth events" do
          expect( @third_day_events.all ).to eq [@e2, @e3, @e4]
        end
        it "should have no carryover events" do
          expect( @third_day_events.carryover ).to eq []
        end
      end
    end
  end

  describe "#present_day_events_count" do
    context "with events" do
      before(:all) do
        presenter = CalendarMonthPresenter.new(events: [])
        events = [Event.new, Event.new]
        @result = presenter.present_day_events_count(events)
      end
      it "should present the count wrapped in a paragraph" do
        expect( @result ).to eq '<p>2 events</p>'
      end
      it "should return an html safe string" do
        expect( @result.html_safe? ).to be_true
      end
    end
    context "with a single event" do
      it "should present the count in singular form" do
        presenter = CalendarMonthPresenter.new(events: [])
        events = [Event.new]
        @result = presenter.present_day_events_count(events)
        expect( @result ).to eq '<p>1 event</p>'
      end
    end
    context "with an empty list" do
      before(:all) do
        presenter = CalendarMonthPresenter.new(events: [])
        @result = presenter.present_day_events_count([])
      end
      it "should return an empty string" do
        expect( @result ).to eq ''
      end
      it "should return an html safe string" do
        expect( @result.html_safe? ).to be_true
      end
    end
  end

  describe "#present_day_events" do
    context "with events" do
      let(:event) { $event = Event.new(start_at: Time.zone.parse('2007-08-09 10:11am')) }
      let(:event_list) do
        $event_list = Wayground::Event::DayEvents.new(events: [event])
      end
      let(:presenter) { $presenter = CalendarMonthPresenter.new(events: [event]) }
      it "should wrap the list in a div" do
        presenter.stub(:present_day_events_list).with([event]).and_return('events')
        expect( presenter.present_day_events(event_list) ).to eq '<div class="date_content">events</div>'
      end
      it "should return an html safe string" do
        presenter.stub(:present_day_events_list).with([event]).and_return('events')
        expect( presenter.present_day_events(event_list).html_safe? ).to be_true
      end
    end
    context "with an empty event list" do
      before(:all) do
        presenter = CalendarMonthPresenter.new(events: [])
        @result = presenter.present_day_events([])
      end
      it "should return a blank string when no events in the list" do
        expect( @result ).to eq ''
      end
      it "should return an html safe string" do
        expect( @result.html_safe? ).to be_true
      end
    end
  end

  describe "#present_day_events_list" do
    it "should return an html_safe string" do
      presenter = CalendarMonthPresenter.new(view: view, events: [])
      expect( presenter.present_day_events_list([]).html_safe? ).to be_true
    end
    it "should return the list wrapped in an unordered list element" do
      presenter = CalendarMonthPresenter.new(view: view, events: [])
      presenter.stub(:present_event_in_list).and_return('-'.html_safe)
      result = presenter.present_day_events_list([Event.new])
      expect( result ).to match /\A<ul>/
      expect( result ).to match /<\/ul>[\r\n]*\z/
    end
    it "should include all of the given events" do
      path = view.event_path(nil)
      start_at = Time.zone.parse '2011-03-14 6:30pm'
      events = [
        Event.new(start_at: start_at, title: 'Event 1'),
        Event.new(start_at: start_at, title: 'Event 2'),
        Event.new(start_at: start_at, title: 'Event 3')
      ]
      presenter = CalendarMonthPresenter.new(view: view, events: events)
      result = presenter.present_day_events_list(events)
      expect( result ).to match(
        /\A<ul>[\r\n]*
        <li><a\ href="#{path}"[^>]*>6:30pm:\ Event\ 1<\/a><\/li>[\r\n]+
        <li><a\ href="#{path}"[^>]*>6:30pm:\ Event\ 2<\/a><\/li>[\r\n]+
        <li><a\ href="#{path}"[^>]*>6:30pm:\ Event\ 3<\/a><\/li>[\r\n]*
        <\/ul>\z/x
      )
    end
  end

  describe "#present_event_in_list" do
    let(:title) { $title = 'Test Event' }
    let(:event_common_params) do
      $event_common_params = {start_at: Time.zone.parse('2012-3-15 7pm'), title: title}
    end
    let(:event_params) { $event_params = event_common_params }
    let(:event) { $event = Event.new(event_params) }
    let(:view) { $view = ViewDouble.new }
    let(:path) { $path = view.event_path(event) }
    let(:presenter) do
      $presenter = CalendarMonthPresenter.new(view: view, year: 2012, month: 3, events: [event])
    end
    it "should return the link wrapped in a list item element" do
      expect(
        presenter.present_event_in_list(event)
      ).to match /\A<li><a href="#{path}"[^>]*>7pm: #{title}<\/a><\/li>\n\z/
    end
    it "should return an html_safe string" do
      expect( presenter.present_event_in_list(event).html_safe? ).to be_true
    end
    context "with an all-day event" do
      let(:event_params) { $event_params = event_common_params.merge(is_allday: true) }
      it "should not include the time" do
        expect(
          presenter.present_event_in_list(event)
        ).to match /\A<li><a href="#{path}"[^>]*>#{title}<\/a><\/li>\n\z/
      end
    end
    context "with a cancelled event" do
      let(:event_params) { $event_params = event_common_params.merge(is_cancelled: true) }
      it "should set the “cancelled” class on the wrapping html element" do
        expect(
          presenter.present_event_in_list(event)
        ).to match /\A<[^>]+ class="(?:[^"]* )?cancelled(?: [^"]*)?"/
      end
    end
    context "with a tentative event" do
      let(:event_params) { $event_params = event_common_params.merge(is_tentative: true) }
      it "should set the “tentative” class on the wrapping html element" do
        expect(
          presenter.present_event_in_list(event)
        ).to match /\A<[^>]+ class="(?:[^"]* )?tentative(?: [^"]*)?"/
      end
    end
  end

end
