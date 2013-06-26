# encoding: utf-8
require 'spec_helper'

describe Event do

  before(:all) do
    Authority.delete_all
    User.destroy_all
    # first user is automatically an admin
    @user_admin = FactoryGirl.create(:user, name: 'Admin User')
    @user_normal = FactoryGirl.create(:user, name: 'Normal User')
  end

  let(:source) { $source = FactoryGirl.create(:source) }

  describe "acts_as_authority_controlled" do
    it "should be in the “Calendar” area" do
      expect( Event.authority_area ).to eq 'Calendar'
    end
  end

  describe "attr_accessor" do
    it "should provide an editor accessor" do
      event = Event.new
      event.editor = 'test'
      expect( event.editor ).to eq 'test'
    end
    it "should provide an edit_comment accessor" do
      event = Event.new
      event.edit_comment = 'test'
      expect( event.edit_comment ).to eq 'test'
    end
  end

  describe "attr_accessible" do
    it "should not allow user to be set" do
      expect {
        event = Event.new(user: @user_normal)
      }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should not allow user_id to be set" do
      expect {
        event = Event.new(user_id: @user_normal.id)
      }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should allow start_at to be set" do
      event = Event.new(start_at: '2012-01-02 03:04:05')
      expect( event.start_at.getlocal.to_s(:db) ).to eq '2012-01-02 03:04:05'
    end
    it "should allow end_at to be set" do
      event = Event.new(end_at: '2012-06-07 08:09:10')
      expect( event.end_at.getlocal.to_s(:db) ).to eq '2012-06-07 08:09:10'
    end
    it "should allow timezone to be set" do
      event = Event.new(timezone: 'UTC')
      expect( event.timezone ).to eq 'UTC'
    end
    it "should allow is_allday to be set" do
      event = Event.new(is_allday: true)
      expect( event.is_allday ).to be_true
    end
    it "should allow is_draft to be set" do
      event = Event.new(is_draft: true)
      expect( event.is_draft ).to be_true
    end
    it "should not allow is_approved to be set" do
      expect {
        event = Event.new(is_approved: true)
      }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should allow is_wheelchair_accessible to be set" do
      event = Event.new(is_wheelchair_accessible: true)
      expect( event.is_wheelchair_accessible ).to be_true
    end
    it "should allow is_adults_only to be set" do
      event = Event.new(is_adults_only: true)
      expect( event.is_adults_only ).to be_true
    end
    it "should allow is_tentative to be set" do
      event = Event.new(is_tentative: true)
      expect( event.is_tentative ).to be_true
    end
    it "should allow is_cancelled to be set" do
      event = Event.new(is_cancelled: true)
      expect( event.is_cancelled ).to be_true
    end
    it "should allow is_featured to be set" do
      event = Event.new(is_featured: true)
      expect( event.is_featured ).to be_true
    end
    it "should allow title to be set" do
      event = Event.new(title: 'set title')
      expect( event.title ).to eq 'set title'
    end
    it "should allow description to be set" do
      event = Event.new(description: 'set description')
      expect( event.description ).to eq 'set description'
    end
    it "should allow content to be set" do
      event = Event.new(content: 'set content')
      expect( event.content ).to eq 'set content'
    end
    it "should allow organizer to be set" do
      event = Event.new(organizer: 'set organizer')
      expect( event.organizer ).to eq 'set organizer'
    end
    it "should allow organizer_url to be set" do
      event = Event.new(organizer_url: 'set organizer_url')
      expect( event.organizer_url ).to eq 'set organizer_url'
    end
    it "should allow location to be set" do
      event = Event.new(location: 'set location')
      expect( event.location ).to eq 'set location'
    end
    it "should allow address to be set" do
      event = Event.new(address: 'set address')
      expect( event.address ).to eq 'set address'
    end
    it "should allow city to be set" do
      event = Event.new(city: 'set city')
      expect( event.city ).to eq 'set city'
    end
    it "should allow province to be set" do
      event = Event.new(province: 'set province')
      expect( event.province ).to eq 'set province'
    end
    it "should allow country to be set" do
      event = Event.new(country: 'set country')
      expect( event.country ).to eq 'set country'
    end
    it "should allow location_url to be set" do
      event = Event.new(location_url: 'set location_url')
      expect( event.location_url ).to eq 'set location_url'
    end
    it "should allow external_links_attributes to be set" do
      url = 'http://set.external_links_attributes.tld/'
      event = Event.new(external_links_attributes: { '0' => { url: url } })
      expect( event.external_links[0].url ).to eq url
    end
    it "should not allow editor to be set" do
      expect {
        event = Event.new(editor: @user_normal)
      }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should allow edit_comment to be set" do
      event = Event.new(edit_comment: 'set edit_comment')
      expect( event.edit_comment ).to eq 'set edit_comment'
    end
  end

  describe "validation" do
    describe "of start_at" do
      it "should fail if start_at is not set" do
        event = Event.new(title: 'missing start_at')
        expect( event.valid? ).to be_false
      end
    end
    describe "of end_at" do
      it "should pass if end_at is equal to start_at" do
        event = Event.new(start_at: '2012-01-01 01:01:01', title: 'end_at = start_at',
          end_at: '2012-01-01 01:01:01'
        )
        expect( event.valid? ).to be_true
      end
      it "should fail if end_at is less than start_at" do
        event = Event.new(start_at: '2012-01-01 01:01:01', title: 'end_at < start_at',
          end_at: '2012-01-01 01:01:00'
        )
        expect( event.valid? ).to be_false
      end
    end
    describe "of timezone" do
      it "should pass if timezone is nil" do
        event = Event.new(start_at: '2012-01-01 01:01:01', title: 'not a timezone', timezone: nil)
        expect( event.valid? ).to be_true
      end
      it "should pass if timezone is blank" do
        event = Event.new(start_at: '2012-01-01 01:01:01', title: 'not a timezone', timezone: '')
        expect( event.valid? ).to be_true
      end
      it "should pass if timezone is one of the recognized timezones" do
        event = Event.new(start_at: '2012-01-01 01:01:01', title: 'UTC timezone', timezone: 'UTC')
        expect( event.valid? ).to be_true
      end
      it "should fail if the string is present but not a timezone" do
        event = Event.new(
          start_at: '2012-01-01 01:01:01', title: 'not a timezone', timezone: 'invalid timezone'
        )
        expect( event.valid? ).to be_false
      end
    end
    describe "of is_approved" do
      it "should fail if both is_approved and is_draft are true" do
        event = Event.new(start_at: '2012-01-01 01:01:01', title: 'is_approved and is_draft',
          is_draft: true
        )
        event.is_approved = true
        expect( event.valid? ).to be_false
      end
    end
    describe "of title" do
      it "should fail if title is not set" do
        event = Event.new(start_at: '2012-01-01 01:01:01')
        expect( event.valid? ).to be_false
      end
      it "should fail if title is blank" do
        event = Event.new(title: '', start_at: '2012-01-01 01:01:01')
        expect( event.valid? ).to be_false
      end
      it "should fail if title is too long" do
        event = Event.new(title: ('A' * 256), start_at: '2012-01-01 01:01:01')
        expect( event.valid? ).to be_false
      end
    end
    describe "of description" do
      it "should pass if description is the maximum length" do
        event = Event.new(start_at: '2012-01-01 01:01:01', title: 'max length description',
          description: ('A' * 511)
        )
        expect( event.valid? ).to be_true
      end
      it "should fail if description is too long" do
        event = Event.new(start_at: '2012-01-01 01:01:01', title: 'too long description',
          description: ('A' * 512)
        )
        expect( event.valid? ).to be_false
      end
    end
    describe "of content" do
      it "should fail if content is too long" do
        event = Event.new(start_at: '2012-01-01 01:01:01', title: 'too long content',
          content: ('A' * 8192)
        )
        expect( event.valid? ).to be_false
      end
    end
    describe "of organizer" do
      it "should fail if organizer is too long" do
        event = Event.new(start_at: '2012-01-01 01:01:01', title: 'too long organizer',
          organizer: ('A' * 256)
        )
        expect( event.valid? ).to be_false
      end
    end
    describe "of organizer_url" do
      it "should fail if organizer_url is too long" do
        event = Event.new(start_at: '2012-01-01 01:01:01', title: 'too long organizer_url',
          organizer_url: ('A' * 256)
        )
        expect( event.valid? ).to be_false
      end
    end
    describe "of location" do
      it "should fail if location is too long" do
        event = Event.new(start_at: '2012-01-01 01:01:01', title: 'too long location',
          location: ('A' * 256)
        )
        expect( event.valid? ).to be_false
      end
    end
    describe "of address" do
      it "should fail if address is too long" do
        event = Event.new(start_at: '2012-01-01 01:01:01', title: 'too long address',
          address: ('A' * 256)
        )
        expect( event.valid? ).to be_false
      end
    end
    describe "of city" do
      it "should fail if city is too long" do
        event = Event.new(start_at: '2012-01-01 01:01:01', title: 'too long city',
          city: ('A' * 256)
        )
        expect( event.valid? ).to be_false
      end
    end
    describe "of province" do
      it "should fail if province is too long" do
        event = Event.new(start_at: '2012-01-01 01:01:01', title: 'too long province',
          province: ('A' * 32)
        )
        expect( event.valid? ).to be_false
      end
    end
    describe "of country" do
      it "should fail if country is too long" do
        event = Event.new(start_at: '2012-01-01 01:01:01', title: 'too long country',
          country: ('A' * 3)
        )
        expect( event.valid? ).to be_false
      end
    end
    describe "of location_url" do
      it "should fail if location_url is too long" do
        event = Event.new(start_at: '2012-01-01 01:01:01', title: 'too long location_url',
          location_url: ('A' * 256)
        )
        expect( event.valid? ).to be_false
      end
    end
  end

  #describe "updating as a sourced item" do
  #  it "should set the has_local_modifications flag on any SourcedItems" do
  #    # TODO: test for setting has_local_modifications on sourced items when updating an Event
  #  end
  #end

  describe "scopes" do
    describe "default_scope" do
      it "should order by start date & time by default" do
        Event.delete_all
        event2 = FactoryGirl.create(:event, start_at: '2002-02-02 02:02:02')
        event4 = FactoryGirl.create(:event, start_at: '2004-04-04 04:04:04')
        event3 = FactoryGirl.create(:event, start_at: '2003-03-03 03:03:03')
        event1 = FactoryGirl.create(:event, start_at: '2001-01-01 01:01:01')
        expect( Event.all ).to eq [event1, event2, event3, event4]
      end
    end
    describe ".approved" do
      it "should return only events where is_approved" do
        Event.delete_all
        event1 = FactoryGirl.build(:event)
        event1.is_approved = true
        event1.save!
        event2 = FactoryGirl.build(:event)
        event2.is_approved = false
        event2.save!
        event3 = FactoryGirl.build(:event)
        event3.is_approved = true
        event3.save!
        expect( Event.approved ).to eq [event1, event3]
      end
    end
    describe ".upcoming" do
      it "should return only events that are active on, or after, the current current date & time" do
        Event.delete_all
        # create some past events
        FactoryGirl.create(:event, start_at: 1.day.ago)
        FactoryGirl.create(:event, start_at: 2.weeks.ago)
        FactoryGirl.create(:event, start_at: 3.months.ago)
        # create an event that occurred earlier today
        event1 = FactoryGirl.create(:event, start_at: Time.current.beginning_of_day)
        # create an event happening in just a minute
        event2 = FactoryGirl.create(:event, start_at: Time.current.advance(minutes: 1))
        # create some future events
        event3 = FactoryGirl.create(:event, start_at: 1.hour.from_now)
        event4 = FactoryGirl.create(:event, start_at: 2.days.from_now)
        event5 = FactoryGirl.create(:event, start_at: 3.months.from_now)
        expect( Event.upcoming ).to eq [event1, event2, event3, event4, event5]
      end
    end
    describe ".past" do
      it "should return only events that ended before the current date & time" do
        Event.delete_all
        # past events
        event1 = FactoryGirl.create(:event, start_at: 2.weeks.ago)
        event2 = FactoryGirl.create(:event, start_at: 1.day.ago)
        # create an event that occurred earlier today
        FactoryGirl.create(:event, start_at: Time.current.beginning_of_day)
        # create an event happening in just a minute
        FactoryGirl.create(:event, start_at: Time.current.advance(minutes: 1))
        # create a future event
        FactoryGirl.create(:event, start_at: 1.day.from_now)
        expect( Event.past ).to eq [event1, event2]
      end
    end
    context "with dates in the year 2000" do
      before(:all) do
        Event.delete_all
        @event1 = FactoryGirl.create(:event, start_at: '2000-01-01 23:59:59', title: '2000 day 1')
        @event2 = FactoryGirl.create(:event, start_at: '2000-01-02 00:00:00', title: '2000 day 2')
        @event3 = FactoryGirl.create(:event, start_at: '2000-01-03 23:59:59', title: '2000 day 3')
        @event4 = FactoryGirl.create(:event, start_at: '2000-01-04 00:00:00', title: '2000 day 4')
        @event4_2 = FactoryGirl.create(:event, start_at: '2000-01-04 23:59:59', title: '2000 day 4, #2')
        @event5 = FactoryGirl.create(:event, start_at: '2000-01-05 00:00:00', title: '2000 day 5')
      end
      describe ".falls_between_dates" do
        it "should return the events that occur within the specified period" do
          result = Event.falls_between_dates('2000-01-02'.to_date, '2000-01-03'.to_date)
          expect( result.sort ).to eq( [@event2, @event3].sort )
        end
      end
      describe ".falls_on_date" do
        it "should return the events that occur on the specified date" do
          result = Event.falls_on_date('2000-01-04'.to_date)
          expect( result.sort ).to eq( [@event4, @event4_2].sort )
        end
      end
    end
    describe '.tagged' do
      it 'should return events that are tagged with the given tag' do
        Tag.delete_all
        event1 = Event.order(:id).first || FactoryGirl.create(:event)
        event2 = Event.order(:id).offset(1).first || FactoryGirl.create(:event)
        event3 = Event.order(:id).offset(2).first || FactoryGirl.create(:event)
        event1.tag_list = 'Given, Tag'
        event1.editor = @user_admin
        event1.save!
        event3.tag_list = 'Tag, Given'
        event3.editor = @user_admin
        event3.save!
        expect( Event.tagged('given') ).to eq [event1, event3]
      end
    end
  end

  describe "initialize" do
    it "should set the city, province and country" do
      event = Event.new
      expect( [event.city, event.province, event.country] ).to eq ['Calgary', 'Alberta', 'CA']
    end
    it "should not set any location defaults if city is set" do
      event = Event.new(city: 'Test')
      expect( [event.city, event.province, event.country] ).to eq ['Test', nil, nil]
    end
    it "should not set any location defaults if city is set" do
      event = Event.new(province: 'Test')
      expect( [event.city, event.province, event.country] ).to eq [nil, 'Test', nil]
    end
    it "should not set any location defaults if country is set" do
      event = Event.new(country: 'Test')
      expect( [event.city, event.province, event.country] ).to eq [nil, nil, 'Test']
    end
  end

  describe "approve_if_authority" do
    it "should not set is_approved if regular user" do
      event = Event.new(start_at: '2012-01-01 01:01:01', title: 'already approved')
      event.user = @user_normal
      # TESTING:
      expect( event.user.has_authority_for_area('Calendar', :is_owner) ).to be_false
      # actual tests:
      event.approve_if_authority
      expect( event.is_approved ).to be_false
    end
    it "should set is_approved to true when user has authority" do
      event = Event.new(start_at: '2012-01-01 01:01:01', title: 'admin created event')
      event.user = FactoryGirl.create(:user)
      authority = FactoryGirl.create(:owner_authority, area: 'Calendar', user: event.user)
      # TESTING:
      expect( event.user.has_authority_for_area('Calendar', :is_owner) ).to be_true
      # actual tests:
      event.approve_if_authority
      expect( event.is_approved ).to be_true
    end
    it "should not change is_approved if already true" do
      event = Event.new(start_at: '2012-01-01 01:01:01', title: 'already approved')
      event.is_approved = true
      event.user = @user_normal
      # TESTING:
      expect( event.user.has_authority_for_area('Calendar', :is_owner) ).to be_false
      # actual tests:
      event.approve_if_authority
      expect( event.is_approved ).to be_true
    end
  end

  describe "#set_timezone" do
    it "should set the timezone based on the user" do
      tz_str = 'Central Time (US & Canada)'
      event = Event.new(start_at: '2012-01-01 01:01:01', title: 'user’s timezone')
      event.user = FactoryGirl.build(:user, timezone: tz_str)
      event.set_timezone
      expect( event.timezone ).to eq tz_str
    end
    it "should set the timezone to the system default if no user" do
      default_tz = Time.zone_default
      tz_str = 'Pacific Time (US & Canada)'
      Time.zone_default = ActiveSupport::TimeZone[tz_str]
      event = Event.new(start_at: '2012-01-01 01:01:01', title: 'system default timezone')
      event.set_timezone
      expect( event.timezone ).to eq tz_str
      Time.zone_default = default_tz
    end
    it "should not override an existing timezone" do
      event = Event.new(start_at: '2012-01-01 01:01:01', title: 'preset timezone',
        timezone: 'Saskatchewan'
      )
      event.user = FactoryGirl.build(:user, timezone: 'UTC')
      event.set_timezone
      expect( event.timezone ).to eq 'Saskatchewan'
    end
    it "should be automatically called on create" do
      event = Event.new(start_at: '2012-01-01 01:01:01', title: 'auto-set timezone on create')
      event.editor = @user_admin
      event.save!
      expect( event.timezone.present? ).to be_true
    end
    it "should not be called on update" do
      event = Event.new(start_at: '2012-01-01 01:01:01', title: 'no timezone on update')
      event.editor = @user_admin
      event.save!
      event.timezone = nil
      event.save!
      expect( event.timezone.present? ).to be_false
    end
  end

  describe "#flag_as_modified_for_sourcing" do
    let(:event) { $event = FactoryGirl.create(:event) }
    let(:sourced_item) {
      $sourced_item = FactoryGirl.create(:sourced_item, item: event, source: source)
    }

    it "should be called when updating an Event" do
      sourced_item.has_local_modifications = false
      sourced_item.save!
      event.update(title: 'Updated')
      sourced_item.reload
      expect( sourced_item.has_local_modifications? ).to be_true
    end
    it "should set the has_local_modifications for all sourced_items" do
      sourced_item.has_local_modifications = false
      sourced_item.save!
      source2 = FactoryGirl.create(:source)
      sourced_item2 = event.sourced_items.new(last_sourced_at: source2.last_updated_at)
      sourced_item2.source = source2
      sourced_item2.save!
      # should not have updated event yet
      expect( sourced_item.has_local_modifications? ).to be_false
      expect( sourced_item2.has_local_modifications? ).to be_false
      # “update” the event
      event.flag_as_modified_for_sourcing
      expect( event.sourced_items[0].has_local_modifications? ).to be_true
      expect( event.sourced_items[1].has_local_modifications? ).to be_true
    end
    it "should not touch the sourced_items when is_sourcing is set true" do
      sourced_item.has_local_modifications = false
      sourced_item.save!
      event.is_sourcing = true
      event.flag_as_modified_for_sourcing
      expect( event.sourced_items[0].has_local_modifications? ).to be_false
    end
  end

  describe "#add_version" do
    before(:all) do
      @versioned_event = FactoryGirl.create(:event, editor: @user_admin, edit_comment: 'add version specs')
    end
    it "should add a Version" do
      @versioned_event.editor = @user_admin
      Version.any_instance.stub(:diff_with).and_return(title: 'Different')
      expect { @versioned_event.add_version }.to change{ @versioned_event.versions.count }.by(1)
    end
    it "should not add a Version when there have been no changes" do
      @versioned_event.editor = @user_admin
      @versioned_event.edit_comment = 'saving without changes'
      Version.any_instance.stub(:diff_with).and_return({})
      expect { @versioned_event.add_version }.to change{ @versioned_event.versions.count }.by(0)
    end
    it "should fail if editor has not been set" do
      @versioned_event.editor = nil
      Version.any_instance.stub(:diff_with).and_return(title: 'Different')
      expect { @versioned_event.add_version }.to raise_error(ActiveRecord::RecordInvalid)
    end
    it "should be called after an event is created" do
      event = FactoryGirl.build(:event, editor: @user_admin, edit_comment: 'add_version after save')
      expect { event.save! }.to change{ event.versions.count }.by(1)
    end
    it "should be called after an event is updated" do
      event = FactoryGirl.create(:event, editor: @user_admin, edit_comment: 'add_version after update')
      Version.any_instance.stub(:diff_with).and_return(title: 'Different')
      expect {
        event.update(title: 'updated version')
      }.to change{ event.versions.count }.by(1)
    end
  end

  describe '#new_version' do
    it "should build a new Version for the event" do
      values1 = {timezone: 'CDT', is_allday: true, is_draft: true}
      values2 = {
        is_wheelchair_accessible: true, is_adults_only: true, is_tentative: true,
        is_cancelled: true, is_featured: true,
        organizer: 'Organizer', organizer_url: 'http://organizer.url/',
        location: 'Location', address: 'Address', city: 'City', province: 'Province', country: 'Country',
        location_url: 'http://location.url/',
        content: 'Content', description: 'Description',
        start_at: Time.zone.parse('2000-01-01 02:03pm'), end_at: Time.zone.parse('2000-01-01 04:05pm')
      }
      event = Event.new(
        { edit_comment: 'Edit Comment', title: 'Title' }.merge(values1).merge(values2)
      )
      event.editor = @user_admin
      event.is_approved = true
      updated_at = Time.zone.parse('2000-01-01 06:07pm')
      event.updated_at = updated_at
      version = event.new_version
      expect( version.user ).to eq @user_admin
      expect( version.edited_at ).to eq updated_at
      expect( version.edit_comment ).to eq 'Edit Comment'
      expect( version.title ).to eq 'Title'
      expect( version.values ).to eq values1.merge(is_approved: true).merge(values2)
    end
  end

  describe "#title=" do
    it "should set the title attribute" do
      event = Event.new
      event.title = 'test'
      expect( event.title ).to eq 'test'
    end
    it "should clear the title attribute when nil is given" do
      event = Event.new(title: 'Test')
      event.title = nil
      expect( event.title ).to be_nil
    end
    it "should try to clean up the string passed in" do
      event = Event.new
      event.title = " A  Messy \t String\t"
      expect( event.title ).to eq 'A Messy String'
    end
  end
  describe "#description=" do
    it "should set the description attribute" do
      event = Event.new
      event.description = 'test'
      expect( event.description ).to eq 'test'
    end
    it "should clear the description attribute when nil is given" do
      event = Event.new(description: 'Test')
      event.description = nil
      expect( event.description ).to be_nil
    end
    it "should try to clean up the string passed in" do
      event = Event.new
      event.description = " A  Messy \t String\t"
      expect( event.description ).to eq 'A Messy String'
    end
  end
  describe "#content=" do
    it "should set the content attribute" do
      event = Event.new
      event.content = 'test'
      expect( event.content ).to eq 'test'
    end
    it "should clear the content attribute when nil is given" do
      event = Event.new(content: 'Test')
      event.content = nil
      expect( event.content ).to be_nil
    end
    it "should try to clean up the string passed in" do
      event = Event.new
      event.content = " A  Messy \t String\t"
      expect( event.content ).to eq 'A Messy String'
    end
  end
  describe "#organizer=" do
    it "should set the organizer attribute" do
      event = Event.new
      event.organizer = 'test'
      expect( event.organizer ).to eq 'test'
    end
    it "should clear the organizer attribute when nil is given" do
      event = Event.new(organizer: 'Test')
      event.organizer = nil
      expect( event.organizer ).to be_nil
    end
    it "should try to clean up the string passed in" do
      event = Event.new
      event.organizer = " A  Messy \t String\t"
      expect( event.organizer ).to eq 'A Messy String'
    end
  end
  describe "#organizer_url=" do
    it "should set the organizer_url attribute" do
      event = Event.new
      event.organizer_url = 'test'
      expect( event.organizer_url ).to eq 'test'
    end
    it "should clear the organizer_url attribute when nil is given" do
      event = Event.new(organizer_url: 'Test')
      event.organizer_url = nil
      expect( event.organizer_url ).to be_nil
    end
    it "should try to clean up the url passed in" do
      event = Event.new
      event.organizer_url = 'http://twitter.com/#!/wayground'
      expect( event.organizer_url ).to eq 'https://twitter.com/wayground'
    end
  end
  describe "#location=" do
    it "should set the location attribute" do
      event = Event.new
      event.location = 'test'
      expect( event.location ).to eq 'test'
    end
    it "should clear the location attribute when nil is given" do
      event = Event.new(location: 'Test')
      event.location = nil
      expect( event.location ).to be_nil
    end
    it "should try to clean up the string passed in" do
      event = Event.new
      event.location = " A  Messy \t String\t"
      expect( event.location ).to eq 'A Messy String'
    end
  end
  describe "#address=" do
    it "should set the address attribute" do
      event = Event.new
      event.address = 'test'
      expect( event.address ).to eq 'test'
    end
    it "should clear the address attribute when nil is given" do
      event = Event.new(address: 'Test')
      event.address = nil
      expect( event.address ).to be_nil
    end
    it "should try to clean up the string passed in" do
      event = Event.new
      event.address = " A  Messy \t String\t"
      expect( event.address ).to eq 'A Messy String'
    end
  end
  describe "#city=" do
    it "should set the city attribute" do
      event = Event.new
      event.city = 'test'
      expect( event.city ).to eq 'test'
    end
    it "should clear the city attribute when nil is given" do
      event = Event.new(city: 'Test')
      event.city = nil
      expect( event.city ).to be_nil
    end
    it "should try to clean up the string passed in" do
      event = Event.new
      event.city = " A  Messy \t String\t"
      expect( event.city ).to eq 'A Messy String'
    end
  end
  describe "#province=" do
    it "should set the province attribute" do
      event = Event.new
      event.province = 'test'
      expect( event.province ).to eq 'test'
    end
    it "should clear the province attribute when nil is given" do
      event = Event.new(province: 'Test')
      event.province = nil
      expect( event.province ).to be_nil
    end
    it "should try to clean up the string passed in" do
      event = Event.new
      event.province = " A  Messy \t String\t"
      expect( event.province ).to eq 'A Messy String'
    end
  end
  describe "#location_url=" do
    it "should set the location_url attribute" do
      event = Event.new
      event.location_url = 'test'
      expect( event.location_url ).to eq 'test'
    end
    it "should clear the location_url attribute when nil is given" do
      event = Event.new(location_url: 'Test')
      event.location_url = nil
      expect( event.location_url ).to be_nil
    end
    it "should try to clean up the url passed in" do
      event = Event.new
      event.location_url = 'http://twitter.com/#!/wayground'
      expect( event.location_url ).to eq 'https://twitter.com/wayground'
    end
  end

  describe '#tag_list' do
    context 'with no tags' do
      it 'should return an empty string' do
        event = Event.new
        expect( event.tag_list.to_s ).to eq ''
      end
    end
    context 'with a single tag' do
      it 'should return the tag title' do
        event = Event.new
        event.tags.new(title: 'Test Tag')
        expect( event.tag_list.to_s ).to eq 'Test Tag'
      end
    end
    context 'with multiple tags' do
      it 'should return a comma and space separated string of the tag titles' do
        event = Event.new
        event.tags.new(title: 'Tag A')
        event.tags.new(title: 'Tag B')
        event.tags.new(title: 'Tag C')
        expect( event.tag_list.to_s ).to eq 'Tag A, Tag B, Tag C'
      end
    end
  end

  describe '#tag_list=' do
    context 'with no tags' do
      it 'should add a single-tag when given a string with no commas' do
        event = Event.new
        event.tag_list = 'Single Tag'
        expect( event.tag_list.to_s ).to eq 'Single Tag'
      end
      it 'should add multiple tags when give a string with multiple commas' do
        event = Event.new
        event.tag_list = 'Tag 1, Tag 2, Tag 3'
        expect( event.tag_list.to_s ).to eq 'Tag 1, Tag 2, Tag 3'
      end
      it 'should strip surrounding quotes and white-space' do
        event = Event.new
        event.tag_list = " 'Tag 1 ' ,  \" Tag 2\",' Tag 3'"
        expect( event.tag_list.to_s ).to eq 'Tag 1, Tag 2, Tag 3'
      end
    end
    context 'with pre-existing tags' do
      before(:all) do
        @event = FactoryGirl.create(:event)
      end
      it 'should remove existing tags that aren’t in the given string' do
        Tag.delete_all
        @event.tag_list = 'Keep 1, Remove 1, Remove 2'
        @event.save!
        @event.tag_list = 'Keep 1, New Tag'
        @event.save!
        @event.reload
        expect( @event.tag_list.to_s ).to eq 'Keep 1, New Tag'
      end
      it 'should change the title on tags that match with different titles' do
        Tag.delete_all
        @event.tag_list = 'Change 1, Change 2'
        @event.save!
        @event.tag_list = 'change1, change2'
        @event.save!
        @event.reload
        expect( @event.tag_list.to_s ).to eq 'change1, change2'
      end
    end
  end

  describe "#is_multi_day" do
    let(:event) { $event = Event.new(start_at: '2004-05-06 7:08am') }
    context "with no end time" do
      it "should return false" do
        expect( event.is_multi_day ).to be_false
      end
    end
    context "with an end time on the same date as the start time" do
      it "should return false" do
        event.end_at = event.start_at + 1.hour
        expect( event.is_multi_day ).to be_false
      end
    end
    context "with an end time on a later date" do
      it "should return true" do
        event.end_at = event.start_at + 1.week
        expect( event.is_multi_day ).to be_true
      end
    end
  end

  describe "#approve_by" do
    let(:event) { $event = FactoryGirl.create(:event, is_approved: false) }
    it "should return true if already approved" do
      event.is_approved = true
      expect( event.approve_by(nil) ).to be_true
    end
    context "with an authorized user" do
      it "should set is_approved" do
        event.approve_by(@user_admin)
        expect( event.is_approved? ).to be_true
      end
      it "should save the event" do
        event.approve_by(@user_admin)
        expect( event.changed? ).to be_false
      end
    end
    it "should return false if user is nil" do
      expect( event.approve_by(nil) ).to be_false
    end
    it "should return false if user is unauthorized" do
      expect( event.approve_by(@user_normal) ).to be_false
    end
    it "should not set the locally modified flag on shared items" do
      sourced_at = 1.hour.ago
      sourced_item = event.sourced_items.new(last_sourced_at: sourced_at)
      sourced_item.source = FactoryGirl.create(:source, last_updated_at: sourced_at)
      sourced_item.save
      event.approve_by(@user_admin)
      expect( event.sourced_items.first.has_local_modifications? ).to be_false
    end
  end

  # icalendar source processing

  describe "#update_from_icalendar" do
    let(:start_time) { $start_time = 25.hours.ago }
    let(:end_time) { $end_time = 24.hours.ago }
    let(:changed_ievent) do
      $changed_ievent = {
        'ATTACH' => { value: 'http://changed.tld/attach' },
        'DESCRIPTION' => { value: 'Changed description.' },
        'DTSTART' => { value: start_time },
        'DTEND' => { value: end_time },
        'LOCATION' => { value: 'Change Place' },
        'ORGANIZER' => { value: 'Change Org' },
        'SUMMARY' => { value: 'Changed Summary' },
        'URL' => { value: 'http://change.tld/url' },
        'UID' => { value: '123@spec' }
      }
    end
    context "with no local changes to the event" do
      it "should overwrite any changed information" do
        # make a slightly different ievent
        event = Event.new
        # update the event using the different ievent
        event.update_from_icalendar(changed_ievent)
        event_values = [
          event.description, event.start_at, event.end_at, event.location, event.organizer, event.title
        ]
        expect( event_values ).to eq([
          'Changed description.', start_time, end_time,
          'Change Place', 'Change Org', 'Changed Summary'
        ])
      end
      it "should accept an editor" do
        # TODO: text passing an editor to Event#update_from_icalendar
        #pending
      end
    end
    context "with local changes to the event" do
      # TODO: handle processing an update for an event with local changes
      it "should return false" do
        # set the last arg to true (has_local_modifications)
        expect( Event.new.update_from_icalendar(changed_ievent, has_local_modifications: true) ).to be_false
      end
    end
  end

end
