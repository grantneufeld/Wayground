# encoding: utf-8
require 'spec_helper'

describe User do
  def mock_auth(stubs = {})
    @mock_auth = mock_model(Authentication, stubs)
  end

  describe "attr_accessible" do
    it "should allow timezone to be set" do
      tz_str = 'test timezone'
      user = User.new(:timezone => tz_str)
      user.timezone.should eq tz_str
    end
  end

  describe "validations without authentications" do
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
      User.new(:email => 'test+validtimezone@wayground.ca',
        :password => 'password', :password_confirmation => 'password',
        :timezone => 'invalid timezone'
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
  describe "validations with authentications" do
    it "should fail to validate when no authentication and no email/pass" do
      user = User.new
      user.valid?.should be_false
    end
    it "should validate when there is an authentication and no email/pass" do
      authentication = FactoryGirl.build(:authentication)
      user = authentication.user
      user.valid?.should be_true
    end
  end

  describe ".find_by_string" do
    before(:all) do
      User.delete_all
      FactoryGirl.create(:user)
      @user = FactoryGirl.create(:user, {:name => 'Bob', :email => 'bob@bob.tld'})
      FactoryGirl.create(:user)
    end
    it "should return nil given an empty string" do
      User.find_by_string('').should be_nil
    end
    it "should find matching id, given a numeric string" do
      User.find_by_string(@user.id.to_s).should == @user
    end
    it "should find matching email given an email string" do
      User.find_by_string('bob@bob.tld').should == @user
    end
    it "should find matching name given an arbitrary string" do
      User.find_by_string('Bob').should == @user
    end
  end

  describe "#local_authentication_required?" do
  end

  describe "#password_present?" do
  end

  describe "#email_present?" do
  end

  describe ".create_from_authentication!" do
    it "should create a new user with the authentication" do
      #authentication = mock_auth({:name => 'User From Auth', :email => 'test+fromauth@wayground.ca', :user= => nil, :to_ary => []})
      authentication = FactoryGirl.create(:authentication,
        {:name => 'User From Auth', :email => 'test+fromauth@wayground.ca'}
      )
      user = User.create_from_authentication!(authentication)
      user.valid?.should be_true
      user.name.should eq 'User From Auth'
      user.email.should eq 'test+fromauth@wayground.ca'
      user.authentications[0].should be authentication
    end
  end

  describe "password encryption" do
    before(:each) do
      @user = User.new
      @user.email = 'test+newuser@wayground.ca'
      @user.password_confirmation = @user.password = 'password'
      @user.save!
    end

    it "should save an encrypted version of a new user’s password" do
      @user.password_hash.present?.should be_true
    end

    describe ".authenticate" do
      it "should fail to authenticate a user with a non-matching password" do
        User.authenticate(@user.email, 'wrongpassword').should be_nil
      end

      it "should authenticate a user with a valid password" do
        User.authenticate(@user.email, 'password').should eq @user
      end
    end
  end

  describe "#encrypt_password" do
  end

  describe "email code confirmation" do
    before(:each) do
      @user = User.new
      @user.email = 'test+newuser@wayground.ca'
      @user.password_confirmation = @user.password = 'password'
      @user.save!
    end

    it "should generate a confirmation token when creating a new user" do
      @user.confirmation_token.blank?.should_not be
    end
    it "should fail to confirm if the code parameter does not match the saved token" do
      @user.confirm_code!('invalid token').should be_false
    end
    it "should fail to confirm if the user’s email has already been confirmed" do
      @user.email_confirmed = true
      @user.save!
      @user.confirm_code!(@user.confirmation_token).should be_false
    end
    it "should successfully flag the user’s email as confirmed" do
      @user.confirm_code!(@user.confirmation_token)
      @user.email_confirmed.should be_true
    end
    it "should clear the confirmation token when the user’s email is confirmed" do
      @user.confirm_code!(@user.confirmation_token)
      @user.confirmation_token.should be_nil
    end
  end

  # REMEMBER ME

  context '#generate_remember_token' do
    it "should create a unique token" do
      user = FactoryGirl.build(:user)
      user.generate_remember_token
      user.save!
      user.remember_token.present?.should be_true
    end
  end

  context "#remember_token_hash" do
    it "should produce a hash from the remember_token and user id" do
      user = User.new
      user.generate_remember_token
      user.id = 123
      user.remember_token_hash.should match /^.+\/123/
    end
    it "should generate a remember_token if blank" do
      user = FactoryGirl.create(:user)
      user.remember_token = nil
      user.remember_token_hash
      user.remember_token.present?.should be_true
    end
  end

  context "#matches_token_hash?" do
    it "should clear the token" do
      user = User.new
      user.generate_remember_token
      token = user.remember_token_hash
      user.matches_token_hash?(token).should be_true
    end
  end


  # AUTHORITIES

  context "#admin?" do
    before(:all) do
      @user = FactoryGirl.create(:user)
    end
    it "should be true for a user with global is_owner authority" do
      @user.make_admin!
      @user.admin?.should be_true
    end
    it "should not be true for a user with global, but not is_owner, authority" do
      @user.authorities.delete_all
      @user.set_authority_on_area('global', :can_view)
      @user.admin?.should_not be_true
    end
    it "should not be true for a regular user" do
      @user.authorities.delete_all
      @user.admin?.should_not be_true
    end
  end

  describe "#first_user_is_admin" do
    before(:each) do
      Authority.delete_all
      User.delete_all
      @user = FactoryGirl.create(:user)
    end
    it "should create one authority for first user" do
      Authority.count.should == 1
    end
    it "should do nothing if more than one user" do
      Authority.count.should == 1
      User.count.should == 1
      second_user = FactoryGirl.create(:user)
      Authority.count.should == 1
    end
  end

  describe "#make_admin!" do
    before(:each) do
      Authority.delete_all
      User.delete_all
      @admin = FactoryGirl.create(:user)
    end
    it "should upgrade a pre-existing global authority" do
      authority = FactoryGirl.create(:authority, {:area => 'global'})
      user = authority.user
      user.make_admin!
      user.authorizations.for_area_or_global('global').for_action(:is_owner).first.should_not be_nil
    end
    it "should upgrade a pre-existing specific area authority" do
      authority = FactoryGirl.create(:authority, {:area => 'Content'})
      user = authority.user
      user.make_admin!('Content')
      user.authorizations.for_area_or_global('Content').for_action(:is_owner).first.should_not be_nil
    end
    it "should not change the authorizing user when authorizing user not provided for a pre-existing authority" do
      authority = FactoryGirl.create(:authority, {:area => 'global', :authorized_by => @admin})
      user = authority.user
      user.make_admin!
      user.authorizations.for_area_or_global('global').for_action(:is_owner).first.authorized_by.should == @admin
    end
    it "should assign the authorizing user when provided for a pre-existing authority" do
      authority = FactoryGirl.create(:authority, {:area => 'global', :authorized_by => @admin})
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
      authority = FactoryGirl.build(:authority, :user => user, :area => 'global', :can_view => true)
      user.authorizations << authority
      user.save!
      user.set_authority_on_area('global', :can_update)
      authority = user.authorizations.for_area('global').first
      authority.can_view?.should be_true
      authority.can_update?.should be_true
    end
  end

  describe "#set_authority_on_item" do
    before(:each) do
      @admin = FactoryGirl.create(:user)
      @user = FactoryGirl.create(:user)
      @item = FactoryGirl.create(:page)
    end
    it "should create an authority" do
      @user.authorizations.delete_all
      @user.set_authority_on_item(@item, :can_update)
      @item.has_authority_for_user_to?(@user, :can_update).should be_true
    end
    it "should ammend an existing authority" do
      authority = FactoryGirl.build(:authority, :user => @user, :item => @item, :can_view => true)
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
      @admin = FactoryGirl.create(:user)
      @user = FactoryGirl.create(:user)
      @auth_content = FactoryGirl.create(:authority, {:user => @user, :area => 'Content', :is_owner => true})
      @auth_user = FactoryGirl.create(:authority, {:user => @user, :area => 'User', :can_update => true})
      @auth_global = FactoryGirl.create(:authority, {:user => @user, :area => 'global', :can_view => true})
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
