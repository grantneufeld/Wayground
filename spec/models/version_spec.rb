# encoding: utf-8
require 'spec_helper'

describe Version do

  before(:all) do
    Version.delete_all
  end

  describe "validation" do
    before(:all) do
      @page = FactoryGirl.create(:page)
      @user = FactoryGirl.create(:user)
    end
    it "should pass when all required fields are set" do
      version = Version.new(:item => @page, :user => @user, :edited_at => Time.now)
      version.valid?.should be_true
    end
    it "should require an item" do
      version = Version.new(:user => @user, :edited_at => Time.now)
      version.valid?.should be_false
    end
    it "should require a user" do
      version = Version.new(:item => @page, :edited_at => Time.now)
      version.valid?.should be_false
    end
    it "should require an edited at datetime" do
      version = Version.new(:item => @page, :user => @user)
      version.valid?.should be_false
    end
  end

  # SCOPES

  describe "default_scope" do
    it "should keep the versions in order from oldest to newest" do
      item = FactoryGirl.create(:page)
      newest_version = item.versions[0]
      # create in reverse order just to make sure they’re getting sorted
      middle_version = FactoryGirl.create(:version, :item => item, :edited_at => 1.week.ago)
      oldest_version = FactoryGirl.create(:version, :item => item, :edited_at => 1.month.ago)
      # reload item to reload versions
      item = Page.find(item.id)
      item.versions.should eq [oldest_version, middle_version, newest_version]
    end
  end

  describe ".versions_before" do
    it "should restrict searches to versions that occurred before a given datetime" do
      item = FactoryGirl.create(:page)
      item.versions.delete_all
      first = FactoryGirl.create(:version, :item => item, :edited_at => 5.days.ago)
      second = FactoryGirl.create(:version, :item => item, :edited_at => 4.days.ago)
      FactoryGirl.create(:version, :item => item, :edited_at => 2.days.ago)
      FactoryGirl.create(:version, :item => item, :edited_at => 1.days.ago)
      item.versions.versions_before(3.days.ago).should eq [first, second]
    end
  end

  describe ".versions_after" do
    it "should restrict searches to versions that occurred after a given datetime" do
      item = FactoryGirl.create(:page)
      FactoryGirl.create(:version, :item => item, :edited_at => 2.days.from_now)
      versions = []
      versions << FactoryGirl.create(:version, :item => item, :edited_at => 4.days.from_now)
      versions << FactoryGirl.create(:version, :item => item, :edited_at => 5.days.from_now)
      item.versions.versions_after(3.days.from_now).should eq versions
    end
  end

  describe ".current_versions" do
    it "should restrict searches to the current versions for each item" do
      Version.delete_all
      Page.delete_all
      item = FactoryGirl.create(:page)
      first = FactoryGirl.create(:version, :item => item, :edited_at => 1.days.from_now)
      item = FactoryGirl.create(:page)
      second = FactoryGirl.create(:version, :item => item, :edited_at => 1.days.from_now)
      Version.current_versions.should eq [first, second]
    end
  end

  # METHODS

  describe ".first_versions" do
    it "should restrict searches to the first versions for each item" do
      # FIXME: I haven’t figured out why the grouping scope only selects the latest, ignoring order
    end
  end

  describe "#previous" do
    it "should return nothing if this is the first version" do
      version = FactoryGirl.create(:page).versions.first
      Version.find(version.id).previous.should be_nil
    end
    it "should return the first version if this is the second" do
      item = FactoryGirl.create(:page)
      item.versions.delete_all
      first_version = FactoryGirl.create(:version, :item => item, :edited_at => 1.week.ago)
      version = FactoryGirl.create(:version, :item => item, :edited_at => 1.day.ago)
      version.previous.should eq first_version
    end
    it "should return the previous version when this version is in the middle" do
      item = FactoryGirl.create(:page)
      item.versions.delete_all
      first_version = FactoryGirl.create(:version, :item => item, :edited_at => 2.weeks.ago)
      second_version = FactoryGirl.create(:version, :item => item, :edited_at => 2.weeks.ago)
      version = FactoryGirl.create(:version, :item => item, :edited_at => 1.week.ago)
      last_version = FactoryGirl.create(:version, :item => item, :edited_at => 1.day.ago)
      version.previous.should eq second_version
    end
    it "should return the previous version when this version is the last of many" do
      item = FactoryGirl.create(:page)
      item.versions.delete_all
      first_version = FactoryGirl.create(:version, :item => item, :edited_at => 2.weeks.ago)
      second_version = FactoryGirl.create(:version, :item => item, :edited_at => 2.weeks.ago)
      third_version = FactoryGirl.create(:version, :item => item, :edited_at => 1.week.ago)
      version = FactoryGirl.create(:version, :item => item, :edited_at => 1.day.ago)
      version.previous.should eq third_version
    end
  end

  describe "#current" do
    it "should return the most recent edit on the version’s item" do
      item = FactoryGirl.create(:page)
      version = FactoryGirl.create(:version, :item => item, :edited_at => 2.hours.from_now)
      current = FactoryGirl.create(:version, :item => item, :edited_at => 3.hours.from_now)
      version.current.should == current
    end
  end

  describe "#is_current?" do
    it "should be true if this is the only version" do
      item = FactoryGirl.create(:page)
      item.versions[0].is_current?.should be_true
    end
    it "should be true if this is the latest version" do
      item = FactoryGirl.create(:page)
      version = FactoryGirl.create(:version, :item => item, :edited_at => 1.day.from_now)
      version.is_current?.should be_true
    end
    it "should be false if this is not the latest version" do
      item = FactoryGirl.create(:page)
      item.versions.delete_all
      version = FactoryGirl.create(:version, :item => item, :edited_at => 2.weeks.ago)
      middle_version = FactoryGirl.create(:version, :item => item, :edited_at => 1.week.ago)
      new_version = FactoryGirl.create(:version, :item => item, :edited_at => 1.day.ago)
      middle_version.is_current?.should be_false
    end
  end

end
