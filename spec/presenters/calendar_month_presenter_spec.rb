require 'rails_helper'
require 'calendar_month_presenter'
require 'event'
require 'event/day_events'
require_relative 'view_double'

describe CalendarMonthPresenter do

  let(:view) { $view = ViewDouble.new }
  let(:year) { 2016 }
  let(:month) { 1 }
  let(:time) { Time.zone.parse("#{year}-#{month}-02 03:04") }
  let(:event) { $event = Event.new(start_at: time) }
  let(:events) { [event] }
  let(:user) { $user = User.new }
  let(:minimum_params) { $minimum_params = { view: view, year: year, month: month } }
  let(:presenter) { $presenter = CalendarMonthPresenter.new(minimum_params) }

  describe "initialization" do
    context 'with minimum required params' do
      it 'should take a view parameter' do
        expect(CalendarMonthPresenter.new(minimum_params).view).to eq view
      end
      it 'should take a year parameter' do
        expect(CalendarMonthPresenter.new(minimum_params).year).to eq year
      end
      it 'should take a month parameter' do
        expect(CalendarMonthPresenter.new(minimum_params).month).to eq month
      end
      context 'with an events parameter' do
        it 'should take an events parameter' do
          expect(
            CalendarMonthPresenter.new(minimum_params.merge(events: events)).events_by_date.events_by_date
          ).to eq(time.to_date => [event])
        end
      end
      context 'with a user parameter' do
        it 'should take a user parameter' do
          expect(CalendarMonthPresenter.new(minimum_params.merge(user: user)).user).to eq user
        end
      end
    end
    context 'without a view parameter' do
      it 'should throw an ArgumentError' do
        args = minimum_params.delete(:view)
        expect { CalendarMonthPresenter.new(args) }.to raise_error(ArgumentError)
      end
    end
    context 'without a year parameter' do
      it 'should throw an ArgumentError' do
        args = minimum_params.delete(:year)
        expect { CalendarMonthPresenter.new(args) }.to raise_error(ArgumentError)
      end
    end
    context 'without a month parameter' do
      it 'should throw an ArgumentError' do
        args = minimum_params.delete(:month)
        expect { CalendarMonthPresenter.new(args) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#weeks" do
    let(:month) { 2 }
    context 'in a leap year' do
      let(:year) { 2004 }
      it 'should handle February in a leap year correctly' do
        start_date = Date.new(year, 2, 1)
        end_date = Date.new(year, 3, 6)
        # offset with a nil at the start so d[1] is feb 1
        d = [nil] + (start_date..end_date).to_a
        expected_weeks = [
          [d[1], d[2], d[3], d[4], d[5], d[6], d[7]],
          [d[8], d[9], d[10], d[11], d[12], d[13], d[14]],
          [d[15], d[16], d[17], d[18], d[19], d[20], d[21]],
          [d[22], d[23], d[24], d[25], d[26], d[27], d[28]],
          [d[29], d[30], d[31], d[32], d[33], d[34], d[35]]
        ]
        expect(presenter.weeks).to eq expected_weeks
      end
    end
    context 'in a non-leap year' do
      let(:year) { 2010 }
      it 'should handle February in a non-leap year correctly' do
        start_date = Date.new(year, 1, 31)
        end_date = Date.new(year, 3, 6)
        d = (start_date..end_date).to_a
        expected_weeks = [
          [d[0], d[1], d[2], d[3], d[4], d[5], d[6]],
          [d[7], d[8], d[9], d[10], d[11], d[12], d[13]],
          [d[14], d[15], d[16], d[17], d[18], d[19], d[20]],
          [d[21], d[22], d[23], d[24], d[25], d[26], d[27]],
          [d[28], d[29], d[30], d[31], d[32], d[33], d[34]]
        ]
        expect(presenter.weeks).to eq expected_weeks
      end
    end
    context 'in a non-leap year where February starts on a Sunday' do
      let(:year) { 2009 }
      it 'should handle when February 1 is a Sunday in a non-leap year correctly' do
        start_date = Date.new(year, 2, 1)
        end_date = Date.new(year, 2, 28)
        # offset with a nil at the start so d[1] is feb 1
        d = [nil] + (start_date..end_date).to_a
        expected_weeks = [
          [d[1], d[2], d[3], d[4], d[5], d[6], d[7]],
          [d[8], d[9], d[10], d[11], d[12], d[13], d[14]],
          [d[15], d[16], d[17], d[18], d[19], d[20], d[21]],
          [d[22], d[23], d[24], d[25], d[26], d[27], d[28]]
        ]
        expect(presenter.weeks).to eq expected_weeks
      end
    end
  end

  describe "#present_weeks" do
    let(:year) { 2013 }
    let(:month) { 3 }
    it "should call through to present_week 6 times" do
      expect(presenter).to receive(:present_week).exactly(6).times.and_return('present_week'.html_safe)
      expect( presenter.present_weeks ).to match /(?:present_week){6}/
    end
    it "should return an html safe string" do
      allow(presenter).to receive(:present_week).and_return('present_week'.html_safe)
      expect( presenter.present_weeks.html_safe? ).to be_truthy
    end
  end

  describe "#present_week" do
    before(:all) do
      @week = ((Date.parse('2013-02-24'))..(Date.parse('2013-03-02'))).to_a
    end
    let(:year) { 2013 }
    let(:month) { 3 }
    it "should wrap the result in a tr element" do
      allow(presenter).to receive(:present_day).and_return('present_day'.html_safe)
      expect( presenter.present_week(@week) ).to match /\A<tr>.*<\/tr>[\r\n]*\z/
    end
    it "should call through to present_day 7 times" do
      expect(presenter).to receive(:present_day).exactly(7).times.and_return('present_day'.html_safe)
      expect( presenter.present_week(@week) ).to match /(?:present_day){7}/
    end
    it "should return an html safe string" do
      allow(presenter).to receive(:present_day).and_return('present_day'.html_safe)
      expect( presenter.present_week(@week).html_safe? ).to be_truthy
    end
  end

  describe "#present_day" do
    let(:year) { 2006 }
    let(:month) { 8 }
    context "in the presenter’s month" do
      before(:all) do
        @day = Date.parse '2006-08-14'
      end
      it "should wrap the result in a td element" do
        allow(presenter).to receive(:present_day_elements).with(@day).and_return('present_day_elements'.html_safe)
        result = presenter.present_day(@day)
        expect( result ).to match /\A<td(?:| [^>]*)>/
        expect( result ).to match /<\/td>[\r\n]*\z/
      end
      it "should call through to present_day_elements" do
        expect(presenter).to receive(:present_day_elements).with(@day).
          and_return('present_day_elements'.html_safe)
        result = presenter.present_day(@day)
        expect( result ).to match /present_day_elements/
      end
      it "should return an html safe string" do
        allow(presenter).to receive(:present_day_elements).with(@day).and_return('present_day_elements'.html_safe)
        result = presenter.present_day(@day)
        expect( result.html_safe? ).to be_truthy
      end
    end
    context "outside the presenter’s month" do
      it "should set the class of the td element to outside_month" do
        day = Date.parse '2006-09-01'
        allow(presenter).to receive(:present_day_elements).with(day).and_return('present_day_elements'.html_safe)
        result = presenter.present_day(day)
        expect( result ).to match /\A<td (?:|[^>]* )class="(?:|[^"]* )outside_month(?:| [^"]*)"/
      end
    end
  end

  describe "#present_day_elements" do
    it "should call through to present_day_num and present_day_content" do
      presenter = CalendarMonthPresenter.new(view: view, year: 2011, month: 11, events: [])
      allow(presenter).to receive(:present_day_num).with(:day).and_return('present_day_num')
      allow(presenter).to receive(:present_day_content).with(:day).and_return('present_day_content')
      expect( presenter.present_day_elements(:day) ).to eq 'present_day_numpresent_day_content'
    end
  end

  describe "#present_day_num" do
    context "with events" do
      before(:all) do
        @day = Time.zone.parse('2007-09-27').to_date
      end
      let(:year) { 2007 }
      let(:month) { 9 }
      let(:result) { presenter.present_day_num(@day) }
      context 'with an event on the day' do
        before(:each) do
          allow(Event).to receive(:earliest_date).and_return(@day)
          allow(Event).to receive(:last_date).and_return(@day)
        end
        let(:events) { [Event.new(start_at: Time.zone.parse('2007-09-27 1pm'))] }
        let(:presenter) { CalendarMonthPresenter.new(minimum_params.merge(events: events)) }
        it 'should not include the empty class in the anchor' do
          expect(result).not_to match(/ class="(?:|[^"]* )empty(?:| [^"]*)"/)
        end
      end
      context 'with no events on the day' do
        before(:each) do
          allow(Event).to receive(:earliest_date).and_return(@day)
          allow(Event).to receive(:last_date).and_return(@day)
        end
        it 'should include the empty class in the anchor' do
          expect(result).to match(/ class="(?:|[^"]* )empty(?:| [^"]*)"/)
        end
      end
      context 'with the only event on the day' do
        before(:each) do
          allow(Event).to receive(:earliest_date).and_return(@day)
          allow(Event).to receive(:last_date).and_return(@day)
          allow(Event).to receive(:count).and_return(1)
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
          expect(result.html_safe?).to be_truthy
        end
      end
      context 'with the day before the earliest event' do
        before(:each) do
          allow(Event).to receive(:earliest_date).and_return(Date.parse('2007-09-28'))
          allow(Event).to receive(:last_date).and_return(Date.parse('2008-09-10'))
        end
        it 'should return the unanchored date' do
          expect(result).to match /\A<span [^>]+>27<\/span>\z/
        end
        it 'should have the date as the title of the span element' do
          expect(result).to match /\A<span [^>]*title="September 27, 2007"/
        end
        it 'should return an html safe string' do
          expect(result.html_safe?).to be_truthy
        end
      end
      context 'with the day after the last event' do
        before(:each) do
          allow(Event).to receive(:earliest_date).and_return(Date.parse('2007-01-01'))
          allow(Event).to receive(:last_date).and_return(Date.parse('2007-09-26'))
        end
        it 'should return the unanchored date' do
          expect(result).to match /\A<span [^>]+>27<\/span>\z/
        end
        it 'should have the date as the title of the span element' do
          expect(result).to match /\A<span [^>]*title="September 27, 2007"/
        end
        it 'should return an html safe string' do
          expect(result.html_safe?).to be_truthy
        end
      end
      context 'with no events' do
        before(:each) do
          allow(Event).to receive(:count).and_return(0)
        end
        it 'should return the unanchored date' do
          expect(result).to match /\A<span [^>]+>27<\/span>\z/
        end
        it 'should have the date as the title of the span element' do
          expect(result).to match /\A<span [^>]*title="September 27, 2007"/
        end
        it 'should return an html safe string' do
          expect(result.html_safe?).to be_truthy
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
        expect( @result.html_safe? ).to be_truthy
      end
    end
    context "with no events on the day" do
      before(:all) do
        presenter = CalendarMonthPresenter.new(view: ViewDouble.new, year: 1987, month: 2, events: [])
        @result = presenter.present_day_content(Date.parse('1987-02-21'))
      end
      it "should return an empty string" do
        expect( @result ).to eq ''
      end
      it "should return an html safe string" do
        expect( @result.html_safe? ).to be_truthy
      end
    end
  end

  describe "#get_day_events" do
    context "with an event" do
      before(:all) do
        @event = Event.new(start_at: Time.zone.parse('2013-04-17 1:23pm'))
        presenter = CalendarMonthPresenter.new(view: ViewDouble.new, year: 2013, month: 4, events: [@event])
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
        presenter = CalendarMonthPresenter.new(view: ViewDouble.new, year: 2003, month: 1, events: [@e1, @e2, @e3, @e4])
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
        events = [
          Event.new(start_at: Time.zone.parse('2001-02-03 12:00')),
          Event.new(start_at: Time.zone.parse('2001-02-04 12:00'))
        ]
        presenter = CalendarMonthPresenter.new(view: ViewDouble.new, year: 2001, month: 2, events: events)
        @result = presenter.present_day_events_count(events)
      end
      it "should present the count wrapped in a paragraph" do
        expect( @result ).to eq '<p>2 events</p>'
      end
      it "should return an html safe string" do
        expect( @result.html_safe? ).to be_truthy
      end
    end
    context "with a single event" do
      it "should present the count in singular form" do
        events = [Event.new(start_at: Time.zone.parse('2002-03-04 12:00'))]
        presenter = CalendarMonthPresenter.new(view: ViewDouble.new, year: 2002, month: 3, events: events)
        @result = presenter.present_day_events_count(events)
        expect( @result ).to eq '<p>1 event</p>'
      end
    end
    context "with an empty list" do
      before(:all) do
        presenter = CalendarMonthPresenter.new(view: ViewDouble.new, year: 2003, month: 4, events: [])
        @result = presenter.present_day_events_count([])
      end
      it "should return an empty string" do
        expect( @result ).to eq ''
      end
      it "should return an html safe string" do
        expect( @result.html_safe? ).to be_truthy
      end
    end
  end

  describe "#present_day_events" do
    context "with events" do
      let(:event) { $event = Event.new(start_at: Time.zone.parse('2007-08-09 10:11am')) }
      let(:event_list) { $event_list = Wayground::Event::DayEvents.new(events: events) }
      let(:presenter) { $presenter = CalendarMonthPresenter.new(minimum_params.merge(events: events)) }
      it "should wrap the list in a div" do
        allow(presenter).to receive(:present_day_events_list).with(events).and_return('events')
        expect( presenter.present_day_events(event_list) ).to eq '<div class="date_content">events</div>'
      end
      it "should return an html safe string" do
        allow(presenter).to receive(:present_day_events_list).with(events).and_return('events')
        expect( presenter.present_day_events(event_list).html_safe? ).to be_truthy
      end
    end
    context "with an empty event list" do
      before(:each) do
        @result = presenter.present_day_events([])
      end
      it "should return a blank string when no events in the list" do
        expect( @result ).to eq ''
      end
      it "should return an html safe string" do
        expect( @result.html_safe? ).to be_truthy
      end
    end
  end

  describe "#present_day_events_list" do
    it "should return an html_safe string" do
      expect( presenter.present_day_events_list([]).html_safe? ).to be_truthy
    end
    it "should return the list wrapped in an unordered list element" do
      allow(presenter).to receive(:present_event_in_list).and_return('-'.html_safe)
      result = presenter.present_day_events_list(events)
      expect( result ).to match /\A<ul>/
      expect( result ).to match /<\/ul>[\r\n]*\z/
    end
    context 'with a bunch of events' do
      let(:year) { 2011 }
      let(:month) { 3 }
      let(:time) { Time.zone.parse '2011-03-14 6:30pm' }
      let(:events) do
        $events = [
          Event.new(start_at: time, title: 'Event 1'),
          Event.new(start_at: time, title: 'Event 2'),
          Event.new(start_at: time, title: 'Event 3')
        ]
      end
      let(:presenter) { $presenter = CalendarMonthPresenter.new(minimum_params.merge(events: events)) }
      it 'should include all of the given events' do
        path = view.event_path(nil)
        result = presenter.present_day_events_list(events)
        expect(result).to match(
          /\A<ul>[\r\n]*
          <li><a\ href="#{path}"[^>]*>6:30pm:\ Event\ 1<\/a><\/li>[\r\n]+
          <li><a\ href="#{path}"[^>]*>6:30pm:\ Event\ 2<\/a><\/li>[\r\n]+
          <li><a\ href="#{path}"[^>]*>6:30pm:\ Event\ 3<\/a><\/li>[\r\n]*
          <\/ul>\z/x
        )
      end
    end
  end

  describe "#present_event_in_list" do
    let(:title) { $title = 'Test Event' }
    let(:year) { 2012 }
    let(:month) { 3 }
    let(:event_common_params) do
      $event_common_params = {start_at: Time.zone.parse('2012-3-15 7pm'), title: title}
    end
    let(:event_params) { $event_params = event_common_params }
    let(:event) { $event = Event.new(event_params) }
    let(:path) { $path = view.event_path(event) }
    let(:presenter) { $presenter = CalendarMonthPresenter.new(minimum_params.merge(events: events)) }
    it "should return the link wrapped in a list item element" do
      expect(
        presenter.present_event_in_list(event)
      ).to match /\A<li><a href="#{path}"[^>]*>7pm: #{title}<\/a><\/li>\n\z/
    end
    it "should return an html_safe string" do
      expect( presenter.present_event_in_list(event).html_safe? ).to be_truthy
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
