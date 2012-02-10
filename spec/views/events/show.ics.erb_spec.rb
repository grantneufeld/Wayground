# encoding: utf-8
require 'spec_helper'

describe "events/show.ics.erb" do
  before(:each) do
    @event = Factory.create(:event,
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
    Factory.create(:external_link, :url => 'http://1st.external.link/', :item => @event)
    Factory.create(:external_link, :url => 'http://2nd.external.link/', :item => @event)
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
    render
    rendered.should match(/\ABEGIN:VEVENT$/)
    rendered.should match(/^UID:123-event@wayground.ca$/)
    rendered.should match(/^CREATED;TZID=America\/Denver:20010203T040506$/)
    rendered.should match(/^DTSTAMP;TZID=America\/Denver:20010202T210506$/)
    rendered.should match(/^DTSTART;TZID=America\/Denver:20110203T040506$/)
    rendered.should match(/^DTEND;TZID=America\/Denver:20110708T091011$/)
    rendered.should match(
      /^SUMMARY:A Title That Extends Beyond Seventy-Five Characters So We Can Test (\r\n?|\n) Line Folding$/
    )
    rendered.should match(
      /^DESCRIPTION:A description that goes on, and on, so it can exceed two lines (\r\n?|\n) of seventy-five characters\. This should serve as a good test of the line f(\r\n?|\n) olding\. At least, that’s what I hope\.$/
    )
    rendered.should match(/^CLASS:PUBLIC$/)
    rendered.should match(/^URL:http:\/\/[a-z0-9\.]+\/events\/123$/)
    rendered.should match(/^LOCATION:Location \(Address\)$/)
    rendered.should match(/^STATUS:CONFIRMED$/)
    rendered.should match(/^ORGANIZER;CN=Organizer:http:\/\/organizer\.tld\/$/)
    #rendered.should match(/^ATTACH:http:\/\/1st\.external\.link\/$/)
    #rendered.should match(/^ATTACH:http:\/\/2nd\.external\.link\/$/)
    rendered.should match(/^SEQUENCE:1$/)
    rendered.should match(/^END:VEVENT[\r\n]*\z/)
  end
end
