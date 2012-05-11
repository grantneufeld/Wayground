# encoding: utf-8
require 'spec_helper'

describe "events/show.ics.erb" do
  before(:each) do
    @event = FactoryGirl.create(:event,
      :id => 123,
      :user => nil,
      :start_at => Time.parse('2011-02-03 04:05:06 am MST'),
      :end_at => Time.parse('2011-07-08 09:10:11 am MDT'),
      :is_allday => false,
      :is_draft => false,
      :is_approved => true,
      :is_wheelchair_accessible => false,
      :is_adults_only => false,
      :is_tentative => false,
      :is_cancelled => false,
      :is_featured => false,
      :title => "A Title That Extends Beyond Seventy-Five Characters So We Can Test Line Folding",
      :description => "A description that goes on, and on, so it can exceed two lines of seventy-five characters. This should serve as a good test of the line folding. At least, that’s what I hope.",
      :content => "Content",
      :organizer => "Organizer",
      :organizer_url => "http://organizer.tld/",
      :location => "Location",
      :address => "Address",
      :city => "City",
      :province => "Province",
      :country => "CA",
      :location_url => "http://location.tld/",
      :created_at => Time.parse('2001-02-03 04:05:06 am MST'),
      :updated_at => Time.parse('2001-02-03 04:05:06 am UTC')
    )
    FactoryGirl.create(:external_link, :url => 'http://1st.external.link/', :item => @event)
    FactoryGirl.create(:external_link, :url => 'http://2nd.external.link/', :item => @event)
    assign(:event, Event.find(123))
    #@event ||= assign(:event, stub_model(Event,
    #  :id => 123,
    #  :user => nil,
    #  :start_at => Time.parse('2011-02-03 04:05:06 am MST'),
    #  :end_at => Time.parse('2011-07-08 09:10:11 am MDT'),
    #  :is_allday => false,
    #  :is_draft => false,
    #  :is_approved => true,
    #  :is_wheelchair_accessible => false,
    #  :is_adults_only => false,
    #  :is_tentative => false,
    #  :is_cancelled => false,
    #  :is_featured => false,
    #  :title => "A Title That Extends Beyond Seventy-Five Characters So We Can Test Line Folding",
    #  :description => "A description that goes on, and on, so it can exceed two lines of seventy-five characters. This should serve as a good test of the line folding. At least, that’s what I hope.",
    #  :content => "Content",
    #  :organizer => "Organizer",
    #  :organizer_url => "Organizer Url",
    #  :location => "Location",
    #  :address => "Address",
    #  :city => "City",
    #  :province => "Province",
    #  :country => "Country",
    #  :location_url => "Location Url",
    #  :created_at => Time.parse('2001-02-03 04:05:06 am MST'),
    #  :updated_at => Time.parse('2001-02-03 04:05:06 am UTC'),
    #  :external_links => @external_links
    #))
  end

  it "renders the expected text" do
    render :template => "events/show.ics.erb"
    rendered.should match(/\ABEGIN:VEVENT\r/)
    rendered.should match(/^UID:123-event@wayground.ca\r/)
    rendered.should match(/^CREATED:20010203T110506Z\r/)
    rendered.should match(/^DTSTAMP:20010203T040506Z\r/)
    rendered.should match(/^DTSTART;TZID=America\/Denver:20110203T040506\r/)
    rendered.should match(/^DTEND;TZID=America\/Denver:20110708T091011\r/)
    rendered.should match(
      /^SUMMARY:A Title That Extends Beyond Seventy-Five Characters So We Can Test (\r\n?|\n) Line Folding\r/
    )
    rendered.should match(
      /^DESCRIPTION:A description that goes on\\, and on\\, so it can exceed two line\r\n s of seventy-five characters\. This should serve as a good test of the line\r\n  folding\. At least\\, that’s what I hope\.\r/
    )
    rendered.should match(/^CLASS:PUBLIC\r/)
    rendered.should match(/^URL:http:\/\/[a-z0-9\.]+\/events\/123\r/)
    rendered.should match(/^LOCATION:Location \(Address\)\r/)
    rendered.should match(/^STATUS:CONFIRMED\r/)
    rendered.should match(/^ORGANIZER;CN=Organizer:http:\/\/organizer\.tld\/\r/)
    #rendered.should match(/^ATTACH:http:\/\/1st\.external\.link\/\r/)
    #rendered.should match(/^ATTACH:http:\/\/2nd\.external\.link\/\r/)
    rendered.should match(/^SEQUENCE:1\r/)
    rendered.should match(/^END:VEVENT[\r\n]*\z/)
  end
end
