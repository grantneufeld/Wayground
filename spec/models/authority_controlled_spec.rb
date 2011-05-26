# encoding: utf-8
require 'spec_helper'

# For testing purposes, currently relying on the following models:
# - Authentication as a model that is not using authority control
NO_AUTHORITY_CLASS = Authentication
# - User as an authority controlled model where all records are restricted from view
PRIVATE_AUTHORITY_CLASS = User
# - Page as an authority controlled model where the viewability of records is individually flagged
SELECTIVE_AUTHORITY_CLASS = Page
# - Path as an authority controlled model that inherits authorities from another model (Page)
INHERITED_AUTHORITY_CLASS = Path

# Ideally, these tests would use one-off classes to test the application of authority controlled functions.
# However, ActiveRecord hits the database and custom sub-classes would have to have matching tables
# in the database, unless I figure out how to stub out all the applicable parts of ActiveRecord.

describe "authority_controlled extensions to ActiveRecord::Base" do
  describe ".authority_area" do
    it "should default to the class name for ActiveRecord models that are not set as authority_controlled" do
      NO_AUTHORITY_CLASS.authority_area.should eq NO_AUTHORITY_CLASS.name
    end
  end
  describe "#is_authority_restricted?" do
    it "should be false for ActiveRecord models that are not set as authority_controlled" do
      NO_AUTHORITY_CLASS.new.is_authority_restricted?.should be_false
    end
  end
  describe "#has_authority_to?" do
    it "should allow viewing for models that are not set as authority_controlled" do
      NO_AUTHORITY_CLASS.new.has_authority_to?.should be_true
    end
    it "should not allow users to change models that are not set as authority_controlled, without authority" do
      NO_AUTHORITY_CLASS.new.has_authority_to?(nil, :can_edit).should be_false
    end
    it "should refer to authority_area authorities for change actions when not set as authority_controlled" do
      item = Factory.create(:authority, :area => 'test')
      user = Factory.create(:user)
      a = Factory.create(:authority, :user => user, :area => 'Authority', :can_edit => true)
      item.has_authority_to?(user, :can_edit).should be_true
    end
    it "should fall back to global authorities for change actions when not set as authority_controlled" do
      item = Factory.create(:authority, :area => 'test')
      user = Factory.create(:user)
      a = Factory.create(:authority, :user => user, :area => 'global', :can_edit => true)
      item.has_authority_to?(user, :can_edit).should be_true
    end
  end
  describe ".allowed_for_user" do
    describe "nil user, :can_view" do
      it "should return all items for models that are not authority_controlled" do
        # create a couple of authentications so the search will have something to find
        Factory.create(:authentication)
        Factory.create(:authentication)
        NO_AUTHORITY_CLASS.allowed_for_user(nil, :can_view).size.should eq 2
      end
      it "should return non-flagged items for models that are selectively authority_controlled" do
        # create a couple of pages so the search will have something to find
        Page.delete_all
        Path.delete_all
        Factory.create(:page)
        Factory.create(:page, :is_authority_controlled => true)
        SELECTIVE_AUTHORITY_CLASS.allowed_for_user(nil, :can_view).size.should eq 1
      end
      it "should return no items for models that are all private authority_controlled" do
        # create a couple of users so the search will have something to find
        Factory.create(:user)
        Factory.create(:user)
        PRIVATE_AUTHORITY_CLASS.allowed_for_user(nil, :can_view).size.should eq 0
      end
    end
    describe "nil user, non-view action" do
      it "should return no items for models that are not authority_controlled" do
        Factory.create(:authentication)
        NO_AUTHORITY_CLASS.allowed_for_user(nil, :can_edit).size.should eq 0
      end
      it "should return no items for models that are authority_controlled" do
        Factory.create(:page)
        SELECTIVE_AUTHORITY_CLASS.allowed_for_user(nil, :can_edit).size.should eq 0
      end
    end
    describe "authorized user" do
      it "should return all items user has authority for" do
        Page.delete_all
        Path.delete_all
        Factory.create(:page, :is_authority_controlled => true)
        page = Factory.create(:page, :is_authority_controlled => true)
        user = Factory.create(:authority, :item => page, :can_edit => true).user
        SELECTIVE_AUTHORITY_CLASS.allowed_for_user(user, :can_edit).size.should eq 1
      end
      it "should return all items user has authority for for non-authority-controlled models" do
        auth = Factory.create(:authentication)
        user = Factory.create(:authority, :item => auth, :can_edit => true).user
        NO_AUTHORITY_CLASS.allowed_for_user(user, :can_edit).size.should eq 1
      end
    end
  end
end

describe "acts_as_authority_controlled" do
  describe "item_authority_flag_field" do
    it "should, when field is set to false, require authority for all records to be viewed" do
      PRIVATE_AUTHORITY_CLASS.new.is_authority_restricted?.should be_true
    end
    it "should, when using the default, restrict viewing records when the flag is set" do
      SELECTIVE_AUTHORITY_CLASS.new(:is_authority_controlled => true).is_authority_restricted?.should be_true
    end
    it "should, when using the default, allow viewing records when the flag is not set" do
      SELECTIVE_AUTHORITY_CLASS.new.is_authority_restricted?.should be_false
    end
    it "should, when set to a custom field, use the custom field for the flag" do
      #pending
    end
  end

  it "should not allow a class to be assigned to the ‘global’ authority_area" do
    expect {
      class TestAuthorityControlledCannotBeGlobal < ActiveRecord::Base
        acts_as_authority_controlled :authority_area => 'global', :item_authority_flag_field => :always_private
      end
    }.to raise_exception(Wayground::ModelAuthorityAreaCannotBeGlobal)
  end
  it "should allow a class to be assigned to a custom authority_area" do
    class TestAuthorityControlledCustomArea < ActiveRecord::Base
      acts_as_authority_controlled :authority_area => 'Custom Area', :item_authority_flag_field => :always_private
    end
    TestAuthorityControlledCustomArea.authority_area.should eq 'Custom Area'
  end
end

describe "authority_controlled class" do
  describe "has_many authorities" do
  end
  describe "#is_authority_restricted?" do
    it "should be true for ActiveRecord models that are set as authority_controlled and always private" do
      PRIVATE_AUTHORITY_CLASS.new.is_authority_restricted?.should be_true
    end
    it "should default to false for models that are set as authority_controlled but item is not flagged" do
      SELECTIVE_AUTHORITY_CLASS.new.is_authority_restricted?.should be_false
    end
    it "should be true for models that are set as authority_controlled and item is flagged" do
      item = SELECTIVE_AUTHORITY_CLASS.new
      item.is_authority_controlled = true
      item.is_authority_restricted?.should be_true
    end
  end
  describe "#set_authority_for!" do
    it "should assign access to a user for an item" do
      item = Factory.create(:user)
      new_accessor = Factory.create(:user)
      item.has_authority_to?(new_accessor, :can_view).should be_false
      item.set_authority_for!(new_accessor, :can_view)
      item.has_authority_to?(new_accessor, :can_view).should be_true
    end
    it "should extend an existing authority" do
      item = Factory.create(:user)
      user = Factory.create(:user)
      Factory.create(:authority, :user => user, :item => item, :can_edit => true)
      item.set_authority_for!(user, :can_delete)
      authority = item.has_authority_to?(user, :can_delete)
      (authority.can_edit && authority.can_delete).should be_true
    end
  end
  describe ".authority_area" do
    it "should be the class name by default" do
      PRIVATE_AUTHORITY_CLASS.authority_area.should eq PRIVATE_AUTHORITY_CLASS.name
    end
    it "should be the parent item’s authority_area on an inherited authority controlled class" do
      Path.authority_area.should eq Page.authority_area
    end
  end
  describe "#authority_area" do
    it "should match the class method" do
      PRIVATE_AUTHORITY_CLASS.new.authority_area.should eq PRIVATE_AUTHORITY_CLASS.name
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
  describe "#has_authority_to?" do
    before(:all) do
      @item = Factory.create(:user)
      @owner = Factory.create(:user)
      @viewer = Factory.create(:user)
      Factory.create(:authority, :user => @owner, :item => @item, :is_owner => true)
      Factory.create(:authority, :user => @viewer, :item => @item, :can_view => true)
    end
    it "should have authority for the owner" do
      @item.has_authority_to?(@owner, :can_edit).should be_true
    end
    it "should have authority for a viewer" do
      @item.has_authority_to?(@viewer).should be_true
    end
    it "should not allow a viewer to edit" do
      @item.has_authority_to?(@viewer, :can_edit).should be_false
    end
    it "should not allow an unauthorized user" do
      unauthorized = Factory.create(:user)
      @item.has_authority_to?(unauthorized).should be_false
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
  describe "#has_authority_to?" do
    it "should allow viewing of non-restricted items" do
    end
    it "should allow authorized users to access restricted items" do
    end
    it "should not allow unauthorized users to access restricted items" do
    end
  end
end
