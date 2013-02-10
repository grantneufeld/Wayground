# encoding: utf-8
require 'spec_helper'

describe Event do

  before(:all) do
    Authority.delete_all
    User.destroy_all
    # first user is automatically an admin
    @user_admin = FactoryGirl.create(:user, :name => 'Admin User')
    @user_normal = FactoryGirl.create(:user, :name => 'Normal User')
  end

  let(:source) { $source = FactoryGirl.create(:source) }

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
        Event.delete_all
        # past events
        event1 = FactoryGirl.create(:event, :start_at => 2.weeks.ago)
        event2 = FactoryGirl.create(:event, :start_at => 1.day.ago)
        # create an event that occurred earlier today
        FactoryGirl.create(:event, :start_at => Time.current.beginning_of_day)
        # create an event happening in just a minute
        FactoryGirl.create(:event, :start_at => Time.current.advance(:minutes => 1))
        # create a future event
        FactoryGirl.create(:event, :start_at => 1.day.from_now)
        Event.past.should eq [event1, event2]
      end
    end
  end

  describe "initialize" do
    it "should set the city, province and country" do
      event = Event.new
      [event.city, event.province, event.country].should eq ['Calgary', 'Alberta', 'CA']
    end
    it "should not set any location defaults if city is set" do
      event = Event.new(city: 'Test')
      [event.city, event.province, event.country].should eq ['Test', nil, nil]
    end
    it "should not set any location defaults if city is set" do
      event = Event.new(province: 'Test')
      [event.city, event.province, event.country].should eq [nil, 'Test', nil]
    end
    it "should not set any location defaults if country is set" do
      event = Event.new(country: 'Test')
      [event.city, event.province, event.country].should eq [nil, nil, 'Test']
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

  describe "#flag_as_modified_for_sourcing" do
    let(:event) { $event = FactoryGirl.create(:event) }
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
      event.flag_as_modified_for_sourcing
      event.sourced_items[0].has_local_modifications?.should be_true
      event.sourced_items[1].has_local_modifications?.should be_true
    end
    it "should not touch the sourced_items when is_sourcing is set true" do
      sourced_item.has_local_modifications = false
      sourced_item.save!
      event.is_sourcing = true
      event.flag_as_modified_for_sourcing
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

  describe "#title=" do
    it "should set the title attribute" do
      event = Event.new
      event.title = 'test'
      event.title.should eq 'test'
    end
    it "should clear the title attribute when nil is given" do
      event = Event.new(title: 'Test')
      event.title = nil
      event.title.should be_nil
    end
    it "should try to clean up the string passed in" do
      event = Event.new
      event.title = " A  Messy \t String\t"
      event.title.should eq 'A Messy String'
    end
  end
  describe "#description=" do
    it "should set the description attribute" do
      event = Event.new
      event.description = 'test'
      event.description.should eq 'test'
    end
    it "should clear the description attribute when nil is given" do
      event = Event.new(description: 'Test')
      event.description = nil
      event.description.should be_nil
    end
    it "should try to clean up the string passed in" do
      event = Event.new
      event.description = " A  Messy \t String\t"
      event.description.should eq 'A Messy String'
    end
  end
  describe "#content=" do
    it "should set the content attribute" do
      event = Event.new
      event.content = 'test'
      event.content.should eq 'test'
    end
    it "should clear the content attribute when nil is given" do
      event = Event.new(content: 'Test')
      event.content = nil
      event.content.should be_nil
    end
    it "should try to clean up the string passed in" do
      event = Event.new
      event.content = " A  Messy \t String\t"
      event.content.should eq 'A Messy String'
    end
  end
  describe "#organizer=" do
    it "should set the organizer attribute" do
      event = Event.new
      event.organizer = 'test'
      event.organizer.should eq 'test'
    end
    it "should clear the organizer attribute when nil is given" do
      event = Event.new(organizer: 'Test')
      event.organizer = nil
      event.organizer.should be_nil
    end
    it "should try to clean up the string passed in" do
      event = Event.new
      event.organizer = " A  Messy \t String\t"
      event.organizer.should eq 'A Messy String'
    end
  end
  describe "#organizer_url=" do
    it "should set the organizer_url attribute" do
      event = Event.new
      event.organizer_url = 'test'
      event.organizer_url.should eq 'test'
    end
    it "should clear the organizer_url attribute when nil is given" do
      event = Event.new(organizer_url: 'Test')
      event.organizer_url = nil
      event.organizer_url.should be_nil
    end
    it "should try to clean up the url passed in" do
      event = Event.new
      event.organizer_url = 'http://twitter.com/#!/wayground'
      event.organizer_url.should eq 'https://twitter.com/wayground'
    end
  end
  describe "#location=" do
    it "should set the location attribute" do
      event = Event.new
      event.location = 'test'
      event.location.should eq 'test'
    end
    it "should clear the location attribute when nil is given" do
      event = Event.new(location: 'Test')
      event.location = nil
      event.location.should be_nil
    end
    it "should try to clean up the string passed in" do
      event = Event.new
      event.location = " A  Messy \t String\t"
      event.location.should eq 'A Messy String'
    end
  end
  describe "#address=" do
    it "should set the address attribute" do
      event = Event.new
      event.address = 'test'
      event.address.should eq 'test'
    end
    it "should clear the address attribute when nil is given" do
      event = Event.new(address: 'Test')
      event.address = nil
      event.address.should be_nil
    end
    it "should try to clean up the string passed in" do
      event = Event.new
      event.address = " A  Messy \t String\t"
      event.address.should eq 'A Messy String'
    end
  end
  describe "#city=" do
    it "should set the city attribute" do
      event = Event.new
      event.city = 'test'
      event.city.should eq 'test'
    end
    it "should clear the city attribute when nil is given" do
      event = Event.new(city: 'Test')
      event.city = nil
      event.city.should be_nil
    end
    it "should try to clean up the string passed in" do
      event = Event.new
      event.city = " A  Messy \t String\t"
      event.city.should eq 'A Messy String'
    end
  end
  describe "#province=" do
    it "should set the province attribute" do
      event = Event.new
      event.province = 'test'
      event.province.should eq 'test'
    end
    it "should clear the province attribute when nil is given" do
      event = Event.new(province: 'Test')
      event.province = nil
      event.province.should be_nil
    end
    it "should try to clean up the string passed in" do
      event = Event.new
      event.province = " A  Messy \t String\t"
      event.province.should eq 'A Messy String'
    end
  end
  describe "#location_url=" do
    it "should set the location_url attribute" do
      event = Event.new
      event.location_url = 'test'
      event.location_url.should eq 'test'
    end
    it "should clear the location_url attribute when nil is given" do
      event = Event.new(location_url: 'Test')
      event.location_url = nil
      event.location_url.should be_nil
    end
    it "should try to clean up the url passed in" do
      event = Event.new
      event.location_url = 'http://twitter.com/#!/wayground'
      event.location_url.should eq 'https://twitter.com/wayground'
    end
  end

  describe "#approve_by" do
    let(:event) { $event = FactoryGirl.create(:event, is_approved: false) }
    it "should return true if already approved" do
      event.is_approved = true
      event.approve_by(nil).should be_true
    end
    context "with an authorized user" do
      it "should set is_approved" do
        event.approve_by(@user_admin)
        event.is_approved?.should be_true
      end
      it "should save the event" do
        event.approve_by(@user_admin)
        event.changed?.should be_false
      end
    end
    it "should return false if user is nil" do
      event.approve_by(nil).should be_false
    end
    it "should return false if user is unauthorized" do
      event.approve_by(@user_normal).should be_false
    end
    it "should not set the locally modified flag on shared items" do
      sourced_at = 1.hour.ago
      sourced_item = event.sourced_items.new(last_sourced_at: sourced_at)
      sourced_item.source = FactoryGirl.create(:source, last_updated_at: sourced_at)
      sourced_item.save
      event.approve_by(@user_admin)
      event.sourced_items.first.has_local_modifications?.should be_false
    end
  end

  # icalendar source processing

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
        event = Event.new
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
        Event.new.update_from_icalendar(changed_ievent, has_local_modifications: true).should be_false
      end
    end
  end

end
