require 'spec_helper'

describe 'events/show.html.erb', type: :view do
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
      :is_cancelled => false,
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
      :location_url => "http://location.url.tld/"
    ))
    view.stub(:add_submenu_item)
  end

  it "renders the expected text" do
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
    rendered.should match('href="http://location.url.tld/"')
  end

  it "renders the Cancelled notice" do
    @event = assign(:event, stub_model(Event, :start_at => Time.current, :title => 'Title',
      :is_cancelled => true
    ))
    render
    expect( rendered ).to match(
      /<h2\ class="cancelled\ summary">
      <span\ class="status"\ title="CANCELLED">Cancelled:<\/span>
      [\ \r\n\t]+Title<\/h2>/x
    )
  end
end
