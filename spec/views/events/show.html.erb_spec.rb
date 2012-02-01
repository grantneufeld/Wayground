require 'spec_helper'

describe "events/show.html.erb" do
  before(:each) do
    @event = assign(:event, stub_model(Event,
      :user => nil,
      :start_at => Time.now,
      :end_at => "",
      :is_allday => false,
      :is_draft => false,
      :is_approved => false,
      :is_wheelchair_accessible => false,
      :is_adults_only => false,
      :is_tentative => false,
      :is_featured => false,
      :title => "Title",
      :description => "Description",
      :content => "Content",
      :organizer => "Organizer",
      :organizer_url => "Organizer Url",
      :location => "Location",
      :address => "Address",
      :city => "City",
      :province => "Province",
      :country => "Country",
      :location_url => "Location Url"
    ))
  end

  it "renders attributes in <p>" do
    render
    rendered.should match(/Title/)
    rendered.should match(/Description/)
    rendered.should match(/Content/)
    rendered.should match(/Organizer/)
    rendered.should match(/href="Organizer Url"/)
    rendered.should match(/Location/)
    rendered.should match(/Address/)
    rendered.should match(/City/)
    rendered.should match(/Province/)
    rendered.should match(/Country/)
    rendered.should match(/href="Location Url"/)
  end
end
