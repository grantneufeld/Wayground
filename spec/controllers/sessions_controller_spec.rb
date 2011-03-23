# encoding: utf-8
require 'spec_helper'

describe SessionsController do
	
	def mock_user(stubs={})
		@mock_user ||= mock_model(User, {:id => 123, :email => 'test+session@wayground.ca'}.merge(stubs))
	end
		

	describe "GET 'new'" do
		it "should redirect to the account page if already signed in" do
			session[:user_id] = mock_user.id
			User.stub!(:find).with(session[:user_id]).and_return(mock_user)
			get 'new'
			response.location.should match /^[a-z]+:\/*[^\/]+\/account$/
		end
		it "should show the sign in form" do
			get 'new'
			response.should render_template('sessions/new')
		end
	end

	describe "POST 'create'" do
		it "should redirect to the account page if already signed in" do
			session[:user_id] = mock_user.id
			User.stub!(:find).with(session[:user_id]).and_return(mock_user)
			post 'create', {:email => 'invalid', :password => 'invalid'}
			response.location.should match account_url #/^[a-z]+:\/*[^\/]+\/account$/
		end
		it "should not sign in the user if invalid form values submitted" do
			post 'create', {:email => 'invalid', :password => 'invalid'}
			session[:user_id].should be_nil
		end
		it "should show the sign in form again if invalid form values submitted" do
			post 'create', {:email => 'invalid', :password => 'invalid'}
			response.should render_template('sessions/new')
		end
		it "should sign in the user if valid form values submitted" do
			user = mock_user
			User.stub!(:authenticate).and_return(mock_user)
			post 'create', {:email => 'test+session@wayground.ca', :password => 'password'}
			session[:user_id].should eq mock_user.id
		end
		it "should take the user to the root page after sign in" do
			user = mock_user
			User.stub!(:authenticate).and_return(mock_user)
			post 'create', {:email => 'test+session@wayground.ca', :password => 'password'}
			response.location.should eq root_url #match /^[a-z]+:\/*[^\/]+\/account$/
		end
		it "should notify the user that they are signed in after sign in" do
			user = mock_user
			User.stub!(:authenticate).and_return(mock_user)
			post 'create', {:email => 'test+session@wayground.ca', :password => 'password'}
			flash[:notice].should match /You are now signed in/
		end
	end

	describe "GET 'delete'" do
		it "should redirect to the sign in page if not signed in" do
			get 'delete'
			response.location.should match /^[a-z]+:\/*[^\/]+\/sign_in$/
		end
		it "should notify the user if not signed in" do
			get 'delete'
			flash[:notice].should match /You are not signed in/
		end
		it "should show the sign out form" do
			session[:user_id] = mock_user.id
			User.stub!(:find).with(session[:user_id]).and_return(mock_user)
			get 'delete'
			response.should render_template('sessions/delete')
		end
	end

	describe "DELETE 'destroy'" do
		it "should redirect to the sign in page if not signed in" do
			delete 'destroy'
			response.location.should match /^[a-z]+:\/*[^\/]+\/sign_in$/
		end
		it "should flash an alert if not signed in" do
			delete 'destroy'
			flash[:notice].should match /You are not signed in/
		end
		it "should sign out the user if signed in" do
			session[:user_id] = mock_user.id
			User.stub!(:find).with(session[:user_id]).and_return(mock_user)
			delete 'destroy'
			session[:user_id].should be_nil
		end
		it "should direct the user to the sign in page after signing out" do
			session[:user_id] = mock_user.id
			User.stub!(:find).with(session[:user_id]).and_return(mock_user)
			delete 'destroy'
			response.location.should eq root_url #match /^[a-z]+:\/*[^\/]+\/sign_in$/
		end
		it "should notify the user that they are signed out after sign out" do
			session[:user_id] = mock_user.id
			User.stub!(:find).with(session[:user_id]).and_return(mock_user)
			delete 'destroy'
			flash[:notice].should match /You are now signed out/
		end
	end

	describe "GET 'oauth_callback'" do
		before(:all) do
			OmniAuth.config.test_mode = true
			Authentication.delete_all
			User.delete_all
		end
		after(:all) do
			OmniAuth.config.test_mode = false
		end
		def set_mock_auth(provider = :twitter, uid = '12345', hash = {})
			@provider = provider
			@uid = uid
			request.env["omniauth.auth"] = OmniAuth.config.add_mock(provider, {
				:uid => @uid,
				:user_info => {'name' => 'Oauth User'}
			}.merge(hash))
		end

		it "should sign in an existing authentication when not signed in" do
			authentication = Factory.create(:authentication, :provider => 'twitter')
			set_mock_auth(authentication.provider, authentication.uid)
			get :oauth_callback, :provider => 'twitter'
			flash[:notice].should match /You are now signed in/
		end
		it "should change the signed in user’s sign in source to the oauth provider" do
			authentication = Factory.create(:authentication, :provider => 'twitter')
			set_mock_auth(authentication.provider, authentication.uid)
			session[:user_id] = authentication.user.id # user is signed in
			session[:source] = nil
			get :oauth_callback, :provider => 'twitter'
			session[:source].should eq 'twitter'
		end
		it "should give an error when an existing authentication is used by the wrong user" do
			authentication = Factory.create(:authentication, :provider => 'twitter')
			set_mock_auth(authentication.provider, authentication.uid)
			wrong_user = Factory.create(:user)
			session[:user_id] = wrong_user.id # wrong user is signed in
			get :oauth_callback, :provider => 'twitter'
			flash[:alert].should match /ERROR: The authentication failed/
		end
		it "should add a new authentication to the signed in user" do
			set_mock_auth('new-provider', 'new-id')
			user = Factory.create(:user)
			session[:user_id] = user.id # user is signed in
			get :oauth_callback, :provider => 'twitter'
			user.authentications.count.should eq 1
		end
		it "should create and sign in a new user with a new authentication when not already signed in" do
			set_mock_auth('new-provider', 'new-id')
			session[:user_id] = nil # no one is signed in
			get :oauth_callback, :provider => 'twitter'
			user = User.find(session[:user_id])
			user.authentications.count.should eq 1
		end
	end
end
