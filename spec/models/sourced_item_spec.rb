require 'spec_helper'

describe SourcedItem, type: :model do
  before(:all) do
    Authority.delete_all
    User.destroy_all
    # first user is automatically an admin
    @user_admin = FactoryGirl.create(:user, :name => 'Admin User')
    @user_normal = FactoryGirl.create(:user, :name => 'Normal User')
  end

  let(:source) { $source = FactoryGirl.create(:source) }
  let(:item) { $item = FactoryGirl.create(:event) }
  let(:minimum_valid_params) {
    $minimum_valid_params = { last_sourced_at: 1.day.ago }
  }

  describe "attr_accessible" do
    it "should not allow source to be set" do
      expect {
        SourcedItem.new(:source => Project.new)
      }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should not allow source_id to be set" do
      expect {
        SourcedItem.new(:source_id => '1')
      }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should not allow item to be set" do
      expect {
        SourcedItem.new(:item => Project.new)
      }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should not allow item_type to be set" do
      expect {
        SourcedItem.new(:item_type => 'Event')
      }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should not allow item_id to be set" do
      expect {
        SourcedItem.new(:item_id => '1')
      }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should not allow datastore to be set" do
      expect {
        SourcedItem.new(:datastore => Datastore.new)
      }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should not allow datastore_id to be set" do
      expect {
        SourcedItem.new(:datastore_id => '1')
      }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should allow source_identifier to be set" do
      SourcedItem.new(:source_identifier => 'Test').source_identifier.should eq 'Test'
    end
    it "should allow last_sourced_at to be set" do
      sourced_item = SourcedItem.new(:last_sourced_at => '2012-06-07 08:09:10')
      sourced_item.last_sourced_at?.should be_truthy
    end
    it "should allow has_local_modifications to be set" do
      sourced_item = SourcedItem.new(:has_local_modifications => true)
      sourced_item.has_local_modifications.should be_truthy
    end
  end

  describe "validation" do
    it "should pass with minimum valid parameters" do
      si = source.sourced_items.new(minimum_valid_params)
      si.item = item
      si.valid?.should be_truthy
    end
    describe "of source" do
      it "should fail if not set" do
        si = SourcedItem.new(minimum_valid_params)
        si.item = item
        si.valid?.should be_falsey
      end
    end
    describe "of item" do
      it "should fail if not set" do
        si = source.sourced_items.new(minimum_valid_params)
        si.valid?.should be_falsey
      end
    end
    describe "of last_sourced_at" do
      it "should fail if greater than the source’s time" do
        si = source.sourced_items.new(minimum_valid_params)
        si.item = item
        si.source.last_updated_at = Time.now
        si.last_sourced_at = 1.minute.from_now
        si.valid?.should be_falsey
      end
      it "should pass if equal to the current time" do
        si = source.sourced_items.new(minimum_valid_params)
        si.item = item
        si.last_sourced_at = 0.minutes.ago
        si.source.last_updated_at = Time.now
        si.valid?.should be_truthy
      end
    end
  end

  describe "#set_date" do
    it "should be called before validation of a new sourced item" do
      si = SourcedItem.new
      si.valid?
      si.last_sourced_at?.should be_truthy
    end
    it "should not change last_sourced_at if already set" do
      time = 1.day.ago
      si = SourcedItem.new(last_sourced_at: time)
      si.set_date
      si.last_sourced_at.should eq time
    end
  end

  describe "#modified_locally" do
    it "should set has_local_modifications to true" do
      si = source.sourced_items.new(minimum_valid_params)
      si.modified_locally
      si.has_local_modifications?.should be_truthy
    end
    it "should not save the sourced item" do
      si = source.sourced_items.new(minimum_valid_params)
      si.modified_locally
      si.changed?.should be_truthy
    end
  end

  describe "#modified_locally!" do
    it "should set has_local_modifications to true" do
      si = source.sourced_items.new(minimum_valid_params)
      si.item = item
      si.modified_locally!
      si.has_local_modifications?.should be_truthy
    end
    it "should save the sourced item" do
      si = source.sourced_items.new(minimum_valid_params)
      si.item = item
      si.modified_locally!
      si.changed?.should be_falsey
    end
  end

end
