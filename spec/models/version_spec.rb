require 'rails_helper'

describe Version, type: :model do

  before(:all) do
    Version.delete_all
    Page.delete_all
    User.delete_all
    @item = FactoryGirl.create(:page)
    @event = FactoryGirl.create(:event)
    @user = FactoryGirl.create(:user)
  end

  describe "validation" do
    it "should pass when all required fields are set" do
      version = @item.versions.new(edited_at: Time.now)
      version.user = @user
      expect( version.valid? ).to be_truthy
    end
    it "should require an item" do
      version = Version.new(edited_at: Time.now)
      version.user = @user
      expect( version.valid? ).to be_falsey
    end
    it "should require a user" do
      version = @item.versions.new(edited_at: Time.now)
      expect( version.valid? ).to be_falsey
    end
    it "should require an edited at datetime" do
      version = @item.versions.new
      version.user = @user
      expect( version.valid? ).to be_falsey
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
      expect( @item.versions ).to eq [oldest_version, middle_version, newest_version]
    end
  end

  describe ".versions_before" do
    it "should restrict searches to versions that occurred before a given datetime" do
      Version.delete_all
      first = FactoryGirl.create(:version, item: @item, user: @user, edited_at: 5.days.ago)
      second = FactoryGirl.create(:version, item: @item, user: @user, edited_at: 4.days.ago)
      FactoryGirl.create(:version, item: @item, user: @user, edited_at: 2.days.ago)
      FactoryGirl.create(:version, item: @item, user: @user, edited_at: 1.days.ago)
      expect( @item.versions.versions_before(3.days.ago) ).to eq [first, second]
    end
  end

  describe ".versions_after" do
    it "should restrict searches to versions that occurred after a given datetime" do
      Version.delete_all
      FactoryGirl.create(:version, item: @item, user: @user, edited_at: 2.days.from_now)
      versions = []
      versions << FactoryGirl.create(:version, item: @item, user: @user, edited_at: 4.days.from_now)
      versions << FactoryGirl.create(:version, item: @item, user: @user, edited_at: 5.days.from_now)
      expect( @item.versions.versions_after(3.days.from_now) ).to eq versions
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
      expect( @first_version.previous ).to be_nil
    end
    it "should return the first version if this is the second" do
      expect( @second_version.previous ).to eq @first_version
    end
    it "should return the previous version when this version is in the middle" do
      expect( @third_version.previous ).to eq @second_version
    end
    it "should return the previous version when this version is the last of many" do
      expect( @last_version.previous ).to eq @third_version
    end
  end

  describe "#current" do
    it "should return the most recent edit on the version’s item" do
      version = FactoryGirl.create(:version, item: @item, user: @user, edited_at: 2.years.ago)
      expect( version.current ).to eq @item.versions.last
    end
  end

  describe "#is_current?" do
    it "should be true if this is the only version" do
      item = FactoryGirl.create(:event)
      expect( item.versions[0].is_current? ).to be_truthy
    end
    it "should be true if this is the latest version" do
      Version.delete_all
      version = FactoryGirl.create(:version, item: @item, user: @user, edited_at: 1.year.from_now)
      # create an additional, earlier, version to make sure we’re ordering by date properly
      FactoryGirl.create(:version, item: @item, user: @user, edited_at: 1.day.ago)
      @item.reload
      expect( version.is_current? ).to be_truthy
    end
    it "should be false if this is not the latest version" do
      FactoryGirl.create(:version, item: @item, user: @user, edited_at: 2.weeks.ago)
      FactoryGirl.create(:version, item: @item, user: @user, edited_at: 1.week.from_now)
      middle_version = FactoryGirl.create(:version, item: @item, user: @user, edited_at: 6.days.from_now)
      expect( middle_version.is_current? ).to be_falsey
    end
  end

  describe '#diff_with' do
    it 'should return an empty hash when no difference' do
      @event.editor = @user
      version_old = @event.new_version
      version_new = @event.new_version
      expect( version_old.diff_with(version_new) ).to eq({})
    end
    it 'should set the filename to the new filename in the diff when filenames differ' do
      @event.editor = @user
      version_old = @event.new_version
      version_new = @event.new_version
      version_new.filename = 'different'
      expect( version_old.diff_with(version_new) ).to eq('filename' => 'different')
    end
    it 'should set the title to the new title in the diff when titles differ' do
      @event.editor = @user
      version_old = @event.new_version
      version_new = @event.new_version
      version_new.title = 'different'
      expect( version_old.diff_with(version_new) ).to eq('title' => 'different')
    end
    it 'should set the different values' do
      @event.editor = @user
      version_old = @event.new_version
      version_new = @event.new_version
      version_new.values.delete('city')
      version_new.values['city'] = 'Diffville'
      version_new.values.delete('province')
      version_new.values['province'] = 'Difference'
      version_new.values.delete('country')
      version_new.values['country'] = 'Diffland'
      diff = version_old.diff_with(version_new)
      expect( diff ).to eq('city' => 'Diffville', 'province' => 'Difference', 'country' => 'Diffland')
    end
    it 'should handle values with keys that are strings or symbols' do
      # FIXME: this test example seems to be broken (seed 31045)
      @event.editor = @user
      version_old = @event.new_version
      version_new = @event.new_version
      version_old.values.delete('city')
      version_old.values[:city] = 'Diffville'
      version_new.values.delete(:city)
      version_new.values['city'] = 'Diffville'
      diff = version_old.diff_with(version_new)
      expect( diff ).to eq({})
    end
  end

end
