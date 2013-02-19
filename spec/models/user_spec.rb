# encoding: utf-8
require 'spec_helper'
require 'user'
require 'authority'

describe User do
  def mock_auth(stubs = {})
    @mock_auth = mock_model(Authentication, stubs)
  end

  before(:all) do
    User.delete_all
    @admin = FactoryGirl.create(:user)
    @user = FactoryGirl.create(:user, email: 'test+user@wayground.ca')
    @bob = FactoryGirl.create(:user, {name: 'Bob', email: 'bob@bob.tld'})
    @item = FactoryGirl.create(:page)
  end

  describe "attr_accessible" do
    it "should allow timezone to be set" do
      tz_str = 'test timezone'
      user = User.new(timezone: tz_str)
      user.timezone.should eq tz_str
    end
  end

  describe "validations" do
    context "of password" do
      it "should fail if there is no password" do
        u = User.new
        u.email = 'test@wayground.ca'
        u.valid?.should be_false
      end
      it "should fail if the password is less than 8 characters long" do
        u = User.new
        u.email = 'test@wayground.ca'
        u.password_confirmation = u.password = '1234567'
        u.valid?.should be_false
      end
      it "should fail if the password is more than 63 characters long" do
        u = User.new
        u.email = 'test@wayground.ca'
        u.password_confirmation = u.password = 'a' * 64
        u.valid?.should be_false
      end
      it "should fail if there is no password confirmation" do
        u = User.new
        u.email = 'test@wayground.ca'
        u.password = 'password'
        u.valid?.should be_false
      end
      it "should fail if the password confirmation is blank" do
        u = User.new
        u.email = 'test@wayground.ca'
        u.password = 'password'
        u.password_confirmation = ''
        u.valid?.should be_false
      end
      it "should fail if the password confirmation does not match" do
        u = User.new
        u.email = 'test@wayground.ca'
        u.password = 'password'
        u.password_confirmation = 'missmatch'
        u.valid?.should be_false
      end
      it "should fail if there is no email address" do
        u = User.new
        u.password_confirmation = u.password = 'password'
        u.valid?.should be_false
      end
      it "should fail if the email address is not a proper email address" do
        u = User.new
        u.email = 'invalid@bad-email'
        u.password_confirmation = u.password = 'password'
        u.valid?.should be_false
      end
      it "should fail if there is already a user registered with the same email address" do
        u = User.new
        u.email = 'test+duplicate@wayground.ca'
        u.password_confirmation = u.password = 'password'
        u.save!
        u2 = User.new
        u2.email = 'test+duplicate@wayground.ca'
        u2.password_confirmation = u2.password = 'another1'
        u2.valid?.should be_false
      end
      it "should fail if there is already a user registered with the same email address but different case" do
        u = User.new
        u.email = 'test+duplicate@wayground.ca'
        u.password_confirmation = u.password = 'password'
        u.save!
        u2 = User.new
        u2.email = 'TEST+DUPLICATE@WAYGROUND.CA'
        u2.password_confirmation = u2.password = 'another1'
        u2.valid?.should be_false
      end
      it "should fail if invalid timezone specified" do
        User.new(email: 'test+validtimezone@wayground.ca',
          password: 'password', password_confirmation: 'password',
          timezone: 'invalid timezone'
        ).valid?.should be_false
      end
      it "should add a user record with valid parameters" do
        u = User.new
        u.email = 'test+good+parameters@wayground.ca'
        u.password_confirmation = u.password = 'password'
        u.save!
        User.find_by_email(u.email).should == u
      end
    end
    context "with authentications" do
      it "should validate when there is an authentication and no email/pass" do
        authentication = FactoryGirl.build(:authentication)
        user = authentication.user
        user.valid?.should be_true
      end
    end
    it "should fail to validate when no authentication and no email/pass" do
      user = User.new
      user.valid?.should be_false
    end
  end

  describe ".find_by_string" do
    it "should return nil given an empty string" do
      User.find_by_string('').should be_nil
    end
    it "should find matching id, given a numeric string" do
      User.find_by_string(@bob.id.to_s).should == @bob
    end
    it "should find matching email given an email string" do
      User.find_by_string('bob@bob.tld').should == @bob
    end
    it "should find matching name given an arbitrary string" do
      User.find_by_string('Bob').should == @bob
    end
  end

  describe ".main_admin" do
    it "should find the first admin" do
      User.main_admin.should eq @admin
    end
  end

  describe "#local_authentication_required?" do
  end

  describe "#password_present?" do
  end

  describe "#email_present?" do
  end

  describe "password=" do
    it "should save an encrypted version of a new user’s password" do
      user = User.new
      user.password = 'encrypt this password'
      expect( user.password_hash.present? ).to be_true
    end
    it "should be used in attribute mass assignment" do
      user = User.new(password: 'encrypt this password')
      expect( user.password_hash.present? ).to be_true
    end
  end

  describe ".login_name_attribute" do
    it "should return a label for the email field" do
      expect( User.login_name_attribute ).to eq :email
    end
  end

  describe "email code confirmation" do
    it "should generate a confirmation token when creating a new user" do
      @user.confirmation_token.blank?.should_not be_true
    end
    it "should fail to confirm if the code parameter does not match the saved token" do
      @user.confirm_code!('invalid token').should be_false
    end
    it "should fail to confirm if the user’s email has already been confirmed" do
      @user.email_confirmed = true
      @user.confirm_code!(@user.confirmation_token).should be_false
      @user.email_confirmed = false
    end
    it "should successfully flag the user’s email as confirmed" do
      save_token = @user.confirmation_token
      @user.confirm_code!(@user.confirmation_token)
      @user.email_confirmed.should be_true
      @user.confirmation_token = save_token #restore
    end
    it "should clear the confirmation token when the user’s email is confirmed" do
      save_token = @user.confirmation_token
      @user.email_confirmed = false
      @user.confirm_code!(@user.confirmation_token)
      @user.confirmation_token.should be_nil
      @user.confirmation_token = save_token #restore
    end
  end

  # AUTHORITIES

  context "#admin?" do
    it "should be true for a user with global is_owner authority" do
      @user.make_admin!
      @user.admin?.should be_true
    end
    it "should not be true for a user with global, but not is_owner, authority" do
      Authority.where(user_id: @user.id).delete_all
      @user.set_authority_on_area('global', :can_view)
      @user.admin?.should_not be_true
    end
    it "should not be true for a regular user" do
      Authority.where(user_id: @user.id).delete_all
      @user.admin?.should_not be_true
    end
  end

  describe "#first_user_is_admin" do
    it "should create one authority for first user" do
      Authority.where(user_id: @user.id).delete_all
      User.stub(:count).and_return(1)
      expect { @user.first_user_is_admin }.to change(Authority, :count).by(1)
    end
    it "should do nothing if more than one user" do
      Authority.where(user_id: @user.id).delete_all
      User.stub(:count).and_return(2)
      expect { @user.first_user_is_admin }.to_not change(Authority, :count)
    end
  end

  describe "#make_admin!" do
    it "should upgrade a pre-existing global authority" do
      authority = FactoryGirl.create(:authority, {area: 'global'})
      user = authority.user
      user.make_admin!
      user.authorizations.for_area_or_global('global').for_action(:is_owner).first.should_not be_nil
    end
    it "should upgrade a pre-existing specific area authority" do
      authority = FactoryGirl.create(:authority, {area: 'Content'})
      user = authority.user
      user.make_admin!('Content')
      user.authorizations.for_area_or_global('Content').for_action(:is_owner).first.should_not be_nil
    end
    it "should not change the authorizing user when authorizing user not provided for a pre-existing authority" do
      authority = FactoryGirl.create(:authority, {area: 'global', authorized_by: @admin})
      user = authority.user
      user.make_admin!
      user.authorizations.for_area_or_global('global').for_action(:is_owner).first.authorized_by.should == @admin
    end
    it "should assign the authorizing user when provided for a pre-existing authority" do
      authority = FactoryGirl.create(:authority, {area: 'global', authorized_by: @admin})
      user = authority.user
      user.make_admin!('global', user)
      user.authorizations.for_area_or_global('global').for_action(:is_owner).first.authorized_by.should == user
    end
    it "should create a global admin Authority for a previously authority-less user" do
      user = FactoryGirl.create(:user)
      user.make_admin!()
      user.authorizations.for_area_or_global('global').for_action(:is_owner).first.should_not be_nil
    end
    it "should create an area-specific Authority for a user not previously authorized for a specific area" do
      user = FactoryGirl.create(:user)
      user.make_admin!('Content')
      user.authorizations.for_area_or_global('Content').for_action(:is_owner).first.should_not be_nil
    end
    it "should set the authorizing user to self when authorizing user not provided" do
      user = FactoryGirl.create(:user)
      user.make_admin!()
      user.authorizations.for_area_or_global('global').for_action(:is_owner).first.authorized_by.should == user
    end
    it "should change the authorizing user when provided" do
      user = FactoryGirl.create(:user)
      user.make_admin!('global', @admin)
      user.authorizations.for_area_or_global('global').for_action(:is_owner).first.authorized_by.should == @admin
    end
  end

  describe "#set_authority_on_area" do
    it "should create an authority" do
      user = FactoryGirl.create(:user)
      user.set_authority_on_area('global', :can_update)
      user.has_authority_for_area('global', :can_update).should be_true
    end
    it "should ammend an existing authority" do
      user = FactoryGirl.create(:user)
      authority = FactoryGirl.build(:authority, user: user, area: 'global', can_view: true)
      user.authorizations << authority
      user.save!
      user.set_authority_on_area('global', :can_update)
      authority = user.authorizations.for_area('global').first
      authority.can_view?.should be_true
      authority.can_update?.should be_true
    end
  end

  describe "#set_authority_on_item" do
    it "should create an authority" do
      Authority.where(user_id: @user.id).delete_all
      @user.set_authority_on_item(@item, :can_update)
      @item.has_authority_for_user_to?(@user, :can_update).should be_true
    end
    it "should ammend an existing authority" do
      authority = FactoryGirl.build(:authority, user: @user, item: @item, can_view: true)
      @user.authorizations << authority
      @user.save!
      @user.set_authority_on_item(@item, :can_update)
      authority = @user.authorizations.for_item(@item).first
      authority.can_view?.should be_true
      authority.can_update?.should be_true
    end
  end

  describe "#has_authority_for_area" do
    before(:all) do
      Authority.where(user_id: @user.id).delete_all
      @auth_content = FactoryGirl.create(:authority, {user: @user, area: 'Content', is_owner: true})
      @auth_user = FactoryGirl.create(:authority, {user: @user, area: 'User', can_update: true})
      @auth_global = FactoryGirl.create(:authority, {user: @user, area: 'global', can_view: true})
    end
    it "should default to the view authority for the area" do
      @user.has_authority_for_area('global').should == @auth_global
    end
    it "should return the authority for the area if the action is set to nil" do
      @user.has_authority_for_area('User', nil).should == @auth_user
    end
    it "should return the authority for the area if the user is the owner" do
      @user.has_authority_for_area('Content', :is_owner).should == @auth_content
      @user.has_authority_for_area('Content', :can_update).should == @auth_content
    end
    it "should return the authority for the area if it authorizes the action" do
      @user.has_authority_for_area('User', :can_update).should == @auth_user
      @user.has_authority_for_area('global', :can_update).should be_nil
    end
    it "should return the global authority if there isn’t one for the specified area" do
      @user.has_authority_for_area('User', :can_view).should == @auth_global
    end
  end

end
