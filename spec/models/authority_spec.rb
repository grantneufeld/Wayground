# encoding: utf-8

require 'spec_helper'

describe Authority do
  # == VALIDATIONS
  describe "validations" do
    before(:each) do
      @valid_user = stub_model(User,
        :id => 1,
        :email => 'test+user@wayground.ca'
      )
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

    it "should create a new instance given valid attributes" do
      a = Authority.new(@valid_attributes)
      a.user = @valid_user
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
      a.user = @valid_user
      a.valid?.should be_false
    end
  end


  # == SCOPES
  describe "scopes" do
    describe ":for_area" do
    end

    describe ":for_area_or_global" do
    end

    describe ":for_item" do
    end

    describe ":for_item_or_area" do
    end

    describe ":for_user" do
    end

    describe ":for_action" do
    end

    describe ":where_owner" do
    end
  end


  # == CLASS METHODS

  describe ".build_from_params" do
    it "should instantiate a new authorization if no user provided" do
    end
    it "should instantiate a new authorization on the provided user" do
      user = Factory.create(:user)
      authority = Authority.build_from_params({:user_proxy => user.email, :area => 'Content'})
      authority.user.should == user
    end
  end

  describe ".user_has_for_item" do
    before(:all) do
      @item1 = Factory.create(:page)
      @item2 = Factory.create(:page)
      @item_user = Factory.create(:user)
      # create a bunch of authorities
      Factory.create(:authority, {:user => @item_user, :item => @item1, :is_owner => true})
      Factory.create(:authority, {:user => @item_user, :item => @item2, :can_delete => true})
      Factory.create(:authority, {:user => @item_user, :area => 'Content', :can_edit => true})
      Factory.create(:authority, {:user => @item_user, :area => 'global', :can_view => true})
      #@item_user.reload
    end
    it "should return the user’s authority for the item when no action_type" do
      authorization = Authority.user_has_for_item(@item_user, @item2, nil)
      authorization.item.should == @item2
    end
    it "should pick an authority for the user as owner of the item over any other authority" do
    end
    it "should prefer an authority for the user on the item over the item area or global" do
    end
  end


  # == INSTANCE METHODS

  describe "#user_proxy" do
  end

  describe "#user_proxy=" do
    before(:all) do
      @proxy_user = Factory.create(:user)
    end
    it "should make the user nil if item is blank" do
        authority = Authority.new
        authority.user_proxy = ''
        authority.user.should be_nil
    end
    it "should assign the user if the item is a valid string identifier (id, email, name)" do
      authority = Authority.new
      authority.user_proxy = @proxy_user.email
      authority.user.should eq @proxy_user
    end
    it "should set the user if the item is a User instance" do
      authority = Authority.new
      authority.user_proxy = @proxy_user
      authority.user.should eq @proxy_user
    end
  end

  describe "#set_action!" do
  end


  # == Authority Controlled
  # from lib/authority_controlled as monkey-patched onto ActiveRecord:

  describe "#authority_area" do
    it "should be in the “Authority” area" do
      Authority.new.authority_area.should eq "Authority"
    end
  end
end
