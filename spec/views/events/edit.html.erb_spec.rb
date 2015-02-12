require 'spec_helper'

describe 'events/edit.html.erb', type: :view do
  before(:each) do
    @event = assign(:event, stub_model(Event,
      :user => nil,
      :start_at => Time.zone.parse('June 12, 2015 at 11:30 AM'),
      :end_at => "",
      :is_allday => false,
      :is_draft => false,
      :is_approved => false,
      :is_wheelchair_accessible => false,
      :is_adults_only => false,
      :is_tentative => false,
      :is_cancelled => false,
      :is_featured => false,
      :title => "MyString",
      :description => "MyString",
      :content => "MyText",
      :organizer => "MyString",
      :organizer_url => "MyString",
      :location => "MyString",
      :address => "MyString",
      :city => "MyString",
      :province => "MyString",
      :country => "MyString",
      :location_url => "MyString"
    ))
  end

  it "renders the edit event form" do
    render

    assert_select "form", :action => events_path(@event), :method => "post" do
      #assert_select "input#event_user", :name => "event[user]"
      assert_select "input#event_start_at", :name => "event[start_at]"
      assert_select "input#event_end_at", :name => "event[end_at]"
      assert_select "input#event_is_allday", :name => "event[is_allday]"
      #assert_select "input#event_is_draft", :name => "event[is_draft]"
      #assert_select "input#event_is_approved", :name => "event[is_approved]"
      assert_select "input#event_is_wheelchair_accessible", :name => "event[is_wheelchair_accessible]"
      assert_select "input#event_is_adults_only", :name => "event[is_adults_only]"
      assert_select "input#event_is_tentative", :name => "event[is_tentative]"
      assert_select "input#event_is_cancelled", :name => "event[is_cancelled]"
      #assert_select "input#event_is_featured", :name => "event[is_featured]"
      assert_select "input#event_title", :name => "event[title]"
      assert_select "textarea#event_description", :name => "event[description]"
      assert_select "textarea#event_content", :name => "event[content]"
      assert_select "input#event_organizer", :name => "event[organizer]"
      assert_select "input#event_organizer_url", :name => "event[organizer_url]"
      assert_select "input#event_location", :name => "event[location]"
      assert_select "input#event_address", :name => "event[address]"
      assert_select "input#event_city", :name => "event[city]"
      assert_select "input#event_province", :name => "event[province]"
      assert_select "select#event_country", :name => "event[country]"
      assert_select "input#event_location_url", :name => "event[location_url]"
    end
  end
end
