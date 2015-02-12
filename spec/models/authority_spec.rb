require 'spec_helper'
require 'authority'
require 'active_record'

describe Authority, type: :model do
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
        :can_update => false,
        :can_delete => false,
        :can_invite => false,
        :can_permit => false,
        :can_approve => false
      }
    end

    it "should create a new instance given valid attributes" do
      a = Authority.new(@valid_attributes)
      a.user = @valid_user
      a.save.should be_truthy
    end
    it "should require a user" do
      a = Authority.new(@valid_attributes)
      a.valid?.should be_falsey
    end
    it "should require either an item or an area" do
      invalid_attrs = @valid_attributes.dup
      invalid_attrs[:area] = nil
      a = Authority.new(invalid_attrs)
      a.user = @valid_user
      a.valid?.should be_falsey
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
      user = FactoryGirl.create(:user, name: 'authorize user')
      authorizer = FactoryGirl.create(:user, name: 'authorizing user')
      authority = Authority.build_from_params(
        authority_params: {user_proxy: user.email, area: 'Content'},
        authorized_by: authorizer
      )
      authority.user.should == user
    end
  end

  describe ".user_has_for_item" do
    before(:all) do
      @item1 = FactoryGirl.create(:page)
      @item2 = FactoryGirl.create(:page)
      @item_user = FactoryGirl.create(:user)
      # create a bunch of authorities
      FactoryGirl.create(:authority, {:user => @item_user, :item => @item1, :is_owner => true})
      FactoryGirl.create(:authority, {:user => @item_user, :item => @item2, :can_delete => true})
      FactoryGirl.create(:authority, {:user => @item_user, :area => 'Content', :can_update => true})
      FactoryGirl.create(:authority, {:user => @item_user, :area => 'global', :can_view => true})
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
      @proxy_user = FactoryGirl.create(:user)
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

  describe ".merge_into!" do
    let(:item) { $item = FactoryGirl.create(:event) }
    let(:user) { $user = FactoryGirl.create(:user) }
    let(:authority1) { $authority1 = FactoryGirl.create(:authority, item: item, user: user) }

    it "should reject anything for the destination authority that is not an Authority" do
      expect { authority1.merge_into!(:not_an_authority) }.to raise_error(TypeError)
    end

    it "should reject a destination authority that doesn’t have the same user" do
      authority2 = FactoryGirl.create(:authority, item: item)
      expect { authority1.merge_into!(authority2) }.to raise_error(Wayground::UserMismatch)
    end

    it "should logical-OR the boolean fields" do
      authority1.update(is_owner: true, can_delete: true)
      authority2 = FactoryGirl.create(:authority, user: user,
        item: FactoryGirl.create(:event), can_view: true, can_update: true
      )
      authority1.merge_into!(authority2)
      (
        ( # these fields should be true
          authority2.is_owner && authority2.can_delete &&
          authority2.can_update && authority2.can_update
        ) &&
        !( # these fields should be false
          authority2.can_create || authority2.can_invite ||
          authority2.can_permit || authority2.can_approve
        )
      ).should be_truthy
    end

    it "should save the changes to the destination authority" do
      authority1.is_owner = true
      authority2 = FactoryGirl.create(:authority, user: user,
        item: FactoryGirl.create(:event), can_view: true
      )
      authority1.merge_into!(authority2)
      authority2.changed?.should be_falsey # no unsaved changes
    end

    it "should destroy the source authority" do
      destroyed_id = authority1.id
      authority2 = FactoryGirl.create(:authority, user: user, item: item)
      authority1.merge_into!(authority2)
      expect {
        Authority.find(destroyed_id)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should not destroy the source authority if saving the destination fails" do
      authority2 = FactoryGirl.create(:authority, user: user, item: item)
      expect_any_instance_of(Authority).to receive(:save).and_return(false)
      authority1.merge_into!(authority2)
      Authority.find(authority1.id).should eq authority1
    end
  end

end
