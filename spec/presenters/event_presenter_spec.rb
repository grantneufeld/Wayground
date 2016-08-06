require 'rails_helper'
require 'event'
require 'event_presenter'
require 'user'
require_relative 'view_double'

describe EventPresenter do
  before(:all) do
    @admin = User.first || FactoryGirl.create(:user)
  end

  let(:view) { $view = ViewDouble.new }
  let(:start_at) { $start_at = Time.zone.parse('2003-04-05 6:07am') }
  let(:event) do
    $event = Event.new(title: 'Test Title', start_at: start_at, city: '', province: '', country: '')
  end
  let(:admin) { @admin }
  let(:user) { $user = User.new }
  let(:minimum_params) { $minimum_params = { view: view, event: event } }
  let(:presenter) { $presenter = EventPresenter.new(minimum_params) }

  describe "initialization" do
    context 'with minimum required params' do
      it 'should take a view parameter' do
        expect(EventPresenter.new(minimum_params).view).to eq view
      end
      it 'should take an event parameter' do
        expect(EventPresenter.new(minimum_params).event).to eq event
      end
      context 'with a user parameter' do
        it 'should take a user parameter' do
          expect(EventPresenter.new(minimum_params.merge(user: user)).user).to eq user
        end
      end
    end
    context 'without a view parameter' do
      it 'should throw an ArgumentError' do
        args = minimum_params.delete(:view)
        expect { EventPresenter.new(args) }.to raise_error(ArgumentError)
      end
    end
    context 'without an event parameter' do
      it 'should throw an ArgumentError' do
        args = minimum_params.delete(:event)
        expect { EventPresenter.new(args) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#present_in_list" do
    it "should wrap the result in an elment with html class “vevent”" do
      expect( presenter.present_in_list ).to match /\A<[^>]+ class="vevent"/
    end
    it "should call through to present_heading and present_details" do
      expect(presenter).to receive(:present_heading).and_return('1')
      expect(presenter).to receive(:present_details).and_return('2')
      expect( presenter.present_in_list ).to match />12</
    end
    it "should end with a line break" do
      expect( presenter.present_in_list ).to match /[\r\n]+\z/
    end
    it "should be html safe" do
      expect( presenter.present_in_list.html_safe? ).to be_truthy
    end
  end

  describe "#present_heading" do
    it "should wrap the result in an h4 elment" do
      expect( presenter.present_heading ).to match /\A<h4(?:| [^>]+)>[^•]+<\/h4>[\r\n]*\z/
    end
    it "should call through to present_status, present_schedule and present_title" do
      expect(presenter).to receive(:present_status).and_return('1')
      expect(presenter).to receive(:present_schedule).and_return('2')
      expect(presenter).to receive(:present_title).and_return('3')
      expect( presenter.present_heading ).to match />12:[\r\n]*3</
    end
    it "should end with a line break" do
      expect( presenter.present_heading ).to match /[\r\n]+\z/
    end
    it "should be html safe" do
      expect( presenter.present_heading.html_safe? ).to be_truthy
    end
    context "with a cancelled event" do
      let(:event) { $event = Event.new(title: 'Test Title', start_at: start_at, is_cancelled: true) }
      it "should wrap the result in an elment with the “cancelled” class" do
        expect( presenter.present_heading ).to match /\A<[^>]+ class="cancelled"/
      end
      it "should be html safe" do
        expect( presenter.present_heading.html_safe? ).to be_truthy
      end
    end
    context "with a tentative event" do
      let(:event) { $event = Event.new(title: 'Test Title', start_at: start_at, is_tentative: true) }
      it "should wrap the result in an elment with the “tentative” class" do
        expect( presenter.present_heading ).to match /\A<[^>]+ class="tentative"/
      end
      it "should be html safe" do
        expect( presenter.present_heading.html_safe? ).to be_truthy
      end
    end
  end

  describe "#event_heading_attrs" do
    context "with a plain event" do
      let(:event) { $event = Event.new }
      it "should return an empty hash" do
        expect( presenter.event_heading_attrs ).to eq({})
      end
    end
    context "with a cancelled event" do
      let(:event) { $event = Event.new(is_cancelled: true) }
      it "should return a hash with the “cancelled” class" do
        expect( presenter.event_heading_attrs ).to eq(class: ['cancelled'])
      end
    end
    context "with a tentative event" do
      let(:event) { $event = Event.new(is_tentative: true) }
      it "should return a hash with the “tentative” class" do
        expect( presenter.event_heading_attrs ).to eq(class: ['tentative'])
      end
    end
  end

  describe "#present_status" do
    context "with a cancelled event" do
      let(:event) { $event = Event.new(is_cancelled: true) }
      it "should return a cancelled notice in an element" do
        expect( presenter.present_status ).to match /\A<[^>]+>Cancelled:<\/[^>]+>[\r\n]+\z/
      end
      it "should be wrapped in an element with the html class “status”" do
        expect( presenter.present_status ).to match /\A<[^>]+ class="status"[^>]*>/
      end
      it "should be html safe" do
        expect( presenter.present_status.html_safe? ).to be_truthy
      end
    end
    context "with a tentative event" do
      let(:event) { $event = Event.new(is_tentative: true) }
      it "should return a tentative notice in an element" do
        expect( presenter.present_status ).to match /\A<[^>]+>Tentative:<\/[^>]+>[\r\n]+\z/
      end
      it "should be wrapped in an element with the html class “status”" do
        expect( presenter.present_status ).to match /\A<[^>]+ class="status"[^>]*>/
      end
      it "should be html safe" do
        expect( presenter.present_status.html_safe? ).to be_truthy
      end
    end
    context "with an event that is not tentative and has not been cancelled" do
      it "should return a blank string" do
        expect( presenter.present_status ).to eq ''
      end
      it "should be html safe" do
        expect( presenter.present_status.html_safe? ).to be_truthy
      end
    end
  end

  describe "#present_schedule" do
    context "with an all day event" do
      it "should call through to present_time_allday" do
        event.is_allday = true
        expect(presenter).to receive(:present_time_allday)
        presenter.present_schedule
      end
    end
    context "with an event that is not all day" do
      it "should call through to present_time" do
        event.is_allday = false
        expect(presenter).to receive(:present_time)
        presenter.present_schedule
      end
    end
  end

  describe "#present_schedule_with_date" do
    context "with an all day event" do
      let(:event) { $event = Event.new(is_allday: true, start_at: start_at) }
      it "should call through to present_time set to format with just the date" do
        expect(presenter).to receive(:present_time).with(:plain_date)
        presenter.present_schedule_with_date
      end
    end
    context "with an event that is not all day" do
      it "should call through to present_time set to format with date & time" do
        expect(presenter).to receive(:present_time).with(:plain_datetime)
        presenter.present_schedule_with_date
      end
    end
  end

  describe "#present_time" do
    context "with no end time" do
      let(:event) { $event = Event.new(start_at: '2005-06-07 8am') }
      it "should be a microformat dtstart time element containing the start time" do
        expect( presenter.present_time ).to eq(
          "<time class=\"dtstart\" datetime=\"2005-06-07T08:00:00-06:00\">8:00am</time>"
        )
      end
      it "should accept a time_format parameter" do
        expect( presenter.present_time(:plain_datetime) ).to eq(
          '<time class="dtstart" datetime="2005-06-07T08:00:00-06:00">Tuesday, June 7, 2005 at 8:00am</time>'
        )
      end
      it "should be html safe" do
        expect( presenter.present_time.html_safe? ).to be_truthy
      end
    end
    context "with an end time on the same day" do
      let(:event) { $event = Event.new(start_at: '2005-06-07 8am', end_at: '2005-06-07 9am') }
      it "should start with the microformat dtstart time element containing the start time" do
        expect( presenter.present_time ).to match(
          /\A<time class="dtstart" datetime="2005-06-07T08:00:00-06:00">8:00am<\/time>/
        )
      end
      it "should have an em-dash separating the start and end times" do
        expect( presenter.present_time ).to match /<\/time>—<time class="dtend"/
      end
      it "should end with the microformat dtend time element containing the end time" do
        expect( presenter.present_time ).to match(
          /<time class="dtend" datetime="2005-06-07T09:00:00-06:00">9:00am<\/time>\z/
        )
      end
      it "should be html safe" do
        expect( presenter.present_time.html_safe? ).to be_truthy
      end
    end
    context "with an end time on a later day" do
      let(:event) { $event = Event.new(start_at: '2005-06-07 8am', end_at: '2005-06-09 9am') }
      it "should start with the microformat dtstart time element containing the start time" do
        expect( presenter.present_time ).to match(
          /\A<time class="dtstart" datetime="2005-06-07T08:00:00-06:00">8:00am<\/time>/
        )
      end
      it "should have the word “to” between the start and end times" do
        expect( presenter.present_time ).to match /<\/time> to <time class="dtend"/
      end
      it "should end with the microformat dtend time element containing the end date and time" do
        expect( presenter.present_time ).to match(
          /<time\ class="dtend"\ datetime="2005-06-09T09:00:00-06:00">
          Thursday,\ June\ +9,\ 2005\ at\ +9:00am<\/time>\z/x
        )
      end
      it "should be html safe" do
        expect( presenter.present_time.html_safe? ).to be_truthy
      end
    end
  end

  describe "#present_time_allday" do
    context "with a single-day event" do
      let(:event) { $event = Event.new(is_allday: true, start_at: '2005-06-07 8am') }
      it "should return just a microformat dtstart time element" do
        expect( presenter.present_time_allday ).to match(
          /\A<time class="dtstart" datetime="2005-06-07T08:00:00-06:00" \/>\z/
        )
      end
      it "should be html safe" do
        expect( presenter.present_time_allday.html_safe? ).to be_truthy
      end
    end
    context "with a multi-day event" do
      let(:event) do
        $event = Event.new(is_allday: true, start_at: '2005-06-07 8am', end_at: '2005-06-09 9am')
      end
      it "should include a microformat element for the end time" do
        expect( presenter.present_time_allday ).to match(
          /<time class="dtend" datetime="2005-06-09T09:00:00-06:00"/
        )
      end
      it "should include the end date within a dtend time element" do
        expect( presenter.present_time_allday ).to match(
          /<time class="dtend"[^>]*>Thursday, June +9, 2005<\/time>/
        )
      end
      it "should be html safe" do
        expect( presenter.present_time_allday.html_safe? ).to be_truthy
      end
    end
  end

  describe "#present_title" do
    it "should wrap the result in an element with the html class “summary”" do
      expect( presenter.present_title ).to match /\A<[^>]+ class="summary"/
    end
    it "should return a link to the event, using the title" do
      allow(event).to receive(:id).and_return(234)
      expect( presenter.present_title ).to match(
        /<a (?:|[^>]+ )href="\/events\/234"(?:| [^>]+)>Test Title<\/a>/
      )
    end
    it "should be html safe" do
      expect( presenter.present_details.html_safe? ).to be_truthy
    end
  end

  describe "#present_details" do
    context "with lots of details" do
      let(:event) do
        $event = Event.new(
          location: 'Test Location', address: 'Test Address',
          description: 'Test Description', organizer: 'Test Organizer'
        )
      end
      it "should wrap the result in paragraph" do
        expect( presenter.present_details ).to match /\A<p(?:| [^>]*)>[^•]+<\/p>[\r\n]*\z/
      end
      it "should call through to present_minimal_location" do
        expect(presenter).to receive(:present_minimal_location).and_return(''.html_safe)
        presenter.present_details
      end
      it "should call through to present_description" do
        expect(presenter).to receive(:present_description).and_return(''.html_safe)
        presenter.present_details
      end
      it "should call through to present_organizer" do
        expect(presenter).to receive(:present_organizer).and_return(''.html_safe)
        presenter.present_details
      end
      it "should include all the detail chunks, separated by line breaks" do
        allow(presenter).to receive(:present_minimal_location).and_return('1'.html_safe)
        allow(presenter).to receive(:present_description).and_return('2'.html_safe)
        allow(presenter).to receive(:present_organizer).and_return('3'.html_safe)
        expect( presenter.present_details ).to match />1[\r\n]*<br \/>2[\r\n]*<br \/>3</
      end
      it "should be html safe" do
        expect( presenter.present_details.html_safe? ).to be_truthy
      end
      context "with a user" do
        let(:user) { $user = User.new }
        it "should call through to present_action_menu" do
          expect(presenter).to receive(:present_action_menu).and_return(''.html_safe)
          presenter.present_details
        end
        it "should include the action menu, separated by a line break" do
          allow(presenter).to receive(:present_minimal_location).and_return('1'.html_safe)
          allow(presenter).to receive(:present_description).and_return('2'.html_safe)
          allow(presenter).to receive(:present_organizer).and_return('3'.html_safe)
          allow(presenter).to receive(:present_action_menu).and_return('4'.html_safe)
          expect( presenter.present_details ).to match />1[\r\n]*<br \/>2[\r\n]*<br \/>3[\r\n]*<br \/>4</
        end
      end
    end
    context "with no details" do
      it "should return a blank string" do
        expect( presenter.present_details ).to eq ''
      end
      it "should be html safe" do
        expect( presenter.present_details.html_safe? ).to be_truthy
      end
      context "with a user" do
        let(:user) { $user = User.new }
        it "should call through to present_action_menu" do
          expect(presenter).to receive(:present_action_menu).and_return(''.html_safe)
          presenter.present_details
        end
        it "should include just the action menu" do
          allow(presenter).to receive(:present_action_menu).and_return('Action!'.html_safe)
          expect( presenter.present_details ).to match /\A<p(?:| [^>]+)>Action!<\/p>[\r\n]*\z/
        end
      end
    end
  end

  describe "#present_minimal_location" do
    context "with an event location" do
      let(:event) { $event = Event.new(location: 'Test Location') }
      it "should wrap the result in an elment that has “location” as the html class" do
        expect( presenter.present_minimal_location ).to match /\A<[^>]+ class="location"/
      end
      it "should wrap the location in an element that has “fn org” as the html class" do
        expect( presenter.present_minimal_location ).to match /<[^>]+ class="fn org"[^>]*>Test Location</
      end
      it "should be html safe" do
        expect( presenter.present_minimal_location.html_safe? ).to be_truthy
      end
    end
    context "with an event address" do
      let(:event) { $event = Event.new(address: 'Test Address') }
      it "should wrap the result in an elment that has “location” as the html class" do
        expect( presenter.present_minimal_location ).to match /\A<[^>]+ class="location"/
      end
      it "should wrap the “street-address” element in an element that has “adr” as the html class" do
        expect( presenter.present_minimal_location ).to match(
          /<[^>]+ class="adr"[^>]*><[^>]+ class="street-address"/
        )
      end
      it "should wrap the address in an element that has “street-address” as the html class" do
        expect( presenter.present_minimal_location ).to match(
          /<[^>]+ class="street-address"[^>]*>Test Address</
        )
      end
      it "should be html safe" do
        expect( presenter.present_minimal_location.html_safe? ).to be_truthy
      end
    end
    context "with both an event address and an event location" do
      let(:event) { $event = Event.new(location: 'Test Location', address: 'Test Address') }
      it "should wrap the result in an elment that has “location” as the html class" do
        expect( presenter.present_minimal_location ).to match /\A<[^>]+ class="location"/
      end
      it "should include the location followed by the address" do
        expect( presenter.present_minimal_location ).to match(
          /<[^>]+\ class="fn\ org"[^>]*>Test\ Location<\/[^>]+>,[\r\n]+
          <[^>]+\ class="adr"[^>]*><[^>]+\ class="street-address"[^>]*>Test\ Address</x
        )
      end
      it "should be html safe" do
        expect( presenter.present_minimal_location.html_safe? ).to be_truthy
      end
    end
    context "with no location or address" do
      it "should return an empty string" do
        expect( presenter.present_minimal_location ).to eq ''
      end
      it "should be html safe" do
        expect( presenter.present_minimal_location.html_safe? ).to be_truthy
      end
    end
  end

  describe "#present_location_block" do
    context "with location details" do
      let(:event) { $event = Event.new(location: 'Test Location', address: 'Test Address') }
      it "should join the details with a linebreak" do
        allow(presenter).to receive(:present_location_org).and_return('org')
        allow(presenter).to receive(:present_location_full_address).and_return('addr')
        expect( presenter.present_location_block ).to match /org[\r\n]*<br \/>[\r\n]*addr/
      end
      it "should wrap the details in a paragraph" do
        expect( presenter.present_location_block ).to match /\A<p[^•]+<\/p>[\r\n]*\z/
      end
      it "should wrap assign “location” as the class" do
        expect( presenter.present_location_block ).to match /\A<[^>]+ class="location"/
      end
    end
    context "with no location details" do
      it "should return an empty string" do
        expect( presenter.present_location_block ).to eq ''
      end
      it "should be html safe" do
        expect( presenter.present_location_block.html_safe? ).to be_truthy
      end
    end
  end

  describe "#present_location_org" do
    context "with location" do
      let(:event) { $event = Event.new(location: 'Test Location') }
      it "should be wrapped in a tag with class “fn org”" do
        expect( presenter.present_location_org ).to match /\A<[^>]+ class="fn org"/
      end
      it "should contain the location" do
        expect( presenter.present_location_org ).to match />Test Location</
      end
      it "should be html safe" do
        expect( presenter.present_location_org.html_safe? ).to be_truthy
      end
    end
    context "with location and location url" do
      let(:event) { $event = Event.new(location: 'Test Location', location_url: 'http://loc.tld/') }
      it "should be wrapped in a tag with class “fn org”" do
        expect( presenter.present_location_org ).to match /\A<[^>]+ class="fn org"/
      end
      it "should be wrapped in an anchor with the location url" do
        expect( presenter.present_location_org ).to match /\A<a [^>]*href="http:\/\/loc\.tld\/"/
      end
      it "should contain the location" do
        expect( presenter.present_location_org ).to match />Test Location</
      end
      it "should be html safe" do
        expect( presenter.present_location_org.html_safe? ).to be_truthy
      end
    end
    context "with no location details" do
      it "should return an empty string" do
        expect( presenter.present_location_org ).to eq ''
      end
      it "should be html safe" do
        expect( presenter.present_location_org.html_safe? ).to be_truthy
      end
    end
  end

  describe "#present_location_address" do
    context "with address" do
      let(:event) { $event = Event.new(address: '123 Test') }
      it "should be wrapped in a tag with class “adr”" do
        expect( presenter.present_location_address ).to match /\A<[^>]+ class="adr"/
      end
      it "should contain the address" do
        allow(presenter).to receive(:present_location_street_address).and_return('Address')
        expect( presenter.present_location_address ).to match '>Address<'
      end
      it "should be html safe" do
        expect( presenter.present_location_address.html_safe? ).to be_truthy
      end
    end
    context "with no location details" do
      it "should return an empty string" do
        expect( presenter.present_location_address ).to eq ''
      end
      it "should be html safe" do
        expect( presenter.present_location_address.html_safe? ).to be_truthy
      end
    end
  end

  describe "#present_location_full_address" do
    context "with address" do
      let(:event) { $event = Event.new(address: '123 Test', city: 'Testville') }
      it "should be wrapped in a tag with class “adr”" do
        expect( presenter.present_location_full_address ).to match /\A<[^>]+ class="adr"/
      end
      it "should contain the address and region, separated by a br tag" do
        allow(presenter).to receive(:present_location_street_address).and_return('Address')
        allow(presenter).to receive(:present_location_region).and_return('Region')
        expect( presenter.present_location_full_address ).to match />Address[\r\n]*<br \/>[\r\n]*Region</
      end
      it "should be html safe" do
        expect( presenter.present_location_full_address.html_safe? ).to be_truthy
      end
    end
    context "with just the region" do
      let(:event) { $event = Event.new(city: 'Testville') }
      it "should be wrapped in a tag with class “adr”" do
        expect( presenter.present_location_full_address ).to match /\A<[^>]+ class="adr"/
      end
      it "should contain the region" do
        allow(presenter).to receive(:present_location_region).and_return('Region')
        expect( presenter.present_location_full_address ).to match />Region</
      end
      it "should be html safe" do
        expect( presenter.present_location_full_address.html_safe? ).to be_truthy
      end
    end
    context "with no location details" do
      it "should return an empty string" do
        expect( presenter.present_location_full_address ).to eq ''
      end
      it "should be html safe" do
        expect( presenter.present_location_full_address.html_safe? ).to be_truthy
      end
    end
  end

  describe "#present_location_street_address" do
    context "with address" do
      let(:event) { $event = Event.new(address: '123 Test') }
      it "should be wrapped in a tag with class “street-address”" do
        expect( presenter.present_location_street_address ).to match /\A<[^>]+ class="street-address"/
      end
      it "should contain the address" do
        expect( presenter.present_location_street_address ).to match '>123 Test<'
      end
      it "should be html safe" do
        expect( presenter.present_location_street_address.html_safe? ).to be_truthy
      end
    end
    context "with address and location_url" do
      let(:event) { $event = Event.new(address: '123 Test', location_url: 'http://loc.tld/') }
      it "should be wrapped in a tag with class “street-address”" do
        expect( presenter.present_location_street_address ).to match /\A<[^>]+ class="street-address"/
      end
      it "should be wrapped in an anchor tag for the location_url" do
        expect( presenter.present_location_street_address ).to match /\A<a [^>]*href="http:\/\/loc\.tld\/"/
      end
      it "should contain the address" do
        expect( presenter.present_location_street_address ).to match '>123 Test<'
      end
      it "should be html safe" do
        expect( presenter.present_location_street_address.html_safe? ).to be_truthy
      end
    end
    context "with just a location_url" do
      let(:event) { $event = Event.new(location_url: 'http://loc.tld/') }
      it "should be wrapped in an anchor tag for the location_url" do
        expect( presenter.present_location_street_address ).to match /\A<a [^>]*href="http:\/\/loc\.tld\/"/
      end
      it "should contain the url" do
        expect( presenter.present_location_street_address ).to match '>http://loc.tld/<'
      end
      it "should be html safe" do
        expect( presenter.present_location_street_address.html_safe? ).to be_truthy
      end
    end
    context "with no location details" do
      it "should return an empty string" do
        expect( presenter.present_location_street_address ).to eq ''
      end
      it "should be html safe" do
        expect( presenter.present_location_street_address.html_safe? ).to be_truthy
      end
    end
  end

  describe "#present_location_region" do
    context "with a region" do
      let(:event) { $event = Event.new(city: 'Testville', province: 'Testia', country: 'Testland') }
      it "should be the region elements joined with commas" do
        allow(presenter).to receive(:present_location_city).and_return('City')
        allow(presenter).to receive(:present_location_province).and_return('Province')
        allow(presenter).to receive(:present_location_country).and_return('Country')
        expect( presenter.present_location_region ).to eq 'City, Province, Country'
      end
      it "should be html safe" do
        expect( presenter.present_location_region.html_safe? ).to be_truthy
      end
    end
    context "with no region" do
      it "should return an empty string" do
        expect( presenter.present_location_region ).to eq ''
      end
      it "should be html safe" do
        expect( presenter.present_location_region.html_safe? ).to be_truthy
      end
    end
  end

  describe "#present_location_city" do
    context "with a city" do
      let(:event) { $event = Event.new(city: 'Test') }
      it "should be wrapped in a tag with class “locality”" do
        expect( presenter.present_location_city ).to match /\A<[^>]+ class="locality"/
      end
      it "should contain the city" do
        expect( presenter.present_location_city ).to match '>Test<'
      end
      it "should be html safe" do
        expect( presenter.present_location_city.html_safe? ).to be_truthy
      end
    end
    context "with no city" do
      it "should return an empty string" do
        expect( presenter.present_location_city ).to eq ''
      end
      it "should be html safe" do
        expect( presenter.present_location_city.html_safe? ).to be_truthy
      end
    end
  end

  describe "#present_location_province" do
    context "with a province" do
      let(:event) { $event = Event.new(province: 'Test') }
      it "should be wrapped in a tag with class “region”" do
        expect( presenter.present_location_province ).to match /\A<[^>]+ class="region"/
      end
      it "should contain the province" do
        expect( presenter.present_location_province ).to match '>Test<'
      end
      it "should be html safe" do
        expect( presenter.present_location_province.html_safe? ).to be_truthy
      end
    end
    context "with no province" do
      it "should return an empty string" do
        expect( presenter.present_location_province ).to eq ''
      end
      it "should be html safe" do
        expect( presenter.present_location_province.html_safe? ).to be_truthy
      end
    end
  end

  describe "#present_location_country" do
    context "with a country" do
      let(:event) { $event = Event.new(country: 'Test') }
      it "should be wrapped in a tag with class “country-name”" do
        expect( presenter.present_location_country ).to match /\A<[^>]+ class="country-name"/
      end
      it "should contain the country" do
        expect( presenter.present_location_country ).to match '>Test<'
      end
      it "should be html safe" do
        expect( presenter.present_location_country.html_safe? ).to be_truthy
      end
    end
    context "with no country" do
      it "should return an empty string" do
        expect( presenter.present_location_country ).to eq ''
      end
      it "should be html safe" do
        expect( presenter.present_location_country.html_safe? ).to be_truthy
      end
    end
  end

  describe "#present_description" do
    context "with a description" do
      let(:event) { $event = Event.new(description: 'Test Description') }
      it "should enclose the content in an element with “description” as the html class" do
        expect( presenter.present_description ).to match(
          /\A<[^>]+ class="description"[^>]*>[^•]+<\/[^> ]+>[\r\n]*\z/
        )
      end
      it "should run the description through simple_text_to_html_breaks" do
        expect(view).to receive(:simple_text_to_html_breaks).with('Test Description').
          and_return('Test Description')
        presenter.present_description
      end
      it "should be html safe" do
        expect( presenter.present_description.html_safe? ).to be_truthy
      end
    end
    context "with no description" do
      it "should return an empty string" do
        expect( presenter.present_description ).to eq ''
      end
      it "should be html safe" do
        expect( presenter.present_description.html_safe? ).to be_truthy
      end
    end
  end

  describe "#present_organizer" do
    context "with an organizer url" do
      let(:event) { $event = Event.new(organizer: 'Test Organizer', organizer_url: 'http://organizer.tld/') }
      it "should begin with “Presented by”" do
        expect( presenter.present_organizer ).to match /\APresented by /
      end
      it "should include an anchor element for the url" do
        expect( presenter.present_organizer ).to match /<a (?:|[^>]+ )href="http:\/\/organizer\.tld\/"/
      end
      it "should display the organizer name in an element with the organizer html class" do
        expect( presenter.present_organizer ).to match /class="organizer"[^>]*>Test Organizer</
      end
      it "should end with a period" do
        expect( presenter.present_organizer ).to match /\.[\r\n]*\z/
      end
      it "should be html safe" do
        expect( presenter.present_organizer.html_safe? ).to be_truthy
      end
    end
    context "without an organizer url" do
      let(:event) { $event = Event.new(organizer: 'Test Organizer') }
      it "should begin with “Presented by”" do
        expect( presenter.present_organizer ).to match /\APresented by /
      end
      it "should not include an anchor element" do
        expect( presenter.present_organizer ).not_to match /<a /
      end
      it "should display the organizer name in an element with the organizer html class" do
        expect( presenter.present_organizer ).to match /class="organizer"[^>]*>Test Organizer</
      end
      it "should end with a period" do
        expect( presenter.present_organizer ).to match /\.[\r\n]*\z/
      end
      it "should be html safe" do
        expect( presenter.present_organizer.html_safe? ).to be_truthy
      end
    end
    context "with no organizer url" do
      it "should return an empty string" do
        expect( presenter.present_organizer ).to eq ''
      end
      it "should be html safe" do
        expect( presenter.present_organizer.html_safe? ).to be_truthy
      end
    end
  end

  describe "#present_action_menu" do
    context "with actions available to the user" do
      it "should list the actions" do
        allow(presenter).to receive(:present_edit_action).and_return(':edit:'.html_safe)
        allow(presenter).to receive(:present_approve_action).and_return(':approve:'.html_safe)
        allow(presenter).to receive(:present_delete_action).and_return(':delete:'.html_safe)
        expect( presenter.present_action_menu ).to match(
          /\A:edit::separator:\n:approve::separator:\n:delete:[\r\n]*\z/
        )
      end
      it "should be html safe" do
        allow(presenter).to receive(:present_edit_action).and_return(':edit:'.html_safe)
        allow(presenter).to receive(:present_approve_action).and_return(':approve:'.html_safe)
        allow(presenter).to receive(:present_delete_action).and_return(':delete:'.html_safe)
        expect( presenter.present_action_menu.html_safe? ).to be_truthy
      end
    end
    context "with no actions available" do
      it "should return an empty string" do
        expect( presenter.present_action_menu ).to eq ''
      end
      it "should be html safe" do
        expect( presenter.present_action_menu.html_safe? ).to be_truthy
      end
    end
  end

  describe "#present_edit_action" do
    context 'with a user with authority' do
      let(:presenter) { $presenter = EventPresenter.new(minimum_params.merge(user: admin)) }
      it "should return a edit link" do
        allow(event).to receive(:has_authority_for_user_to?).and_return(true)
        expect( presenter.present_edit_action ).to match /\A<a (?:|[^>]+ )href="\/events\/123\/edit"/
      end
      it "should be html safe" do
        allow(event).to receive(:has_authority_for_user_to?).and_return(true)
        expect( presenter.present_edit_action.html_safe? ).to be_truthy
      end
    end
    context "with a user without edit authority for the item" do
      let(:presenter) { $presenter = EventPresenter.new(minimum_params.merge(user: user)) }
      it "should return an empty string" do
        allow(event).to receive(:has_authority_for_user_to?).and_return(false)
        expect( presenter.present_edit_action ).to eq ''
      end
      it "should be html safe" do
        allow(event).to receive(:has_authority_for_user_to?).and_return(false)
        expect( presenter.present_edit_action.html_safe? ).to be_truthy
      end
    end
    context "without a user" do
      it "should return an empty string" do
        expect( presenter.present_edit_action ).to eq ''
      end
      it "should be html safe" do
        expect( presenter.present_edit_action.html_safe? ).to be_truthy
      end
    end
  end

  describe "#present_approve_action" do
    context 'with a user with authority' do
      let(:presenter) { $presenter = EventPresenter.new(minimum_params.merge(user: admin)) }
      it "should return an approve link" do
        allow(event).to receive(:has_authority_for_user_to?).and_return(true)
        expect( presenter.present_approve_action ).to match /\A<a (?:|[^>]+ )href="\/events\/123\/approve"/
      end
      it "should be html safe" do
        allow(event).to receive(:has_authority_for_user_to?).and_return(true)
        expect( presenter.present_approve_action.html_safe? ).to be_truthy
      end
    end
    context "with an approved event" do
      let(:presenter) { $presenter = EventPresenter.new(minimum_params.merge(user: admin)) }
      it "should return an empty string" do
        event.is_approved = true
        expect( presenter.present_approve_action ).to eq ''
      end
      it "should be html safe" do
        event.is_approved = true
        expect( presenter.present_approve_action.html_safe? ).to be_truthy
      end
    end
    context "with a user without approve authority for the item" do
      let(:presenter) { $presenter = EventPresenter.new(minimum_params.merge(user: user)) }
      it "should return an empty string" do
        allow(event).to receive(:has_authority_for_user_to?).and_return(false)
        expect( presenter.present_approve_action ).to eq ''
      end
      it "should be html safe" do
        allow(event).to receive(:has_authority_for_user_to?).and_return(false)
        expect( presenter.present_approve_action.html_safe? ).to be_truthy
      end
    end
    context "without a user" do
      it "should return an empty string" do
        expect( presenter.present_approve_action ).to eq ''
      end
      it "should be html safe" do
        expect( presenter.present_approve_action.html_safe? ).to be_truthy
      end
    end
  end

  describe "#present_delete_action" do
    context 'with a user with authority' do
      let(:presenter) { $presenter = EventPresenter.new(minimum_params.merge(user: admin)) }
      it "should return a delete link" do
        allow(event).to receive(:has_authority_for_user_to?).and_return(true)
        allow(event).to receive(:id).and_return(123)
        expect( presenter.present_delete_action ).to match /\A<a (?:|[^>]+ )href="\/events\/123\/delete"/
      end
      it "should be html safe" do
        allow(event).to receive(:has_authority_for_user_to?).and_return(true)
        allow(event).to receive(:id).and_return(123)
        expect( presenter.present_delete_action.html_safe? ).to be_truthy
      end
    end
    context "with a user without delete authority for the item" do
      let(:presenter) { $presenter = EventPresenter.new(minimum_params.merge(user: user)) }
      it "should return an empty string" do
        allow(event).to receive(:has_authority_for_user_to?).and_return(false)
        expect( presenter.present_delete_action ).to eq ''
      end
      it "should be html safe" do
        allow(event).to receive(:has_authority_for_user_to?).and_return(false)
        expect( presenter.present_delete_action.html_safe? ).to be_truthy
      end
    end
    context "without a user" do
      it "should return an empty string" do
        expect( presenter.present_delete_action ).to eq ''
      end
      it "should be html safe" do
        expect( presenter.present_delete_action.html_safe? ).to be_truthy
      end
    end
  end

end
