# encoding: utf-8
require 'spec_helper'

describe SessionsController do

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, {:id => 123, :email => 'test+session@wayground.ca'}.merge(stubs))
  end


  context "GET 'new'" do
    it "should redirect to the account page if already signed in" do
      request.cookies['remember_token'] = 'test/123'
      User.stub!(:find).with(123).and_return(mock_user(:matches_token_hash? => true))
      get 'new'
      response.location.should match /^[a-z]+:\/*[^\/]+\/account$/
    end
    it "should show the sign in form" do
      get 'new'
      response.should render_template('sessions/new')
    end
  end

  context "POST 'create'" do
    it "should redirect to the account page if already signed in" do
      request.cookies['remember_token'] = 'test/123'
      User.stub!(:find).with(123).and_return(mock_user(:matches_token_hash? => true))
      post 'create', {:email => 'invalid', :password => 'invalid'}
      response.location.should match account_url #/^[a-z]+:\/*[^\/]+\/account$/
    end
    it "should not sign in the user if invalid form values submitted" do
      post 'create', {:email => 'invalid', :password => 'invalid'}
      cookies['remember_token'].should be_nil
    end
    it "should show the sign in form again if invalid form values submitted" do
      post 'create', {:email => 'invalid', :password => 'invalid'}
      response.should render_template('sessions/new')
    end
    context "with a valid user sign in" do
      before(:all) do
        @user = Factory.create(:user, :email => 'test+session@wayground.ca', :password => 'password')
        User.stub!(:authenticate).and_return(@user)
      end
      it "should sign in the user" do
        post 'create', {:email => 'test+session@wayground.ca', :password => 'password'}
        cookies['remember_token'].should match /.+\/#{@user.id}/
      end
      it "should take the user to the root page" do
        post 'create', {:email => 'test+session@wayground.ca', :password => 'password'}
        response.location.should eq root_url
      end
      it "should notify the user that they are signed in" do
        post 'create', {:email => 'test+session@wayground.ca', :password => 'password'}
        flash[:notice].should match /You are now signed in/
      end
      it "should set the remember_token cookie for the session" do
        post 'create', {:email => 'test+session@wayground.ca', :password => 'password'}
        cookies['remember_token'].should eq @user.remember_token_hash
      end
      it "should set the remember_token permanent cookie when the user selects remember me" do
        post 'create', {:email => 'test+session@wayground.ca', :password => 'password', :remember_me => '1'}
        cookies['remember_token'].should eq @user.remember_token_hash
      end
    end
  end

  context "GET 'delete'" do
    it "should redirect to the sign in page if not signed in" do
      get 'delete'
      response.location.should match /^[a-z]+:\/*[^\/]+\/signin$/
    end
    it "should notify the user if not signed in" do
      get 'delete'
      flash[:notice].should match /You are not signed in/
    end
    it "should show the sign out form" do
      request.cookies['remember_token'] = 'test/123'
      User.stub!(:find).with(123).and_return(mock_user(:matches_token_hash? => true))
      get 'delete'
      response.should render_template('sessions/delete')
    end
  end

  context "DELETE 'destroy'" do
    context "without a signed in user" do
      it "should redirect to the sign in page" do
        delete 'destroy'
        response.location.should match /^[a-z]+:\/*[^\/]+\/signin$/
      end
      it "should flash an alert" do
        delete 'destroy'
        flash[:notice].should match /You are not signed in/
      end
    end
    context "with a valid user to sign out" do
      before(:all) do
        @user = Factory.create(:user)
        User.stub!(:find).with(@user.id).and_return(@user)
      end
      it "should clear the remember_token cookie" do
        request.cookies['remember_token'] = @user.remember_token_hash
        delete 'destroy'
        cookies['remember_token'].should be_nil
      end
      it "should direct the user to the sign in page" do
        request.cookies['remember_token'] = @user.remember_token_hash
        delete 'destroy'
        response.location.should eq root_url #match /^[a-z]+:\/*[^\/]+\/signin$/
      end
      it "should notify the user that they are signed out" do
        request.cookies['remember_token'] = @user.remember_token_hash
        delete 'destroy', {:debug => 'y'}, {:debug => 'y'}
        flash[:notice].should match /You are now signed out/
      end
    end
  end

  context "GET 'oauth_callback'" do
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
      request.cookies['remember_token'] = authentication.user.remember_token_hash # user is signed in
      session[:source] = nil
      get :oauth_callback, :provider => 'twitter'
      session[:source].should eq 'twitter'
    end
    it "should give an error when an existing authentication is used by the wrong user" do
      authentication = Factory.create(:authentication, :provider => 'twitter')
      set_mock_auth(authentication.provider, authentication.uid)
      wrong_user = Factory.create(:user)
      request.cookies['remember_token'] = wrong_user.remember_token_hash # wrong user is signed in
      get :oauth_callback, :provider => 'twitter'
      flash[:alert].should match /ERROR: The authentication failed/
    end
    it "should add a new authentication to the signed in user" do
      set_mock_auth('new-provider', 'new-id')
      user = Factory.create(:user)
      request.cookies['remember_token'] = user.remember_token_hash # user is signed in
      get :oauth_callback, :provider => 'twitter'
      user.reload
      user.authentications.count.should eq 1
    end
    it "should create and sign in a new user with a new authentication when not already signed in" do
      set_mock_auth('new-provider', 'new-id')
      request.cookies['remember_token'] = nil # no one is signed in
      get :oauth_callback, :provider => 'twitter'
      user = User.find(cookies['remember_token'].match(/\/([0-9]+)$/)[1].to_i)
      user.authentications.count.should eq 1
    end
  end
end
