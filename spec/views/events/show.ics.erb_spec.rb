require 'rails_helper'

describe 'events/show.ics.erb', type: :view do
  before(:all) do
    Event.delete(123)
    Version.delete_all
    @event = FactoryGirl.create(
      :event,
      id: 123,
      user: nil,
      start_at: Time.zone.parse('2011-02-03 04:05:06 am MST'),
      end_at: Time.zone.parse('2011-07-08 09:10:11 am MDT'),
      is_allday: false,
      is_draft: false,
      is_approved: true,
      is_wheelchair_accessible: false,
      is_adults_only: false,
      is_tentative: false,
      is_cancelled: false,
      is_featured: false,
      title: 'A Title That Extends Beyond Seventy-Five Characters So We Can Test Line Folding',
      description: (
        'A description that goes on, and on, so it can exceed two lines of seventy-five characters.' \
        ' This should serve as a good test of the line folding. At least, that’s what I hope.'
      ),
      content: 'Content',
      organizer: 'Organizer',
      organizer_url: 'http://organizer.tld/',
      location: 'Location',
      address: 'Address',
      city: 'City',
      province: 'Province',
      country: 'CA',
      location_url: 'http://location.tld/',
      created_at: Time.zone.parse('2001-02-03 04:05:06 am MST'),
      updated_at: Time.zone.parse('2001-02-03 04:05:06 am UTC')
    )
    FactoryGirl.create(:external_link, url: 'http://1st.external.link/', item: @event)
    FactoryGirl.create(:external_link, url: 'http://2nd.external.link/', item: @event)
  end
  before(:each) do
    assign(:event, @event)
  end

  it 'renders the expected text' do
    render template: 'events/show.ics.erb'
    expect(rendered).to match(/\ABEGIN:VEVENT\r/)
    expect(rendered).to match(/^UID:123.event@calgarydemocracy.ca\r/)
    expect(rendered).to match(/^CREATED:20010203T110506Z\r/)
    expect(rendered).to match(/^DTSTAMP:20010203T040506Z\r/)
    expect(rendered).to match(%r{^DTSTART;TZID=America/Denver:20110203T040506\r})
    expect(rendered).to match(%r{^DTEND;TZID=America/Denver:20110708T091011\r})
    expect(rendered).to match(
      /^SUMMARY:A Title That Extends Beyond Seventy-Five Characters So We Can Test (\r\n?|\n) Line Folding\r/
    )
    expect(rendered).to match(
      /^DESCRIPTION:A\ description\ that\ goes\ on\\,\ and\ on\\,
      \ so\ it\ can\ exceed\ two\ line\r\n
      \ s\ of\ seventy-five\ characters\.
      \ This\ should\ serve\ as\ a\ good\ test\ of\ the\ line\r\n
      \ \ folding\.\ At\ least\\,\ that’s\ what\ I\ hope\.\r/x
    )
    expect(rendered).to match(/^CLASS:PUBLIC\r/)
    expect(rendered).to match(%r{^URL:http://[a-z0-9\.]+/events/123\r})
    expect(rendered).to match(/^LOCATION:Location \(Address\)\r/)
    expect(rendered).to match(/^STATUS:CONFIRMED\r/)
    expect(rendered).to match(%r{^ORGANIZER;CN=Organizer:http://organizer\.tld/\r})
    # expect(rendered).to match(%r{^ATTACH:http://1st\.external\.link/\r})
    # expect(rendered).to match(%r{^ATTACH:http://2nd\.external\.link/\r})
    expect(rendered).to match(/^SEQUENCE:1\r/)
    expect(rendered).to match(/^END:VEVENT[\r\n]*\z/)
  end
end
