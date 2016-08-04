require 'rails_helper'

describe SourcedItem, type: :model do
  before(:all) do
    Authority.delete_all
    User.delete_all
    # first user is automatically an admin
    @user_admin = FactoryGirl.create(:user, :name => 'Admin User')
    @user_normal = FactoryGirl.create(:user, :name => 'Normal User')
  end

  let(:source) { $source = FactoryGirl.create(:source) }
  let(:item) { $item = FactoryGirl.create(:event) }
  let(:minimum_valid_params) {
    $minimum_valid_params = { last_sourced_at: 1.day.ago }
  }

  describe "validation" do
    it "should pass with minimum valid parameters" do
      si = source.sourced_items.build(minimum_valid_params)
      si.item = item
      expect(si.valid?).to be_truthy
    end
    describe "of source" do
      it "should fail if not set" do
        si = SourcedItem.new(minimum_valid_params)
        si.item = item
        expect(si.valid?).to be_falsey
      end
    end
    describe "of item" do
      context 'when is_ignored' do
        it 'should pass if not set' do
          si = source.sourced_items.new(minimum_valid_params)
          si.is_ignored = true
          expect(si.valid?).to be_truthy
        end
        it 'should fail if set' do
          si = source.sourced_items.new(minimum_valid_params)
          si.is_ignored = true
          si.item = item
          expect(si.valid?).to be_falsey
        end
      end
      context 'when not is_ignored' do
        it 'should fail if not set' do
          si = source.sourced_items.new(minimum_valid_params)
          si.is_ignored = false
          expect(si.valid?).to be_falsey
        end
        it 'should pass if set' do
          si = source.sourced_items.new(minimum_valid_params)
          si.is_ignored = false
          si.item = item
          expect(si.valid?).to be_truthy
        end
      end
    end
    describe "of last_sourced_at" do
      it "should fail if greater than the source’s time" do
        si = source.sourced_items.build(minimum_valid_params)
        si.item = item
        si.source.last_updated_at = Time.now
        si.last_sourced_at = 1.minute.from_now
        expect(si.valid?).to be_falsey
      end
      it "should pass if equal to the current time" do
        si = source.sourced_items.build(minimum_valid_params)
        si.item = item
        si.last_sourced_at = 0.minutes.ago
        si.source.last_updated_at = Time.now
        expect(si.valid?).to be_truthy
      end
    end
  end

  describe "#set_date" do
    it "should be called before validation of a new sourced item" do
      si = SourcedItem.new
      si.valid?
      expect(si.last_sourced_at?).to be_truthy
    end
    it "should not change last_sourced_at if already set" do
      time = 1.day.ago
      si = SourcedItem.new(last_sourced_at: time)
      si.set_date
      expect(si.last_sourced_at).to eq time
    end
  end

  describe "#modified_locally" do
    it "should set has_local_modifications to true" do
      si = source.sourced_items.build(minimum_valid_params)
      si.modified_locally
      expect(si.has_local_modifications?).to be_truthy
    end
    it "should not save the sourced item" do
      si = source.sourced_items.build(minimum_valid_params)
      si.modified_locally
      expect(si.changed?).to be_truthy
    end
  end

  describe "#modified_locally!" do
    it "should set has_local_modifications to true" do
      si = source.sourced_items.build(minimum_valid_params)
      si.item = item
      si.modified_locally!
      expect(si.has_local_modifications?).to be_truthy
    end
    it "should save the sourced item" do
      si = source.sourced_items.build(minimum_valid_params)
      si.item = item
      si.modified_locally!
      expect(si.changed?).to be_falsey
    end
  end

end
