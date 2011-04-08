# encoding: utf-8
require 'spec_helper'

# For testing purposes, currently relying on the following models:
# - Authentication as a model that is not using authority control
# - User as an authority controlled model where all records are restricted from view
# - ? as an authority controlled model where the viewability of records is individually flagged

# Ideally, these tests would use one-off classes to test the application of authority controlled functions.
# However, ActiveRecord hits the database and custom sub-classes would have to have matching tables
# in the database, unless I figure out how to stub out all the applicable parts of ActiveRecord.

describe "authority_controlled extensions to ActiveRecord::Base" do
  describe ".authority_area" do
    it "should default to the class name for ActiveRecord models that are not set as authority_controlled" do
      Authentication.authority_area.should eq "Authentication"
    end
  end
  describe ".is_authority_restricted?" do
    it "should be false for ActiveRecord models that are not set as authority_controlled" do
      Authority.new.is_authority_restricted?.should be_false
    end
    it "should be true for ActiveRecord models that are set as authority_controlled and always private" do
      User.new.is_authority_restricted?.should be_true
    end
    # TODO: when there's such a class (such as Page)
    #it "should default to false for models that are set as authority_controlled but not flagged" do
    #   Page.new.is_authority_restricted?.should be_false
    #end
    #it "should be true for models that are set as authority_controlled and flagged" do
    #   item = Page.new.is_authority_controlled = true
    #   item.is_authority_restricted?.should be_true
    #end
  end
  describe ".has_authority_to?" do
    it "should allow viewing for models that are not set as authority_controlled" do
      Authority.new.has_authority_to?.should be_true
    end
    it "should not allow users to change models that are not set as authority_controlled, without authority" do
      Authority.new.has_authority_to?(nil, :can_edit).should be_false
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
end

describe "acts_as_authority_controlled" do
  describe "item_authority_flag_field" do
    it "should, when field is set to false, require authority for all records to be viewed" do
      User.new.is_authority_restricted?.should be_true
    end
    it "should, when using the default, restrict viewing records when the flag is set" do
    end
    it "should, when using the default, allow viewing records when the flag is not set" do
    end
    it "should, when set to a custom field, use the custom field for the flag" do
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
  describe "#authority_area" do
    it "should be the class name by default" do
      User.authority_area.should eq 'User'
    end
  end
  describe ".authority_area" do
    it "should match the class method" do
      User.new.authority_area.should eq 'User'
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
    it "should allow anyone to view a non-controlled item" do
      Authority.new.has_authority_to?(nil, :can_view).should be_true
      # TODO: “FlaggedClass”.new.has_authority_to?(nil, :can_view).should be_true
    end
  end
end
