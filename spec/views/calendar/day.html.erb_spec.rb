# encoding: utf-8
require 'spec_helper'

describe "calendar/day.html.erb" do
  before(:all) do
    User.delete_all
    @admin = FactoryGirl.create(:user, name: 'Admin User')
    @user = FactoryGirl.create(:user, name: 'Normal User')
  end
  before(:each) do
    @date = assign(:date, Date.new(2013, 3, 4))
    @event1 = stub_model(Event, id: 123, title: 'Test Title', start_at: Time.zone.parse('2013-03-04 1pm'))
    @event2 = stub_model(Event, id: 234, title: 'Test Title', start_at: Time.zone.parse('2013-03-04 2pm'))
    @events = assign(:events, [])
    view.stub(:add_submenu_item)
  end
  context "with no user" do
    before(:each) do
      assign(:user, nil)
    end
    it "should put the microformats profile element in the head" do
      render
      expect( view.view_flow.content[:head] ).to match(
        /<link rel="profile" href="http:\/\/microformats\.org\/profile\/hcalendar" \/>/
      )
    end
    it "should render a link to the previous day" do
      render
      expect( rendered ).to match /<a (?:|[^>]+ )href="\/calendar\/2013\/03\/03"/
    end
    it "should render a link to the next day" do
      render
      expect( rendered ).to match /<a (?:|[^>]+ )href="\/calendar\/2013\/03\/05"/
    end
    context "with no events" do
      before(:each) do
        @events = assign(:events, [])
      end
      it "should render the calendar heading" do
        render
        expect( rendered ).to match /<h1>0 events on Monday, <a href="\/calendar\/2013\/03"[^>]*>March<\/a> 4, <a href="\/calendar\/2013"[^>]*>2013<\/a><\/h1>/
      end
      it "should not render any events" do
        render
        expect( rendered ).not_to match /<[^>]+ class="(?:|[^"] )vevent(?:| [^"])"/
      end
    end
    context "with 1 event" do
      before(:each) do
        @events = assign(:events, [@event1])
      end
      it "should render the calendar heading" do
        render
        expect( rendered ).to match /<h1>1 event on Monday, <a href="\/calendar\/2013\/03"[^>]*>March<\/a> 4, <a href="\/calendar\/2013"[^>]*>2013<\/a><\/h1>/
      end
    end
    context "with multiple events" do
      before(:each) do
        @events = assign(:events, [@event1, @event2])
      end
      it "should render the calendar heading" do
        render
        expect( rendered ).to match /<h1>2 events on Monday, <a href="\/calendar\/2013\/03"[^>]*>March<\/a> 4, <a href="\/calendar\/2013"[^>]*>2013<\/a><\/h1>/
      end
    end
    it "should not show the new event action" do
      render
      expect( rendered ).not_to match /href="\/events\/new"/
    end
  end
  context "with a user" do
    before(:each) do
      assign(:user, @user)
      @events = assign(:events, [@event1])
    end

    context "with update permissions" do
      it "should show the action menu with the events" do
        @event1.stub(:has_authority_for_user_to?).and_return(true)
        @event1.stub(:is_approved?).and_return(false)
        render
        expect( rendered ).to match(
          /<a (?:|[^>]+ )href="\/events\/123\/edit"[^•]+<a (?:|[^>]+ )href="\/events\/123\/approve"[^•]+<a (?:|[^>]+ )href="\/events\/123\/delete"[^•]+/
        )
      end
    end
    context "with no update permission" do
      it "should not show the action menu with the events" do
        @event1.stub(:has_authority_for_user_to?).and_return(false)
        render
        expect( rendered ).not_to match(
          /href="\/events\/123\/edit"|href="\/events\/123\/approve"|href="\/events\/123\/delete"/
        )
      end
    end
  end
  context 'with an admin user' do
    before(:each) do
      assign(:user, @admin)
    end
    it 'should add the new event link to the submenu' do
      view.should_receive(:add_submenu_item).with(
        title: 'New Event', path: '/events/new', attrs: { class: 'new' }
      )
      render
    end
  end
end
