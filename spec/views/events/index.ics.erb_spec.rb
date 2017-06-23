require 'rails_helper'

describe 'events/index.ics.erb', type: :view do
  before(:each) do
    Event.delete_all
    Version.delete_all
    @events = assign(
      :events,
      [
        FactoryGirl.create(
          :event,
          id: 123,
          start_at: Time.zone.parse('2011-02-03 04:05:06 am MST'),
          is_allday: false,
          is_draft: false,
          is_approved: true,
          is_wheelchair_accessible: false,
          is_adults_only: false,
          is_tentative: false,
          is_cancelled: true,
          is_featured: false,
          title: 'Event One',
          created_at: Time.zone.parse('2001-02-03 04:05:06 am MST'),
          updated_at: Time.zone.parse('2001-02-03 04:05:06 am UTC')
        ),
        FactoryGirl.create(
          :event,
          id: 234,
          start_at: Time.zone.parse('2011-02-03 04:05:06 am MST'),
          is_allday: false,
          is_draft: false,
          is_approved: true,
          is_wheelchair_accessible: false,
          is_adults_only: false,
          is_tentative: true,
          is_cancelled: false,
          is_featured: false,
          title: 'Event Two',
          created_at: Time.zone.parse('2001-02-03 04:05:06 am MST'),
          updated_at: Time.zone.parse('2001-02-03 04:05:06 am UTC')
        )
      ]
    )
  end

  it 'renders the expected text' do
    render
    expect(rendered).to match(
      %r{\ABEGIN:VEVENT\r\n
      UID:123.event@calgarydemocracy.ca\r\n
      CREATED:20010203T110506Z\r\nDTSTAMP:20010203T040506Z\r\n
      DTSTART;TZID=America/Denver:20110203T040506\r\n
      SUMMARY:Event\ One\r\nCLASS:PUBLIC\r\n
      URL:http://[a-z0-9\.]+/events/123\r\n
      STATUS:CANCELLED\r\nSEQUENCE:1\r\n
      END:VEVENT\r\n
      BEGIN:VEVENT\r\n
      UID:234.event@calgarydemocracy.ca\r\n
      CREATED:20010203T110506Z\r\nDTSTAMP:20010203T040506Z\r\n
      DTSTART;TZID=America/Denver:20110203T040506\r\n
      SUMMARY:Event\ Two\r\nCLASS:PUBLIC\r\n
      URL:http://[a-z0-9\.]+/events/234\r\n
      STATUS:TENTATIVE\r\nSEQUENCE:1\r\n
      END:VEVENT(\r\n)?\z}x
    )
  end
end
