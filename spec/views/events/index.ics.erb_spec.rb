# encoding: utf-8
require 'spec_helper'

describe "events/index.ics.erb" do
  before(:each) do
    @events = assign(:events,
      [
      Factory.create(:event,
        :id => 123,
        :start_at => Time.parse('2011-02-03 04:05:06 am MST'),
        :is_allday => false,
        :is_draft => false,
        :is_approved => true,
        :is_wheelchair_accessible => false,
        :is_adults_only => false,
        :is_tentative => false,
        :is_cancelled => true,
        :is_featured => false,
        :title => "Event One",
        :created_at => Time.parse('2001-02-03 04:05:06 am MST'),
        :updated_at => Time.parse('2001-02-03 04:05:06 am UTC')
      ),
      Factory.create(:event,
        :id => 234,
        :start_at => Time.parse('2011-02-03 04:05:06 am MST'),
        :is_allday => false,
        :is_draft => false,
        :is_approved => true,
        :is_wheelchair_accessible => false,
        :is_adults_only => false,
        :is_tentative => true,
        :is_cancelled => false,
        :is_featured => false,
        :title => "Event Two",
        :created_at => Time.parse('2001-02-03 04:05:06 am MST'),
        :updated_at => Time.parse('2001-02-03 04:05:06 am UTC')
      )
      ]
    )
  end

  it "renders the expected text" do
    render
    rendered.should match(
    /\ABEGIN:VEVENT\r\nUID:123-event@wayground.ca\r\nCREATED:20010203T110506Z\r\nDTSTAMP:20010203T040506Z\r\nDTSTART;TZID=America\/Denver:20110203T040506\r\nSUMMARY:Event One\r\nCLASS:PUBLIC\r\nURL:http:\/\/[a-z0-9\.]+\/events\/123\r\nSTATUS:CANCELLED\r\nSEQUENCE:1\r\nEND:VEVENT\r\nBEGIN:VEVENT\r\nUID:234-event@wayground.ca\r\nCREATED:20010203T110506Z\r\nDTSTAMP:20010203T040506Z\r\nDTSTART;TZID=America\/Denver:20110203T040506\r\nSUMMARY:Event Two\r\nCLASS:PUBLIC\r\nURL:http:\/\/[a-z0-9\.]+\/events\/234\r\nSTATUS:TENTATIVE\r\nSEQUENCE:1\r\nEND:VEVENT(\r\n)?\z/
    )
  end
end
