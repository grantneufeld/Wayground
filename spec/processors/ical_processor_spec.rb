# encoding: utf-8
require 'spec_helper'

describe IcalProcessor do

  before do
    Authority.delete_all
    User.destroy_all
    # first user is automatically an admin
    @user_admin = FactoryGirl.create(:user, :name => 'Admin User')
    @user_normal = FactoryGirl.create(:user, :name => 'Normal User')
  end

  def new_ievent(overrides = {})
    e = Icalendar::Event.new
    e.description = overrides[:description] || 'Spec description.'
    e.dtstart = overrides[:dtstart] || 24.hours.from_now.to_datetime
    e.dtend = overrides[:dtend] || 26.hours.from_now.to_datetime
    e.klass = overrides[:klass] || 'PUBLIC'
    e.location = overrides[:location] || 'Spec Town, 123 Spec Street'
    e.organizer = overrides[:organizer] || 'Spec Organization'
    e.summary = overrides[:summary] || 'Spec Event'
    e.uid = overrides[:uid] || '123@spec'
    e.url = overrides[:url] || 'http://spec.tld/spec/url'
    e
  end

  let(:source) { $source = FactoryGirl.create(:source) }
  let(:user) { $user = @user_normal }
  let(:proc) do
    iproc = IcalProcessor.new
    iproc.source = source
    iproc.editor = user
    $proc = iproc
  end

  describe ".process_source" do
    it "should generate events" do
      source.url = "#{Rails.root}/spec/fixtures/files/sample.ics"
      expect {
        processor = IcalProcessor.process_source(source, user)
      }.to change(Event, :count).by(2)
    end
    it "should generate sourced items" do
      source.url = "#{Rails.root}/spec/fixtures/files/sample.ics"
      expect {
        processor = IcalProcessor.process_source(source, user)
      }.to change(source.sourced_items, :count).by(2)
    end
  end

  describe "#process" do
    it "should generate events" do
      source.url = "#{Rails.root}/spec/fixtures/files/sample.ics"
      events = proc.process.new_events
      [events[0].title, events[1].title].should eq ['First Sample', 'Second Sample']
    end
  end

  describe "#process_data" do
    it "should generate events" do
      proc.io = File.open("#{Rails.root}/spec/fixtures/files/sample.ics")
      events = proc.process_data.new_events
      [events[0].title, events[1].title].should eq ['First Sample', 'Second Sample']
    end
  end

  describe "#process_icalendar" do
    it "should generate events from the calendar" do
      ical = Icalendar::Calendar.new
      ical.add_event(new_ievent(summary: 'First Event', uid: '1@process_calendar'))
      ical.add_event(new_ievent(summary: 'Second Event', uid: '2@process_calendar'))
      events = proc.process_icalendar(ical).new_events
      [events[0].title, events[1].title].should eq ['First Event', 'Second Event']
    end
    context "with an empty icalendar" do
      let(:ical) { $ical = Icalendar::Calendar.new }
      it "should not generate any events" do
        proc.process_icalendar(ical).new_events.should eq []
      end
      it "should not update any events" do
        proc.process_icalendar(ical).updated_events.should eq []
      end
    end
  end

  describe "#process_event" do
    let(:ievent) { $ievent = new_ievent }

    context "with a pre-existing event" do
      let(:event) { $event = Event.create_from_icalendar(ievent) }
      let(:modified_ievent) do
        $modified_ievent = new_ievent({
          attach: 'http://changed.tld/attach', description: 'Changed description.',
          dtstart: 12.hours.from_now, dtend: 13.hours.from_now, location: 'Change Place',
          organizer: 'Change Org', summary: 'Changed Summary',
          url: 'http://change.tld/url', uid: ievent.uid
        })
      end
      it "should update the event" do
        sourced_item = source.sourced_items.new
        sourced_item.item = event
        sourced_item.source_identifier = ievent.uid
        sourced_item.save!
        proc.process_event(modified_ievent)
        event.reload
        event.title.should eq 'Changed Summary'
      end
      context "that is flagged as locally modified" do
        it "should add the ical event and sourced item to the skipped list" do
          sourced_item = source.sourced_items.new(has_local_modifications: true)
          sourced_item.item = event
          sourced_item.source_identifier = ievent.uid
          sourced_item.save!
          proc.process_event(modified_ievent)
          proc.skipped_ievents.should eq [{ievent: modified_ievent, sourced_item: sourced_item}]
        end
      end
    end

    context "with no pre-existing event" do
       it "should generate an event" do
         expect { proc.process_event(ievent) }.to change(Event, :count).by(1)
       end
       it "should generate a sourced item" do
         expect { proc.process_event(ievent) }.to change(SourcedItem, :count).by(1)
       end
       it "should set the expected values for a sourced item" do
         updated_at = 72.minutes.ago
         source.sourced_items.delete_all
         source.last_updated_at = updated_at
         proc.process_event(ievent)
         sourced_item = proc.new_events[0].sourced_items.first
         [
           sourced_item.source, sourced_item.source_identifier, sourced_item.last_sourced_at
         ].should eq [source, ievent.uid, updated_at]
       end
     end

  end # #process_event

end
