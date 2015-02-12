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
      expect([events[0].title, events[1].title]).to eq ['First Sample', 'Second Sample']
    end
  end

  describe "#process_data" do
    it "should generate events" do
      proc.io = File.open("#{Rails.root}/spec/fixtures/files/sample.ics")
      events = proc.process_data.new_events
      expect([events[0].title, events[1].title]).to eq ['First Sample', 'Second Sample']
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
      expect([events[0].title, events[1].title]).to eq ['First Event', 'Second Event']
    end
    context "with an empty icalendar" do
      let(:ical) { $ical = {} }
      it "should not generate any events" do
        expect(proc.process_icalendar(ical).new_events).to eq []
      end
      it "should not update any events" do
        expect(proc.process_icalendar(ical).updated_events).to eq []
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
        sourced_item = source.sourced_items.new
        sourced_item.item = event
        sourced_item.source_identifier = '123@spec'
        sourced_item.save!
        proc.process_event(modified_ievent)
        event.reload
        expect(event.title).to eq 'Changed Summary'
      end
      context "that is flagged as locally modified" do
        it "should add the ical event and sourced item to the skipped list" do
          # prepare mocks and stubs
          item = double('item')
          allow(item).to receive(:update_from_icalendar).and_return(false)
          sourced_item = double('sourced item')
          allow(sourced_item).to receive(:has_local_modifications).and_return(true)
          allow(sourced_item).to receive(:item).and_return(item)
          sourced_items_where = double('sourced items where')
          allow(sourced_items_where).to receive(:first).and_return(sourced_item)
          sourced_items = double('sourced items')
          allow(sourced_items).to receive(:where).with(source_identifier: ievent['UID'][:value]).
            and_return(sourced_items_where)
          source = double('source')
          allow(source).to receive(:sourced_items).and_return(sourced_items)
          # prepare processor
          proc = Wayground::Import::IcalImporter.new
          proc.source = source
          # call the method being tested
          proc.process_event(modified_ievent)
          expect(proc.skipped_ievents).to eq [{ievent: modified_ievent, sourced_item: sourced_item}]
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
          expect(event.title).to eq 'Spec Event'
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
        item_attributes = [
          sourced_item.source, sourced_item.source_identifier, sourced_item.last_sourced_at
        ]
        expect(item_attributes).to eq [source, '123@spec', updated_at]
      end
    end

  end # #process_event

  describe "#create_event" do
    let(:ievent) { $ievent = new_ievent }

    it "should create a new event" do
      expect(proc.create_event(ievent).class).to eq Event
    end
    context "with a given user" do
      it "should set the version editor to the user" do
        expect(proc.create_event(ievent, editor: @user_normal).versions.first.user).to eq user
      end
    end
    context "with a user to use for approval" do
      it "should flag created events as approved if the user can approve" do
        expect(proc.create_event(ievent, approve_by: @user_admin).is_approved?).to be_truthy
      end
      it "should not flag created events as approved if the user cannot approve" do
        expect(proc.create_event(ievent, approve_by: @user_normal).is_approved?).to be_falsey
      end
    end
    context "with an URL in the ievent" do
      it "should include the url as an external link" do
        fields = double('field mapping')
        allow(proc).to receive(:icalendar_field_mapping).with(ievent).and_return(fields)
        expect(fields).to receive(:merge).with(
          {external_links_attributes: [{url: 'http://spec.tld/spec/url'}]}
        ).and_return({})
        event = FactoryGirl.build(:event)
        allow(Event).to receive(:new).and_return(event)
        proc.create_event(ievent)
      end
    end
  end

  describe "#icalendar_field_mapping" do
    it "should use SUMMARY as the title" do
      expect(proc.icalendar_field_mapping(new_ievent)[:title]).to eq 'Spec Event'
    end
    it "should use DESCRIPTION as the description" do
      expect(proc.icalendar_field_mapping(new_ievent)[:description]).to eq 'Spec description.'
    end
    it "should strip the URL from the end of the description" do
      url = 'http://test.tld/'
      ievent = new_ievent('DESCRIPTION' => { value: "with url\n\t#{url}\n" }, 'URL' => { value: url })
      mapped_description = proc.icalendar_field_mapping(ievent)[:description]
      expect(mapped_description).to eq 'with url'
    end
    it "should strip 'Details:' if it preceeds the URL at the end of the description" do
      url = 'http://test.tld/'
      ievent = new_ievent(
        'DESCRIPTION' => { value: "description\nDetails: #{url}\n" }, 'URL' => { value: url }
      )
      mapped_description = proc.icalendar_field_mapping(ievent)[:description]
      expect(mapped_description).to eq 'description'
    end
    it "should split the description after the first paragraph after 100 chars if too long" do
      ievent = new_ievent(
        'DESCRIPTION' => { value: ('A' * 99) + "\n" + ('B' * 100) + "\nEtc." + ('C' * 350) }
      )
      event = proc.icalendar_field_mapping(ievent)
      expect([event[:description], event[:content]]).to eq [
        ('A' * 99) + "\n" + ('B' * 100),
        'Etc.' + ('C' * 350)
      ]
    end
    it "should split the description on the last sentence break in a too long paragraph" do
      ievent = new_ievent(
        'DESCRIPTION' => { value: ('A' * 200) + '. ' + ('B' * 200) + '! ' + ('C' * 200) + '?' }
      )
      event = proc.icalendar_field_mapping(ievent)
      expect([event[:description], event[:content]]).to eq [
        ('A' * 200) + '. ' + ('B' * 200) + '!',
        ('C' * 200) + '?'
      ]
    end
    it "should split the description on the last space in a too long sentence" do
      event = proc.icalendar_field_mapping(
        new_ievent('DESCRIPTION' => {value: ('A' * 200) + ' ' + ('B' * 200) + ' ' + ('C' * 200) + ' ' })
      )
      expect([event[:description], event[:content]]).to eq [
        ('A' * 200) + ' ' + ('B' * 200),
        ('C' * 200)
      ]
    end
    it "should split the description after the 100th char if an unbroken blob of characters" do
      event = proc.icalendar_field_mapping(
        new_ievent('DESCRIPTION' => {value: ('A' * 100) + 'B' + ('C' * 411)})
      )
      expect([event[:description], event[:content]]).to eq ['A' * 100, 'B' + ('C' * 411)]
    end
    it "should use LOCATION as the location" do
      expect(proc.icalendar_field_mapping(new_ievent)[:location]).to eq 'Spec Town, 123 Spec Street'
    end
    it "should use ORGANIZER as the organizer" do
      expect(proc.icalendar_field_mapping(new_ievent)[:organizer]).to eq 'Spec Organization'
    end
    it "should use DTSTART as the start_at date & time" do
      date = '2001-02-03 04:05:06 MST'.to_datetime
      mapped_date = proc.icalendar_field_mapping(new_ievent('DTSTART' => { value: date }))[:start_at]
      expect(mapped_date).to eq date
    end
    it "should use DTEND as the end_at date & time" do
      date = '2001-02-03 04:05:06 MST'.to_datetime
      mapped_date = proc.icalendar_field_mapping(new_ievent('DTEND' => { value: date }))[:end_at]
      expect(mapped_date).to eq date
    end
  end

end
