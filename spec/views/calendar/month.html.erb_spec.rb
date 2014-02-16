require 'spec_helper'

describe "calendar/month.html.erb" do
  before(:all) do
    @date = assign(:date, Date.new(2013, 3, 1))
    User.delete_all
    @admin = FactoryGirl.create(:user, name: 'Admin User')
    @event = FactoryGirl.create(:event,
      start_at: Time.zone.parse('2013-03-14 6pm'), title: 'Test Event', user: @admin
    )
    @events = assign(:events, [@event])
  end
  before(:each) do
    view.stub(:add_submenu_item)
  end
  context "with no user" do
    before(:each) do
      assign(:user, nil)
    end
    it "should assign the main section class to calendar" do
      view.should_receive(:set_main_section_class).with('calendar')
      render
    end
    context 'with earlier and later events' do
      it 'should render a link to the previous month' do
        Event.stub(:earliest_date).and_return(Date.parse('2000-01-01'))
        render
        expect(rendered).to match /<a [^>]*href="\/calendar\/2013\/02"[^>]*>/
      end
      it 'should render a link to the next month' do
        Event.stub(:last_date).and_return(Date.parse('2100-01-01'))
        render
        expect(rendered).to match /<a [^>]*href="\/calendar\/2013\/04"[^>]*>/
      end
    end
    context 'with no events' do
      before(:each) do
        Event.stub(:earliest_date).and_return(nil)
        Event.stub(:last_date).and_return(nil)
        Event.stub(:count).and_return(0)
      end
      it 'should not render a link to the previous month' do
        render
        expect(rendered).not_to match /<a [^>]*href="\/calendar\/2013\/02"[^>]*>/
      end
      it 'should not render a link to the next month' do
        render
        expect(rendered).not_to match /<a [^>]*href="\/calendar\/2013\/04"[^>]*>/
      end
    end
    it "should render the calendar heading" do
      render
      expect( rendered ).to match /<h1>March .*2013.*<\/h1>/
    end
    it "should render the event on the 14th" do
      render
      expect(rendered).to match(
        /<a href="\/events\/#{@event.id}" title="6pm: Test Event">6pm: Test Event<\/a>/
      )
    end
  end
  context "with an admin user" do
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
