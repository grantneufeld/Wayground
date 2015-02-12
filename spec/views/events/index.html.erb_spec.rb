require 'spec_helper'
require 'page_metadata'

describe 'events/index.html.erb', type: :view do
  before(:each) do
    assign(:events, [
      stub_model(Event,
        :user => nil,
        :start_at => Time.zone.parse('2012-01-01 11:00:00'),
        :end_at => nil,
        :is_allday => false,
        :is_draft => false,
        :is_approved => true,
        :is_wheelchair_accessible => false,
        :is_adults_only => false,
        :is_tentative => false,
        :is_cancelled => false,
        :is_featured => false,
        :title => "Title",
        :description => "Description",
        :content => "MyText",
        :organizer => "Organizer",
        :organizer_url => "Organizer Url",
        :location => "Location",
        :address => "Address",
        :city => "City",
        :province => "Province",
        :country => "Country",
        :location_url => "Location Url"
      ),
      stub_model(Event,
        :user => nil,
        :start_at => Time.zone.parse('2012-01-01 11:00:00'),
        :end_at => nil,
        :is_allday => false,
        :is_draft => false,
        :is_approved => true,
        :is_wheelchair_accessible => false,
        :is_adults_only => false,
        :is_tentative => false,
        :is_cancelled => true,
        :is_featured => false,
        :title => "Title",
        :description => "Description",
        :content => "MyText",
        :organizer => "Organizer",
        :organizer_url => "Organizer Url",
        :location => "Location",
        :address => "Address",
        :city => "City",
        :province => "Province",
        :country => "Country",
        :location_url => "Location Url"
      )
    ])
    allow(view).to receive(:add_submenu_item)
  end

  it "renders a list of events" do
    @page_metadata = Wayground::PageMetadata.new(title: 'Title')
    allow(view).to receive(:page_metadata).and_return(@page_metadata)
    render template: 'events/index.html.erb'
    assert_select "div.vevent>h4>span.status", :text => "Cancelled:", :count => 1
    assert_select "div.vevent>h4>time.dtstart", :text => "11:00am", :count => 2
    assert_select "div.vevent>h4>span.summary", :text => "Title", :count => 2
    assert_select "span.description", :text => "Description", :count => 2
    assert_select "a.organizer", :text => "Organizer", :count => 2
    #assert_select "tr>td", :text => "Organizer Url", :count => 2
    assert_select "span.location>a", text: "Location", count: 2
    assert_select "span.street-address", :text => "Address", :count => 2
    #assert_select "tr>td", :text => "City", :count => 2
    #assert_select "tr>td", :text => "Province", :count => 2
    #assert_select "tr>td", :text => "Country", :count => 2
    #assert_select "tr>td", :text => "Location Url", :count => 2
  end
end
