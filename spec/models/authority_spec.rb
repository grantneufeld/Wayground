# encoding: utf-8

require 'spec_helper'

describe Authority do
  before(:each) do
    @user = stub_model(User,
    :id => 1,
    :email => 'test+user@wayground.ca')
    @valid_attributes = {
      :item_id => nil,
      :item_type => nil,
      :area => "global",
      :is_owner => false,
      :can_create => false,
      :can_view => false,
      :can_edit => false,
      :can_delete => false,
      :can_invite => false,
      :can_permit => false
    }
  end
  describe "validations" do
    it "should create a new instance given valid attributes" do
      a = Authority.new(@valid_attributes)
      a.user = @user
      a.save.should be_true
    end
    it "should require a user" do
      a = Authority.new(@valid_attributes)
      a.valid?.should be_false
    end
    it "should require either an item or an area" do
      invalid_attrs = @valid_attributes.dup
      invalid_attrs[:area] = nil
      a = Authority.new(invalid_attrs)
      a.user = @user
      a.valid?.should be_false
    end
  end
  describe "#authority_area" do
    it "should be in the “Authority” area" do
      Authority.new.authority_area.should eq "Authority"
    end
  end
end
