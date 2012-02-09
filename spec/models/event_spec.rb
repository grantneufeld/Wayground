# encoding: utf-8
require 'spec_helper'

describe Event do

  before do
    Authority.delete_all
    User.destroy_all
    # first user is automatically an admin
    @user_admin = Factory.create(:user, :name => 'Admin User')
    @user_normal = Factory.create(:user, :name => 'Normal User')
  end

  describe "acts_as_authority_controlled" do
    it "should be in the “Calendar” area" do
      Event.authority_area.should eq 'Calendar'
    end
  end

  describe "attr_accessible" do
    it "should not allow user to be set" do
      event = Event.new(:user => @user_normal)
      event.user.should be_nil
    end
    it "should not allow user_id to be set" do
      event = Event.new(:user_id => @user_normal.id)
      event.user_id.should be_nil
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
      event = Event.new(:is_approved => true)
      event.is_approved.should be_false
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
  end

  describe "validation" do
    describe "of start_at" do
      it "should fail if start_at is not set" do
        event = Event.new(:title => 'missing start_at')
        event.valid?.should be_false
      end
    end
    describe "of end_at" do
      it "should fail if end_at is equal to start_at" do
        event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'end_at = start_at',
          :end_at => '2012-01-01 01:01:01'
        )
        event.valid?.should be_false
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
      it "should fail if description is too long" do
        event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'too long description',
          :description => ('A' * 511)
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

  describe "scopes" do
    describe "default_scope" do
      it "should order by start date & time by default" do
        event2 = Factory.create(:event, :start_at => '2002-02-02 02:02:02')
        event4 = Factory.create(:event, :start_at => '2004-04-04 04:04:04')
        event3 = Factory.create(:event, :start_at => '2003-03-03 03:03:03')
        event1 = Factory.create(:event, :start_at => '2001-01-01 01:01:01')
        Event.all.should eq [event1, event2, event3, event4]
      end
    end
    describe ".approved" do
      it "should return only events where is_approved" do
        event1 = Factory.build(:event)
        event1.is_approved = true
        event1.save!
        event2 = Factory.build(:event)
        event2.is_approved = false
        event2.save!
        event3 = Factory.build(:event)
        event3.is_approved = true
        event3.save!
        Event.approved.should eq [event1, event3]
      end
    end
    describe ".current" do
      it "should return only events that are active on, or after, the current current date & time" do
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
      event.user = Factory.create(:user)
      authority = Factory.create(:owner_authority, :area => 'Calendar', :user => event.user)
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
      event.user = Factory.build(:user, :timezone => tz_str)
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
      event.user = Factory.build(:user, :timezone => 'UTC')
      event.set_timezone
      event.timezone.should eq 'Saskatchewan'
    end
    it "should be automatically called on create" do
      event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'auto-set timezone on create')
      event.save!
      event.timezone.present?.should be_true
    end
    it "should not be called on update" do
      event = Event.new(:start_at => '2012-01-01 01:01:01', :title => 'no timezone on update')
      event.save!
      event.timezone = nil
      event.save!
      event.timezone.present?.should be_false
    end
  end

end
