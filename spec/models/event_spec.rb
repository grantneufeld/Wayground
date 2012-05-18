# encoding: utf-8
require 'spec_helper'

describe Event do

  before do
    Authority.delete_all
    User.destroy_all
    # first user is automatically an admin
    @user_admin = FactoryGirl.create(:user, :name => 'Admin User')
    @user_normal = FactoryGirl.create(:user, :name => 'Normal User')
  end

  describe "acts_as_authority_controlled" do
    it "should be in the “Calendar” area" do
      Event.authority_area.should eq 'Calendar'
    end
  end

  describe "attr_accessor" do
    it "should provide an editor accessor" do
      event = Event.new
      event.editor = 'test'
      event.editor.should eq 'test'
    end
    it "should provide an edit_comment accessor" do
      event = Event.new
      event.edit_comment = 'test'
      event.edit_comment.should eq 'test'
    end
  end

  describe "attr_accessible" do
    it "should not allow user to be set" do
      expect {
        event = Event.new(:user => @user_normal)
      }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should not allow user_id to be set" do
      expect {
        event = Event.new(:user_id => @user_normal.id)
      }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should allow start_at to be set" do
      event = Event.new(:start_at => '2012-01-02 03:04:05')
      event.start_at.getlocal.to_s(:db).should eq '2012-01-02 03:04:05'
    end
    it "should allow end_at to be set" do
      event = Event.new(:end_at => '2012-06-07 08:09:10')
      event.end_at.getlocal.to_s(:db).should eq '2012-06-07 08:09:10'
    end
    it "should allow timezone to be set" do
      event = Event.new(:timezone => 'UTC')
      event.timezone.should eq 'UTC'
    end
    it "should allow is_allday to be set" do
      event = Event.new(:is_allday => true)
      event.is_allday.should be_true
    end
    it "should allow is_draft to be set" do
      event = Event.new(:is_draft => true)
      event.is_draft.should be_true
    end
    it "should not allow is_approved to be set" do
      expect {
        event = Event.new(:is_approved => true)
      }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should allow is_wheelchair_accessible to be set" do
      event = Event.new(:is_wheelchair_accessible => true)
      event.is_wheelchair_accessible.should be_true
    end
    it "should allow is_adults_only to be set" do
      event = Event.new(:is_adults_only => true)
      event.is_adults_only.should be_true
    end
    it "should allow is_tentative to be set" do
      event = Event.new(:is_tentative => true)
      event.is_tentative.should be_true
    end
    it "should allow is_cancelled to be set" do
      event = Event.new(:is_cancelled => true)
      event.is_cancelled.should be_true
    end
    it "should allow is_featured to be set" do
      event = Event.new(:is_featured => true)
      event.is_featured.should be_true
    end
    it "should allow title to be set" do
      event = Event.new(:title => 'set title')
      event.title.should eq 'set title'
    end
    it "should allow description to be set" do
      event = Event.new(:description => 'set description')
      event.description.should eq 'set description'
    end
    it "should allow content to be set" do
      event = Event.new(:content => 'set content')
      event.content.should eq 'set content'
    end
    it "should allow organizer to be set" do
      event = Event.new(:organizer => 'set organizer')
      event.organizer.should eq 'set organizer'
    end
    it "should allow organizer_url to be set" do
      event = Event.new(:organizer_url => 'set organizer_url')
      event.organizer_url.should eq 'set organizer_url'
    end
    it "should allow location to be set" do
      event = Event.new(:location => 'set location')
      event.location.should eq 'set location'
    end
    it "should allow address to be set" do
      event = Event.new(:address => 'set address')
      event.address.should eq 'set address'
    end
    it "should allow city to be set" do
      event = Event.new(:city => 'set city')
      event.city.should eq 'set city'
    end
    it "should allow province to be set" do
      event = Event.new(:province => 'set province')
      event.province.should eq 'set province'
    end
    it "should allow country to be set" do
      event = Event.new(:country => 'set country')
      event.country.should eq 'set country'
    end
    it "should allow location_url to be set" do
      event = Event.new(:location_url => 'set location_url')
      event.location_url.should eq 'set location_url'
    end
    it "should allow external_links_attributes to be set" do
      url = 'http://set.external_links_attributes.tld/'
      event = Event.new(:external_links_attributes => {'0' => {:url => url}})
      event.external_links[0].url.should eq url
    end
    it "should not allow editor to be set" do
      expect {
        event = Event.new(:editor => @user_normal)
      }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should allow edit_comment to be set" do
      event = Event.new(:edit_comment => 'set edit_comment')
      event.edit_comment.should eq 'set edit_comment'
    end
  end

  describe "validation" do
    describe "of start_at" do
      it "should fail if start_at is not set" do
        event = Event.new(:title => 'missing start_at')
        event.valid?.should be_false
      end
    end
    describe "of end_at" do
      it "should pass if end_at is equal to start_at" do
        event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'end_at = start_at',
          :end_at => '2012-01-01 01:01:01'
        )
        event.valid?.should be_true
      end
      it "should fail if end_at is less than start_at" do
        event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'end_at < start_at',
          :end_at => '2012-01-01 01:01:00'
        )
        event.valid?.should be_false
      end
    end
    describe "of timezone" do
      it "should pass if timezone is nil" do
        Event.new(:start_at => '2012-01-01 01:01:01', :title => 'not a timezone',
          :timezone => nil
        ).valid?.should be_true
      end
      it "should pass if timezone is blank" do
        Event.new(:start_at => '2012-01-01 01:01:01', :title => 'not a timezone',
          :timezone => ''
        ).valid?.should be_true
      end
      it "should pass if timezone is one of the recognized timezones" do
        Event.new(:start_at => '2012-01-01 01:01:01', :title => 'UTC timezone',
          :timezone => 'UTC'
        ).valid?.should be_true
      end
      it "should fail if the string is present but not a timezone" do
        Event.new(:start_at => '2012-01-01 01:01:01', :title => 'not a timezone',
          :timezone => 'invalid timezone'
        ).valid?.should be_false
      end
    end
    describe "of is_approved" do
      it "should fail if both is_approved and is_draft are true" do
        event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'is_approved and is_draft',
          :is_draft => true
        )
        event.is_approved = true
        event.valid?.should be_false
      end
    end
    describe "of title" do
      it "should fail if title is not set" do
        event = Event.new(:start_at => '2012-01-01 01:01:01')
        event.valid?.should be_false
      end
      it "should fail if title is blank" do
        event = Event.new(:title => '', :start_at => '2012-01-01 01:01:01')
        event.valid?.should be_false
      end
      it "should fail if title is too long" do
        event = Event.new(:title => ('A' * 256), :start_at => '2012-01-01 01:01:01')
        event.valid?.should be_false
      end
    end
    describe "of description" do
      it "should pass if description is the maximum length" do
        event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'max length description',
          :description => ('A' * 511)
        )
        event.valid?.should be_true
      end
      it "should fail if description is too long" do
        event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'too long description',
          :description => ('A' * 512)
        )
        event.valid?.should be_false
      end
    end
    describe "of content" do
      it "should fail if content is too long" do
        event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'too long content',
          :content => ('A' * 8192)
        )
        event.valid?.should be_false
      end
    end
    describe "of organizer" do
      it "should fail if organizer is too long" do
        event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'too long organizer',
          :organizer => ('A' * 256)
        )
        event.valid?.should be_false
      end
    end
    describe "of organizer_url" do
      it "should fail if organizer_url is too long" do
        event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'too long organizer_url',
          :organizer_url => ('A' * 256)
        )
        event.valid?.should be_false
      end
    end
    describe "of location" do
      it "should fail if location is too long" do
        event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'too long location',
          :location => ('A' * 256)
        )
        event.valid?.should be_false
      end
    end
    describe "of address" do
      it "should fail if address is too long" do
        event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'too long address',
          :address => ('A' * 256)
        )
        event.valid?.should be_false
      end
    end
    describe "of city" do
      it "should fail if city is too long" do
        event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'too long city',
          :city => ('A' * 256)
        )
        event.valid?.should be_false
      end
    end
    describe "of province" do
      it "should fail if province is too long" do
        event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'too long province',
          :province => ('A' * 32)
        )
        event.valid?.should be_false
      end
    end
    describe "of country" do
      it "should fail if country is too long" do
        event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'too long country',
          :country => ('A' * 3)
        )
        event.valid?.should be_false
      end
    end
    describe "of location_url" do
      it "should fail if location_url is too long" do
        event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'too long location_url',
          :location_url => ('A' * 256)
        )
        event.valid?.should be_false
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
        event2 = FactoryGirl.create(:event, :start_at => '2002-02-02 02:02:02')
        event4 = FactoryGirl.create(:event, :start_at => '2004-04-04 04:04:04')
        event3 = FactoryGirl.create(:event, :start_at => '2003-03-03 03:03:03')
        event1 = FactoryGirl.create(:event, :start_at => '2001-01-01 01:01:01')
        Event.all.should eq [event1, event2, event3, event4]
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
        Event.approved.should eq [event1, event3]
      end
    end
    describe ".upcoming" do
      it "should return only events that are active on, or after, the current current date & time" do
        Event.delete_all
        # create some past events
        FactoryGirl.create(:event, :start_at => 1.day.ago)
        FactoryGirl.create(:event, :start_at => 2.weeks.ago)
        FactoryGirl.create(:event, :start_at => 3.months.ago)
        # create an event that occurred earlier today
        event1 = FactoryGirl.create(:event, :start_at => Time.current.beginning_of_day)
        # create an event happening in just a minute
        event2 = FactoryGirl.create(:event, :start_at => Time.current.advance(:minutes => 1))
        # create some future events
        event3 = FactoryGirl.create(:event, :start_at => 1.hour.from_now)
        event4 = FactoryGirl.create(:event, :start_at => 2.days.from_now)
        event5 = FactoryGirl.create(:event, :start_at => 3.months.from_now)
        Event.upcoming.should eq [event1, event2, event3, event4, event5]
      end
    end
    describe ".past" do
      it "should return only events that ended before the current date & time" do
      end
    end
  end

  describe "approve_if_authority" do
    it "should not set is_approved if regular user" do
      event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'already approved')
      event.user = @user_normal
      # TESTING:
      event.user.has_authority_for_area('Calendar', :is_owner).should be_false
      # actual tests:
      event.approve_if_authority
      event.is_approved.should be_false
    end
    it "should set is_approved to true when user has authority" do
      event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'admin created event')
      event.user = FactoryGirl.create(:user)
      authority = FactoryGirl.create(:owner_authority, :area => 'Calendar', :user => event.user)
      # TESTING:
      event.user.has_authority_for_area('Calendar', :is_owner).should be_true
      # actual tests:
      event.approve_if_authority
      event.is_approved.should be_true
    end
    it "should not change is_approved if already true" do
      event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'already approved')
      event.is_approved = true
      event.user = @user_normal
      # TESTING:
      event.user.has_authority_for_area('Calendar', :is_owner).should be_false
      # actual tests:
      event.approve_if_authority
      event.is_approved.should be_true
    end
  end

  describe "#set_timezone" do
    it "should set the timezone based on the user" do
      tz_str = 'Central Time (US & Canada)'
      event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'user’s timezone')
      event.user = FactoryGirl.build(:user, :timezone => tz_str)
      event.set_timezone
      event.timezone.should eq tz_str
    end
    it "should set the timezone to the system default if no user" do
      default_tz = Time.zone_default
      tz_str = 'Pacific Time (US & Canada)'
      Time.zone_default = ActiveSupport::TimeZone[tz_str]
      event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'system default timezone')
      event.set_timezone
      event.timezone.should eq tz_str
      Time.zone_default = default_tz
    end
    it "should not override an existing timezone" do
      event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'preset timezone',
        :timezone => 'Saskatchewan'
      )
      event.user = FactoryGirl.build(:user, :timezone => 'UTC')
      event.set_timezone
      event.timezone.should eq 'Saskatchewan'
    end
    it "should be automatically called on create" do
      event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'auto-set timezone on create')
      event.editor = @user_admin
      event.save!
      event.timezone.present?.should be_true
    end
    it "should not be called on update" do
      event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'no timezone on update')
      event.editor = @user_admin
      event.save!
      event.timezone = nil
      event.save!
      event.timezone.present?.should be_false
    end
  end

  describe "#flag_for_sourcing" do
    let(:event) { $event = FactoryGirl.create(:event) }
    let(:source) { $source = FactoryGirl.create(:source) }
    let(:sourced_item) {
      $sourced_item = FactoryGirl.create(:sourced_item, :item => event, :source => source)
    }

    it "should be called when updating an Event" do
      sourced_item.has_local_modifications = false
      sourced_item.save!
      event.update_attributes(title: 'Updated')
      sourced_item.reload
      sourced_item.has_local_modifications?.should be_true
    end
    it "should set the has_local_modifications for all sourced_items" do
      sourced_item.has_local_modifications = false
      sourced_item.save!
      source2 = FactoryGirl.create(:source)
      sourced_item2 = event.sourced_items.new(last_sourced_at: source2.last_updated_at)
      sourced_item2.source = source2
      sourced_item2.save!
      # should not have updated event yet
      sourced_item.has_local_modifications?.should be_false
      sourced_item2.has_local_modifications?.should be_false
      # “update” the event
      event.flag_for_sourcing
      event.sourced_items[0].has_local_modifications?.should be_true
      event.sourced_items[1].has_local_modifications?.should be_true
    end
    it "should not touch the sourced_items when is_sourcing is set true" do
      sourced_item.has_local_modifications = false
      sourced_item.save!
      event.is_sourcing = true
      event.flag_for_sourcing
      event.sourced_items[0].has_local_modifications?.should be_false
    end
  end

  describe "#add_version" do
    it "should add a Version" do
      event = FactoryGirl.create(:event, :editor => @user_admin, :edit_comment => 'add a version')
      expect { event.add_version }.to change{event.versions.count}.by(1)
    end
    it "should fail if editor has not been set" do
      event = FactoryGirl.create(:event, :editor => @user_admin, :edit_comment => 'without editor')
      event.editor = nil
      expect { event.add_version }.to raise_error
    end
    it "should be called after an event is created" do
      event = FactoryGirl.build(:event, :editor => @user_admin, :edit_comment => 'add_version after save')
      expect { event.save! }.to change{event.versions.count}.by(1)
    end
    it "should be called after an event is updated" do
      event = FactoryGirl.create(:event, :editor => @user_admin, :edit_comment => 'add_version after update')
      expect { event.update_attributes(:title => 'updated version') }.to change{event.versions.count}.by(1)
    end
  end

  # icalendar source processing

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
  let(:ievent) { $ievent = new_ievent }
  let(:event) { $event = Event.create_from_icalendar(ievent) }

  describe ".icalendar_field_mapping" do
    it "should use SUMMARY as the title" do
      Event.icalendar_field_mapping(new_ievent)[:title].should eq 'Spec Event'
    end
    it "should use DESCRIPTION as the description" do
      Event.icalendar_field_mapping(new_ievent)[:description].should eq 'Spec description.'
    end
    it "should split the description after the first paragraph after 100 chars if too long" do
      event = Event.icalendar_field_mapping(
        new_ievent('DESCRIPTION' => {:value => ('A' * 99) + "\n" + ('B' * 100) + "\nEtc." + ('C' * 350) })
      )
      [event[:description], event[:content]].should eq [
        ('A' * 99) + "\n" + ('B' * 100),
        'Etc.' + ('C' * 350)
      ]
    end
    it "should split the description on the last sentence break in a too long paragraph" do
      event = Event.icalendar_field_mapping(
        new_ievent('DESCRIPTION' => {:value => ('A' * 200) + '. ' + ('B' * 200) + '! ' + ('C' * 200) + '?' })
      )
      [event[:description], event[:content]].should eq [
        ('A' * 200) + '. ' + ('B' * 200) + '!',
        ('C' * 200) + '?'
      ]
    end
    it "should split the description on the last space in a too long sentence" do
      event = Event.icalendar_field_mapping(
        new_ievent('DESCRIPTION' => {:value => ('A' * 200) + ' ' + ('B' * 200) + ' ' + ('C' * 200) + ' ' })
      )
      [event[:description], event[:content]].should eq [
        ('A' * 200) + ' ' + ('B' * 200),
        ('C' * 200)
      ]
    end
    it "should split the description after the 100th char if an unbroken blob of characters" do
      event = Event.icalendar_field_mapping(
        new_ievent('DESCRIPTION' => {:value => ('A' * 100) + 'B' + ('C' * 411)})
      )
      [event[:description], event[:content]].should eq ['A' * 100, 'B' + ('C' * 411)]
    end
    it "should use LOCATION as the location" do
      Event.icalendar_field_mapping(new_ievent)[:location].should eq 'Spec Town, 123 Spec Street'
    end
    it "should use ORGANIZER as the organizer" do
      Event.icalendar_field_mapping(new_ievent)[:organizer].should eq 'Spec Organization'
    end
    it "should use DTSTART as the start_at date & time" do
      date = '2001-02-03 04:05:06 MST'.to_datetime
      Event.icalendar_field_mapping(
        new_ievent('DTSTART' => {:value => date})
      )[:start_at].should eq date
    end
    it "should use DTEND as the end_at date & time" do
      date = '2001-02-03 04:05:06 MST'.to_datetime
      Event.icalendar_field_mapping(
        new_ievent('DTEND' => {:value => date})
      )[:end_at].should eq date
    end
  end

  describe ".create_from_icalendar" do
    it "should create a new event" do
      event.class.should eq Event
    end
    context "with a given user" do
      let(:user) { $user = @user_normal }
      it "should set the version editor to the user" do
        Event.create_from_icalendar(ievent, user).versions.first.user.should eq user
      end
    end
  end

  describe "#update_from_icalendar" do
    let(:start_time) { $start_time = 25.hours.ago }
    let(:end_time) { $end_time = 24.hours.ago }
    let(:changed_ievent) do
      $changed_ievent = {
        'ATTACH' => {value: 'http://changed.tld/attach'},
        'DESCRIPTION' => {value: 'Changed description.'},
        'DTSTART' => {value: start_time},
        'DTEND' => {value: end_time},
        'LOCATION' => {value: 'Change Place'},
        'ORGANIZER' => {value: 'Change Org'},
        'SUMMARY' => {value: 'Changed Summary'},
        'URL' => {value: 'http://change.tld/url'},
        'UID' => {value: '123@spec'}
      }
    end
    context "with no local changes to the event" do
      it "should overwrite any changed information" do
        # make a slightly different ievent
        # update the event using the different ievent
        event.update_from_icalendar(changed_ievent)
        [ event.description, event.start_at, event.end_at,
          event.location, event.organizer, event.title
        ].should eq([
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
        Event.new.update_from_icalendar(changed_ievent, nil, true).should be_false
      end
    end
  end

end
