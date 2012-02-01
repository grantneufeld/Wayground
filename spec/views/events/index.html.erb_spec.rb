require 'spec_helper'

describe "events/index.html.erb" do
  before(:each) do
    assign(:events, [
      stub_model(Event,
        :user => nil,
        :start_at => Time.now,
        :end_at => nil,
        :is_allday => false,
        :is_draft => false,
        :is_approved => false,
        :is_wheelchair_accessible => false,
        :is_adults_only => false,
        :is_tentative => false,
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
        :start_at => Time.now,
        :end_at => nil,
        :is_allday => false,
        :is_draft => false,
        :is_approved => false,
        :is_wheelchair_accessible => false,
        :is_adults_only => false,
        :is_tentative => false,
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
  end

  it "renders a list of events" do
    render
    assert_select "div.vevent>h4>span.summary", :text => "Title", :count => 2
    assert_select "span.description", :text => "Description", :count => 2
    assert_select "a.organizer", :text => "Organizer", :count => 2
    #assert_select "tr>td", :text => "Organizer Url", :count => 2
    assert_select "span.location>span", :text => "Location", :count => 2
    assert_select "span.street-address", :text => "Address", :count => 2
    #assert_select "tr>td", :text => "City", :count => 2
    #assert_select "tr>td", :text => "Province", :count => 2
    #assert_select "tr>td", :text => "Country", :count => 2
    #assert_select "tr>td", :text => "Location Url", :count => 2
  end
end
