require 'rails_helper'

# For testing purposes, currently relying on the following models:
# - Authentication as a model that is not using authority control
NO_AUTHORITY_CLASS = Authentication
# - User as an authority controlled model where all records are restricted from view
PRIVATE_AUTHORITY_CLASS = User
# - Page as an authority controlled model where the viewability of records is individually flagged
SELECTIVE_AUTHORITY_CLASS = Page
# - Path as an authority controlled model that inherits authorities from another model (Page)
INHERITED_AUTHORITY_CLASS = Path

# Reopen User class to test handling of duplicate calls to acts_as_authority_controlled
class User < ActiveRecord::Base
  acts_as_authority_controlled item_authority_flag_field: :always_private
  acts_as_authority_controlled item_authority_flag_field: :always_private
end


# Ideally, these tests would use one-off classes to test the application of authority controlled functions.
# However, ActiveRecord hits the database and custom sub-classes would have to have matching tables
# in the database, unless I figure out how to stub out all the applicable parts of ActiveRecord.

describe "authority_controlled extensions to ActiveRecord::Base" do
  before(:all) do
    Authentication.delete_all
  end

  describe ".authority_area" do
    it "should default to the class name for ActiveRecord models that are not set as authority_controlled" do
      expect(NO_AUTHORITY_CLASS.authority_area).to eq NO_AUTHORITY_CLASS.name
    end
  end
  describe "#is_authority_restricted?" do
    it "should be false for ActiveRecord models that are not set as authority_controlled" do
      expect(NO_AUTHORITY_CLASS.new.is_authority_restricted?).to be_falsey
    end
  end
  describe "#has_authority_for_user_to?" do
    it "should allow viewing for models that are not set as authority_controlled" do
      expect(NO_AUTHORITY_CLASS.new.has_authority_for_user_to?).to be_truthy
    end
    it 'should not allow unauthorized users to change models that are not set as authority_controlled' do
      expect(NO_AUTHORITY_CLASS.new.has_authority_for_user_to?(nil, :can_update)).to be_falsey
    end
    it "should refer to authority_area authorities for change actions when not set as authority_controlled" do
      item = FactoryGirl.create(:authority, area: 'test')
      user = FactoryGirl.create(:user)
      a = FactoryGirl.create(:authority, user: user, area: 'Authority', can_update: true)
      expect(item.has_authority_for_user_to?(user, :can_update)).to be_truthy
    end
    it "should fall back to global authorities for change actions when not set as authority_controlled" do
      item = FactoryGirl.create(:authority, area: 'test')
      user = FactoryGirl.create(:user)
      a = FactoryGirl.create(:authority, user: user, area: 'global', can_update: true)
      expect(item.has_authority_for_user_to?(user, :can_update)).to be_truthy
    end
  end
  describe ".allowed_for_user" do
    describe "nil user, :can_view" do
      it "should return all items for models that are not authority_controlled" do
        # create a couple of authentications so the search will have something to find
        FactoryGirl.create_list(:authentication, 2)
        expect(NO_AUTHORITY_CLASS.allowed_for_user(nil, :can_view).size).to eq 2
      end
      it "should return non-flagged items for models that are selectively authority_controlled" do
        # create a couple of pages so the search will have something to find
        Page.delete_all
        Path.delete_all
        FactoryGirl.create(:page)
        FactoryGirl.create(:page, is_authority_controlled: true)
        expect(SELECTIVE_AUTHORITY_CLASS.allowed_for_user(nil, :can_view).size).to eq 1
      end
      it "should return no items for models that are all private authority_controlled" do
        # create a couple of users so the search will have something to find
        FactoryGirl.create_list(:user, 2)
        expect(PRIVATE_AUTHORITY_CLASS.allowed_for_user(nil, :can_view).size).to eq 0
      end
    end
    describe "nil user, non-view action" do
      it "should return no items for models that are not authority_controlled" do
        FactoryGirl.create(:authentication)
        expect(NO_AUTHORITY_CLASS.allowed_for_user(nil, :can_update).size).to eq 0
      end
      it "should return no items for models that are authority_controlled" do
        FactoryGirl.create(:page)
        expect(SELECTIVE_AUTHORITY_CLASS.allowed_for_user(nil, :can_update).size).to eq 0
      end
    end
    describe "authorized user" do
      it "should return all items user has authority for" do
        Page.delete_all
        Path.delete_all
        FactoryGirl.create(:page, is_authority_controlled: true)
        page = FactoryGirl.create(:page, is_authority_controlled: true)
        user = FactoryGirl.create(:authority, item: page, can_update: true).user
        expect(SELECTIVE_AUTHORITY_CLASS.allowed_for_user(user, :can_update).size).to eq 1
      end
      it "should return all items user has authority for for non-authority-controlled models" do
        auth = FactoryGirl.create(:authentication)
        user = FactoryGirl.create(:authority, item: auth, can_update: true).user
        expect(NO_AUTHORITY_CLASS.allowed_for_user(user, :can_update).size).to eq 1
      end
    end
  end
end

describe "acts_as_authority_controlled" do
  describe "item_authority_flag_field" do
    it "should, when field is set to false, require authority for all records to be viewed" do
      expect(PRIVATE_AUTHORITY_CLASS.new.is_authority_restricted?).to be_truthy
    end
    it "should, when using the default, restrict viewing records when the flag is set" do
      expect(SELECTIVE_AUTHORITY_CLASS.new(is_authority_controlled: true).is_authority_restricted?).to be_truthy
    end
    it "should, when using the default, allow viewing records when the flag is not set" do
      expect(SELECTIVE_AUTHORITY_CLASS.new.is_authority_restricted?).to be_falsey
    end
    it "should, when set to a custom field, use the custom field for the flag" do
      #pending
    end
  end

  it "should not allow a class to be assigned to the ‘global’ authority_area" do
    expect {
      class TestAuthorityControlledCannotBeGlobal < ActiveRecord::Base
        acts_as_authority_controlled authority_area: 'global', item_authority_flag_field: :always_private
      end
    }.to raise_exception(Wayground::ModelAuthorityAreaCannotBeGlobal)
  end
  it "should allow a class to be assigned to a custom authority_area" do
    class TestAuthorityControlledCustomArea < ActiveRecord::Base
      acts_as_authority_controlled authority_area: 'Custom Area', item_authority_flag_field: :always_private
    end
    expect(TestAuthorityControlledCustomArea.authority_area).to eq 'Custom Area'
  end
end

describe "authority_controlled class" do
  describe "has_many authorities" do
  end
  describe "#is_authority_restricted?" do
    it "should be true for ActiveRecord models that are set as authority_controlled and always private" do
      expect(PRIVATE_AUTHORITY_CLASS.new.is_authority_restricted?).to be_truthy
    end
    it "should default to false for models that are set as authority_controlled but item is not flagged" do
      expect(SELECTIVE_AUTHORITY_CLASS.new.is_authority_restricted?).to be_falsey
    end
    it "should be true for models that are set as authority_controlled and item is flagged" do
      item = SELECTIVE_AUTHORITY_CLASS.new
      item.is_authority_controlled = true
      expect(item.is_authority_restricted?).to be_truthy
    end
  end
  describe "#set_authority_for!" do
    it "should assign access to a user for an item" do
      item = FactoryGirl.create(:user)
      new_accessor = FactoryGirl.create(:user)
      expect(item.has_authority_for_user_to?(new_accessor, :can_view)).to be_falsey
      item.set_authority_for!(new_accessor, :can_view)
      expect(item.has_authority_for_user_to?(new_accessor, :can_view)).to be_truthy
    end
    it "should extend an existing authority" do
      item = FactoryGirl.create(:user)
      user = FactoryGirl.create(:user)
      FactoryGirl.create(:authority, user: user, item: item, can_update: true)
      item.set_authority_for!(user, :can_delete)
      authority = item.has_authority_for_user_to?(user, :can_delete)
      expect((authority.can_update && authority.can_delete)).to be_truthy
    end
  end
  describe ".authority_area" do
    it "should be the class name by default" do
      expect(PRIVATE_AUTHORITY_CLASS.authority_area).to eq PRIVATE_AUTHORITY_CLASS.name
    end
    it "should be the parent item’s authority_area on an inherited authority controlled class" do
      expect(Path.authority_area).to eq Page.authority_area
    end
  end
  describe "#authority_area" do
    it "should match the class method" do
      expect(PRIVATE_AUTHORITY_CLASS.new.authority_area).to eq PRIVATE_AUTHORITY_CLASS.name
    end
  end
  describe ".allowed_for_user" do
    describe "nil user, :can_view" do
      it "should return non-flagged items for models that are selectively authority_controlled" do
      end
      it "should return no items for models that are all private authority_controlled" do
      end
    end
    describe "nil user, non-view action" do
      it "should return no items" do
      end
    end
    describe "authorized user" do
      it "should return all items user has authority for" do
      end
    end
  end
  describe "#has_authority_for_user_to?" do
    before(:all) do
      @item = FactoryGirl.create(:user)
      @owner = FactoryGirl.create(:user)
      @viewer = FactoryGirl.create(:user)
      FactoryGirl.create(:authority, user: @owner, item: @item, is_owner: true)
      FactoryGirl.create(:authority, user: @viewer, item: @item, can_view: true)
    end
    it "should have authority for the owner" do
      expect(@item.has_authority_for_user_to?(@owner, :can_update)).to be_truthy
    end
    it "should have authority for a viewer" do
      expect(@item.has_authority_for_user_to?(@viewer)).to be_truthy
    end
    it "should not allow a viewer to update" do
      expect(@item.has_authority_for_user_to?(@viewer, :can_update)).to be_falsey
    end
    it "should not allow an unauthorized user" do
      unauthorized = FactoryGirl.create(:user)
      expect(@item.has_authority_for_user_to?(unauthorized)).to be_falsey
    end
  end
end

describe "inherited authority model" do
  describe "#set_authority_for!" do
    it "should raise an error" do
      expect {
        INHERITED_AUTHORITY_CLASS.new.set_authority_for!(User.new, :can_view)
      }.to raise_exception(Wayground::WrongModelForSettingAuthority)
    end
  end
  describe "#has_authority_for_user_to?" do
    it "should allow viewing of non-restricted items" do
    end
    it "should allow authorized users to access restricted items" do
    end
    it "should not allow unauthorized users to access restricted items" do
    end
    it "should allow area-authorized users access when no item to inherit from" do
      # ensure there's an existing admin user
      FactoryGirl.create(:user) if User.count == 0
      # create our working user
      user = FactoryGirl.create(:user)
      user.set_authority_on_area(INHERITED_AUTHORITY_CLASS.authority_area, :can_update)
      item = INHERITED_AUTHORITY_CLASS.create!(sitepath: '/spec/authority/inherited/no_item', redirect: '/')
      expect(item.has_authority_for_user_to?(user, :can_update)).to be_truthy
      expect(item.has_authority_for_user_to?(user, :can_delete)).to be_falsey
    end
  end
end
