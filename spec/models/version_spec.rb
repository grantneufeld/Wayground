# encoding: utf-8
require 'spec_helper'

describe Version do

  before(:all) do
    Version.delete_all
    @item = FactoryGirl.create(:page)
    @user = FactoryGirl.create(:user)
  end

  describe "validation" do
    it "should pass when all required fields are set" do
      version = @item.versions.new(edited_at: Time.now)
      version.user = @user
      version.valid?.should be_true
    end
    it "should require an item" do
      version = Version.new(edited_at: Time.now)
      version.user = @user
      version.valid?.should be_false
    end
    it "should require a user" do
      version = @item.versions.new(edited_at: Time.now)
      version.valid?.should be_false
    end
    it "should require an edited at datetime" do
      version = @item.versions.new
      version.user = @user
      version.valid?.should be_false
    end
  end

  # SCOPES

  describe "default_scope" do
    it "should keep the versions in order from oldest to newest" do
      Version.delete_all
      # create in reverse order just to make sure they’re getting sorted
      newest_version = FactoryGirl.create(:version, item: @item, user: @user, edited_at: 1.week.from_now)
      middle_version = FactoryGirl.create(:version, item: @item, user: @user, edited_at: 1.week.ago)
      oldest_version = FactoryGirl.create(:version, item: @item, user: @user, edited_at: 1.month.ago)
      # reload item to reload versions
      @item.reload
      @item.versions.should eq [oldest_version, middle_version, newest_version]
    end
  end

  describe ".versions_before" do
    it "should restrict searches to versions that occurred before a given datetime" do
      Version.delete_all
      first = FactoryGirl.create(:version, item: @item, user: @user, edited_at: 5.days.ago)
      second = FactoryGirl.create(:version, item: @item, user: @user, edited_at: 4.days.ago)
      FactoryGirl.create(:version, item: @item, user: @user, edited_at: 2.days.ago)
      FactoryGirl.create(:version, item: @item, user: @user, edited_at: 1.days.ago)
      @item.versions.versions_before(3.days.ago).should eq [first, second]
    end
  end

  describe ".versions_after" do
    it "should restrict searches to versions that occurred after a given datetime" do
      Version.delete_all
      FactoryGirl.create(:version, item: @item, user: @user, edited_at: 2.days.from_now)
      versions = []
      versions << FactoryGirl.create(:version, item: @item, user: @user, edited_at: 4.days.from_now)
      versions << FactoryGirl.create(:version, item: @item, user: @user, edited_at: 5.days.from_now)
      @item.versions.versions_after(3.days.from_now).should eq versions
    end
  end

  describe ".current_versions" do
    it "should restrict searches to the current versions for each item" do
      item_version = FactoryGirl.create(:version, item: @item, user: @user, edited_at: 70.days.from_now)
      second_item = FactoryGirl.create(:event)
      second_version = FactoryGirl.create(:version, item: second_item, edited_at: 1.days.from_now)
      Version.current_versions.should eq [second_version, item_version]
    end
  end

  # METHODS

  describe ".first_versions" do
    it "should restrict searches to the first versions for each item" do
      # FIXME: I haven’t figured out why the grouping scope only selects the latest, ignoring order
    end
  end

  describe "#previous" do
    before(:all) do
      Version.delete_all
      @first_version = FactoryGirl.create(:version, item: @item, user: @user, edited_at: 2.weeks.ago)
      @second_version = FactoryGirl.create(:version, item: @item, user: @user, edited_at: 2.weeks.ago)
      @third_version = FactoryGirl.create(:version, item: @item, user: @user, edited_at: 1.week.ago)
      @last_version = FactoryGirl.create(:version, item: @item, user: @user, edited_at: 1.day.ago)
    end
    it "should return nothing if this is the first version" do
      @first_version.previous.should be_nil
    end
    it "should return the first version if this is the second" do
      @second_version.previous.should eq @first_version
    end
    it "should return the previous version when this version is in the middle" do
      @third_version.previous.should eq @second_version
    end
    it "should return the previous version when this version is the last of many" do
      @last_version.previous.should eq @third_version
    end
  end

  describe "#current" do
    it "should return the most recent edit on the version’s item" do
      version = FactoryGirl.create(:version, item: @item, user: @user, edited_at: 2.years.ago)
      version.current.should == @item.versions.last
    end
  end

  describe "#is_current?" do
    it "should be true if this is the only version" do
      item = FactoryGirl.create(:event)
      item.versions[0].is_current?.should be_true
    end
    it "should be true if this is the latest version" do
      Version.delete_all
      version = FactoryGirl.create(:version, item: @item, user: @user, edited_at: 1.year.from_now)
      # create an additional, earlier, version to make sure we’re ordering by date properly
      FactoryGirl.create(:version, item: @item, user: @user, edited_at: 1.day.ago)
      @item.reload
      version.is_current?.should be_true
    end
    it "should be false if this is not the latest version" do
      FactoryGirl.create(:version, item: @item, user: @user, edited_at: 2.weeks.ago)
      FactoryGirl.create(:version, item: @item, user: @user, edited_at: 1.week.from_now)
      middle_version = FactoryGirl.create(:version, item: @item, user: @user, edited_at: 6.days.from_now)
      middle_version.is_current?.should be_false
    end
  end

end
