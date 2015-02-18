require 'rails_helper'

describe 'calendar/year.html.erb', type: :view do
  before(:all) do
    @date = assign(:date, Date.new(2013, 1, 1))
    User.delete_all
    @admin = FactoryGirl.create(:user, name: 'Admin User')
    @total_event_count = assign(:total_event_count, 30)
    @event_counts = assign(:event_counts,
      {
        1 => 1, 2 => 14, 3 => 15, 4 => 16, 5 => 17, 6 => 18,
        7 => 19, 8 => 20, 9 => 21, 10 => 22, 11 => 23, 12 => 24
      }
    )
  end
  before(:each) do
    allow(view).to receive(:add_submenu_item)
  end
  context "with no user" do
    before(:all) do
      assign(:user, nil)
    end
    context 'with earlier and later events' do
      it 'should render a link to the previous year' do
        allow(Event).to receive(:earliest_date).and_return(Date.parse('2000-01-01'))
        render
        expect(rendered).to match /<a [^>]*href="\/calendar\/2012"[^>]*>/
      end
      it 'should render a link to the next year' do
        allow(Event).to receive(:last_date).and_return(Date.parse('2100-01-01'))
        render
        expect(rendered).to match /<a [^>]*href="\/calendar\/2014"[^>]*>/
      end
    end
    context 'with no events' do
      before(:each) do
        allow(Event).to receive(:earliest_date).and_return(nil)
        allow(Event).to receive(:last_date).and_return(nil)
        allow(Event).to receive(:count).and_return(0)
      end
      it 'should not render a link to the previous year' do
        render
        expect(rendered).not_to match /<a [^>]*href="\/calendar\/2012"[^>]*>/
      end
      it 'should not render a link to the next year' do
        render
        expect(rendered).not_to match /<a [^>]*href="\/calendar\/2014"[^>]*>/
      end
    end
    it "should render the calendar heading" do
      render
      expect( rendered ).to match /<h1>.*2013.*<\/h1>/
    end
    it "should render the event total count for the year" do
      render
      expect( rendered ).to match /[^0-9]30 events/
    end
    it "should render the months" do
      render
      expect( rendered ).to match /<a href="\/calendar\/2013\/01"[^>]*>January<\/a>.* 1 event[^s]/
      expect( rendered ).to match /<a href="\/calendar\/2013\/12"[^>]*>December<\/a>.* 24 events/
    end
  end
  context 'with an admin user' do
    before(:each) do
      assign(:user, @admin)
    end
    it 'should add the new event link to the submenu' do
      expect(view).to receive(:add_submenu_item).with(
        title: 'New Event', path: '/events/new', attrs: { class: 'new' }
      )
      render
    end
  end
end
