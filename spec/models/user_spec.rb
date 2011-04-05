# encoding: utf-8
require 'spec_helper'

describe User do
	def mock_auth(stubs = {})
		@mock_auth = mock_model(Authentication, stubs)
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
			authentication = Factory.build(:authentication)
			user = authentication.user
			user.valid?.should be_true
		end
	end

	describe "create_from_authentication!" do
		it "should create a new user with the authentication" do
			#authentication = mock_auth({:name => 'User From Auth', :email => 'test+fromauth@wayground.ca', :user= => nil, :to_ary => []})
			authentication = Factory.create(:authentication,
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
		
		it "should fail to authenticate a user with a non-matching password" do
			User.authenticate(@user.email, 'wrongpassword').should be_nil
		end
		
		it "should authenticate a user with a valid password" do
			User.authenticate(@user.email, 'password').should eq @user
		end
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

	describe "#set_authority_on_area" do
	  it "should create an authority" do
	    user = Factory.create(:user)
	    user.set_authority_on_area('global', :can_edit)
	    user.has_authority_for_area('global', :can_edit).should be_true
    end
    it "should ammend an existing authority" do
	    user = Factory.create(:user)
	    authority = Factory.build(:authority, :user => user, :area => 'global', :can_view => true)
	    user.authorities << authority
	    user.save!
	    user.set_authority_on_area('global', :can_edit)
	    authority = user.authorizations.for_area('global').first
	    authority.can_view?.should be_true
	    authority.can_edit?.should be_true
    end
  end

	describe "#set_authority_on_item" do
		before(:each) do
			@user = Factory.create(:user)
			@item = Factory.create(:user)
		end
	  it "should create an authority" do
	    @user.set_authority_on_area('global', :can_edit)
	    @user.has_authority_for_area('global', :can_edit).should be_true
    end
    it "should ammend an existing authority" do
	    authority = Factory.build(:authority, :user => @user, :item => @item, :can_view => true)
	    @user.authorities << authority
	    @user.save!
	    #debugger
	    @user.set_authority_on_item(@item, :can_edit)
	    authority = @user.authorizations.for_item(@item).first
	    authority.can_view?.should be_true
	    authority.can_edit?.should be_true
    end
  end

	describe "#has_authority_for_area" do
	  it "should default to the view authority for the area" do
    end
	  it "should return the authority for the area if it authorizes the action" do
    end
	  it "should return the authority for the area if the action is set to nil" do
    end
    it "should return the global authority if there isn’t one for the specified area" do
    end
  end

end
