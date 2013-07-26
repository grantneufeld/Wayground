# encoding: utf-8
require 'spec_helper'
require 'import/ical_importer'
require 'authority'
require 'event'
require 'user'

describe Wayground::Import::IcalImporter do

  before(:all) do
    Authority.delete_all
    User.destroy_all
    # first user is automatically an admin
    @user_admin = FactoryGirl.create(:user, name: 'Admin User')
    @user_normal = FactoryGirl.create(:user, name: 'Normal User')
    @source = FactoryGirl.create(:source, url: "#{Rails.root}/spec/fixtures/files/sample.ics")
  end

  def new_ievent(overrides = {})
    {
      'DESCRIPTION' => {value: 'Spec description.'},
      'DTSTART' => {value: 24.hours.from_now.to_datetime},
      'DTEND' => {value: 26.hours.from_now.to_datetime},
      'KLASS' => {value: 'PUBLIC'},
      'LOCATION' => {value: 'Spec Town, 123 Spec Street'},
      'ORGANIZER' => {value: 'Spec Organization'},
      'SUMMARY' => {value: 'Spec Event'},
      'UID' => {value: '123@spec'},
      'URL' => {value: 'http://spec.tld/spec/url'}
    }.merge(overrides)
  end

  let(:source) { $source = @source }
  let(:user) { $user = @user_normal }
  let(:proc) do
    iproc = Wayground::Import::IcalImporter.new
    iproc.source = @source
    iproc.editor = @user_normal
    $proc = iproc
  end

  describe ".process_source" do
    it "should generate events" do
      expect {
        processor = Wayground::Import::IcalImporter.process_source(source, user: user)
      }.to change(Event, :count).by(2)
    end
    it "should generate sourced items" do
      expect {
        processor = Wayground::Import::IcalImporter.process_source(source, user: user)
      }.to change(source.sourced_items, :count).by(2)
    end
  end

  describe "#process" do
    it "should generate events" do
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
      #ical = Icalendar::Calendar.new
      #ical.add_event(new_ievent(summary: 'First Event', uid: '1@process_calendar'))
      #ical.add_event(new_ievent(summary: 'Second Event', uid: '2@process_calendar'))
      ical = {'VEVENT' => [
        {
          'SUMMARY' => {value: 'First Event'},
          'DTSTART' => {value: 24.hours.from_now},
          'UID' => {value: '1@process_calendar'}
        },
        {
          'SUMMARY' => {value: 'Second Event'},
          'DTSTART' => {value: 48.hours.from_now},
          'UID' => {value: '2@process_calendar'}
        },
      ]}
      events = proc.process_icalendar(ical).new_events
      [events[0].title, events[1].title].should eq ['First Event', 'Second Event']
    end
    context "with an empty icalendar" do
      let(:ical) { $ical = {} }
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
      let(:event) do
        proc = Wayground::Import::IcalImporter.new
        proc.source = source
        $event = proc.process_event(ievent).new_events[0]
      end
      let(:modified_ievent) do
        $modified_ievent = new_ievent({
          'ATTACH' => {value: 'http://changed.tld/attach'},
          'DESCRIPTION' => {value: 'Changed description.'},
          'DTSTART' => {value: 12.hours.from_now},
          'DTEND' => {value: 13.hours.from_now},
          'LOCATION' => {value: 'Change Place'},
          'ORGANIZER' => {value: 'Change Org'},
          'SUMMARY' => {value: 'Changed Summary'},
          'URL' => {value: 'http://change.tld/url'},
          'UID' => {value: '123@spec'}
        })
      end
      it "should update the event" do
        sourced_item = source.sourced_items.build
        sourced_item.item = event
        sourced_item.source_identifier = '123@spec'
        sourced_item.save!
        proc.process_event(modified_ievent)
        event.reload
        event.title.should eq 'Changed Summary'
      end
      context "that is flagged as locally modified" do
        it "should add the ical event and sourced item to the skipped list" do
          # prepare mocks and stubs
          item = double('item')
          item.stub(:update_from_icalendar).and_return(false)
          sourced_item = double('sourced item')
          sourced_item.stub(has_local_modifications: true)
          sourced_item.stub(item: item)
          sourced_items_where = double('sourced items where')
          sourced_items_where.stub(:first).and_return(sourced_item)
          sourced_items = double('sourced items')
          sourced_items.stub(:where).with(source_identifier: ievent['UID'][:value]).
            and_return(sourced_items_where)
          source = double('source')
          source.stub(sourced_items: sourced_items)
          # prepare processor
          proc = Wayground::Import::IcalImporter.new
          proc.source = source
          # call the method being tested
          proc.process_event(modified_ievent)
          proc.skipped_ievents.should eq [{ievent: modified_ievent, sourced_item: sourced_item}]
        end
      end
      context "without a uid on the icalendar event" do
        it "should generate an event" do
          sourced_item = source.sourced_items.build
          sourced_item.item = event
          sourced_item.source_identifier = '123@spec'
          sourced_item.save!
          # a new event should be created when the icalendar event has no uid
          modified_ievent.delete('UID')
          expect {
            proc.process_event(modified_ievent)
          }.to change(Event, :count).by(1)
          # event should be unchanged
          event.reload
          event.title.should eq 'Spec Event'
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
        ].should eq [source, '123@spec', updated_at]
      end
    end

  end # #process_event

  describe "#create_event" do
    let(:ievent) { $ievent = new_ievent }

    it "should create a new event" do
      proc.create_event(ievent).class.should eq Event
    end
    context "with a given user" do
      it "should set the version editor to the user" do
        proc.create_event(ievent, editor: @user_normal).versions.first.user.should eq user
      end
    end
    context "with a user to use for approval" do
      it "should flag created events as approved if the user can approve" do
        proc.create_event(ievent, approve_by: @user_admin).is_approved?.should be_true
      end
      it "should not flag created events as approved if the user cannot approve" do
        proc.create_event(ievent, approve_by: @user_normal).is_approved?.should be_false
      end
    end
    context "with an URL in the ievent" do
      it "should include the url as an external link" do
        fields = double('field mapping')
        proc.stub(:icalendar_field_mapping).with(ievent).and_return(fields)
        fields.should_receive(:merge).with(
          {external_links_attributes: [{url: 'http://spec.tld/spec/url'}]}
        ).and_return({})
        event = FactoryGirl.build(:event)
        Event.stub(:new).and_return(event)
        proc.create_event(ievent)
      end
    end
  end

  describe "#icalendar_field_mapping" do
    it "should use SUMMARY as the title" do
      proc.icalendar_field_mapping(new_ievent)[:title].should eq 'Spec Event'
    end
    it "should use DESCRIPTION as the description" do
      proc.icalendar_field_mapping(new_ievent)[:description].should eq 'Spec description.'
    end
    it "should strip the URL from the end of the description" do
      url = 'http://test.tld/'
      proc.icalendar_field_mapping(
        new_ievent('DESCRIPTION' => {value: "with url\n\t#{url}\n"}, 'URL' => {value: url})
      )[:description].should eq 'with url'
    end
    it "should strip 'Details:' if it preceeds the URL at the end of the description" do
      url = 'http://test.tld/'
      proc.icalendar_field_mapping(
        new_ievent('DESCRIPTION' => {value: "description\nDetails: #{url}\n"}, 'URL' => {value: url})
      )[:description].should eq 'description'
    end
    it "should split the description after the first paragraph after 100 chars if too long" do
      event = proc.icalendar_field_mapping(
        new_ievent('DESCRIPTION' => {value: ('A' * 99) + "\n" + ('B' * 100) + "\nEtc." + ('C' * 350) })
      )
      [event[:description], event[:content]].should eq [
        ('A' * 99) + "\n" + ('B' * 100),
        'Etc.' + ('C' * 350)
      ]
    end
    it "should split the description on the last sentence break in a too long paragraph" do
      event = proc.icalendar_field_mapping(
        new_ievent('DESCRIPTION' => {value: ('A' * 200) + '. ' + ('B' * 200) + '! ' + ('C' * 200) + '?' })
      )
      [event[:description], event[:content]].should eq [
        ('A' * 200) + '. ' + ('B' * 200) + '!',
        ('C' * 200) + '?'
      ]
    end
    it "should split the description on the last space in a too long sentence" do
      event = proc.icalendar_field_mapping(
        new_ievent('DESCRIPTION' => {value: ('A' * 200) + ' ' + ('B' * 200) + ' ' + ('C' * 200) + ' ' })
      )
      [event[:description], event[:content]].should eq [
        ('A' * 200) + ' ' + ('B' * 200),
        ('C' * 200)
      ]
    end
    it "should split the description after the 100th char if an unbroken blob of characters" do
      event = proc.icalendar_field_mapping(
        new_ievent('DESCRIPTION' => {value: ('A' * 100) + 'B' + ('C' * 411)})
      )
      [event[:description], event[:content]].should eq ['A' * 100, 'B' + ('C' * 411)]
    end
    it "should use LOCATION as the location" do
      proc.icalendar_field_mapping(new_ievent)[:location].should eq 'Spec Town, 123 Spec Street'
    end
    it "should use ORGANIZER as the organizer" do
      proc.icalendar_field_mapping(new_ievent)[:organizer].should eq 'Spec Organization'
    end
    it "should use DTSTART as the start_at date & time" do
      date = '2001-02-03 04:05:06 MST'.to_datetime
      proc.icalendar_field_mapping(
        new_ievent('DTSTART' => {value: date})
      )[:start_at].should eq date
    end
    it "should use DTEND as the end_at date & time" do
      date = '2001-02-03 04:05:06 MST'.to_datetime
      proc.icalendar_field_mapping(
        new_ievent('DTEND' => {value: date})
      )[:end_at].should eq date
    end
  end

end
