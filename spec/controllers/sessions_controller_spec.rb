require 'rails_helper'
require 'sessions_controller'
require 'authentication'
require 'user'
require 'user_token'
require 'omniauth'

describe SessionsController, type: :controller do
  def login_mock_user
    mock_user = User.new(name: 'mock user')
    mock_token = UserToken.new(token: 'mock-token')
    mock_token.user = mock_user
    allow(UserToken).to receive(:from_cookie_token).with('test/123').and_return(mock_token)
    request.cookies['remember_token'] = 'test/123'
  end

  describe "GET 'new'" do
    it 'should redirect to the account page if already signed in' do
      login_mock_user
      get :new
      expect(response.location).to match(%r{^[a-z]+:/*[^/]+/account$})
    end
    it 'should show the sign in form' do
      get :new
      expect(response).to render_template('sessions/new')
    end
  end

  describe "POST 'create'" do
    it 'should redirect to the account page if already signed in' do
      login_mock_user
      post :create, params: { email: 'invalid', password: 'invalid' }
      expect(response.location).to match account_url # %r{^[a-z]+:/*[^/]+/account$}
    end
    it 'should not sign in the user if invalid form values submitted' do
      post :create, params: { email: 'invalid', password: 'invalid' }
      expect(cookies['remember_token']).to be_nil
    end
    it 'should show the sign in form again if invalid form values submitted' do
      post :create, params: { email: 'invalid', password: 'invalid' }
      expect(response).to render_template('sessions/new')
    end
    context 'with a valid user sign in' do
      before(:all) do
        @email = 'test+session@wayground.ca'
        @user = FactoryGirl.create(:user, email: @email, password: 'password')
        @user_token = @user.tokens.create(token: 'valid user sign in token')
      end
      after(:all) do
        @user.delete
      end
      it 'should sign in the user' do
        post :create, params: { email: @email, password: 'password' }
        expect(cookies['remember_token']).to match(%r{.+/#{@user.id}})
      end
      it 'should take the user to the root page' do
        post :create, params: { email: @email, password: 'password' }
        expect(response.location).to eq root_url
      end
      it 'should notify the user that they are signed in' do
        post :create, params: { email: @email, password: 'password' }
        expect(flash[:notice]).to match(/You are now signed in/)
      end
      it 'should set the remember_token cookie for the session' do
        post :create, params: { email: @email, password: 'password' }
        expect(cookies['remember_token']).to eq "#{@user_token.token}/#{@user.id}"
      end
      it 'should set the remember_token permanent cookie when the user selects remember me' do
        post :create, params: { email: @email, password: 'password', remember_me: '1' }
        # FIXME: actually check whether the remember_token cookie is flagged as permanent
        expect(cookies['remember_token']).to eq "#{@user_token.token}/#{@user.id}"
      end
    end
  end

  describe "GET 'delete'" do
    it 'should redirect to the sign in page if not signed in' do
      get :delete
      expect(response.location).to match(%r{^[a-z]+:/*[^/]+/signin$})
    end
    it 'should notify the user if not signed in' do
      get :delete
      expect(flash[:notice]).to match(/You are not signed in/)
    end
    it 'should show the sign out form' do
      login_mock_user
      get :delete
      expect(response).to render_template('sessions/delete')
    end
  end

  describe "DELETE 'destroy'" do
    context 'without a signed in user' do
      it 'should redirect to the sign in page' do
        delete :destroy
        expect(response.location).to match(%r{^[a-z]+:/*[^/]+/signin$})
      end
      it 'should flash an alert' do
        delete :destroy
        expect(flash[:notice]).to match(/You are not signed in/)
      end
    end
    context 'with a valid user to sign out' do
      before(:all) do
        @user = FactoryGirl.create(:user)
        @user_token = @user.tokens.create(token: 'valid user to sign out token')
      end
      before(:each) do
        allow(User).to receive(:find).with(@user.id).and_return(@user)
      end
      it 'should clear the remember_token cookie' do
        request.cookies['remember_token'] = "#{@user_token.token}/#{@user.id}"
        delete :destroy
        expect(response.cookies['remember_token']).to be_nil
      end
      it 'should direct the user to the sign in page' do
        request.cookies['remember_token'] = "#{@user_token.token}/#{@user.id}"
        delete :destroy
        expect(response.location).to eq root_url # match(%r{^[a-z]+:/*[^/]+/signin$})
      end
      it 'should notify the user that they are signed out' do
        request.cookies['remember_token'] = "#{@user_token.token}/#{@user.id}"
        delete :destroy
        expect(flash[:notice]).to match(/You are now signed out/)
      end
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
      auth_hash = {
        'provider' => provider, 'uid' => uid,
        'user_info' => { 'name' => 'Mock User' }
      }.deep_merge(hash)
      request.env['omniauth.auth'] = OmniAuth.config.add_mock(provider, auth_hash)
    end

    context 'with an existing authentication' do
      context 'when not logged in' do
        it 'should sign in from the authentication' do
          authentication = FactoryGirl.create(:authentication, provider: 'twitter')
          set_mock_auth(authentication.provider, authentication.uid)
          get :oauth_callback, params: { provider: 'twitter' }
          expect(flash[:notice]).to match(/You are now signed in/)
        end
      end
      context 'when already logged in' do
        it 'should change the sign in source to the oauth provider' do
          authentication = FactoryGirl.create(:authentication, provider: 'twitter')
          set_mock_auth(authentication.provider, authentication.uid)
          user = authentication.user
          user_token = user.tokens.create(token: 'user token')
          request.cookies['remember_token'] = "#{user_token.token}/#{user.id}" # user is signed in
          session[:source] = nil
          get :oauth_callback, params: { provider: 'twitter' }
          expect(session[:source]).to eq 'twitter'
        end
      end
      context 'when logged in as a different user' do
        it 'should switch to the authentication’s user' do
          authentication = FactoryGirl.create(:authentication, provider: 'twitter')
          set_mock_auth(authentication.provider, authentication.uid, test: 'wrong user for existing auth')
          wrong_user = FactoryGirl.create(:user, name: 'wrong user')
          user_token = wrong_user.tokens.create(token: 'wrong_user_token')
          request.cookies['remember_token'] = "#{user_token.token}/#{wrong_user.id}" # wrong user is signed in
          get :oauth_callback, params: { provider: 'twitter' }
          # FIXME: actually check that the signed in user is the authentication user
          expect(flash[:notice]).to match(/You are now signed in/)
        end
      end
    end

    context 'with no existing authentication' do
      context 'with a logged in user' do
        it 'should add a new authentication to the user' do
          set_mock_auth('new-provider', 'new-id', test: 'new authentication for existing user')
          user = FactoryGirl.create(:user, name: 'add auth to existing user')
          user_token = user.tokens.create(token: 'user-token')
          request.cookies['remember_token'] = "#{user_token.token}/#{user.id}" # user is signed in
          get :oauth_callback, params: { provider: 'new-provider' }
          user.reload
          expect(user.authentications.count).to eq 1
        end
      end
      context 'when not logged in' do
        def when_not_logged_in(request)
          unless @when_not_logged_in
            @when_not_logged_in = true
            @pre_user_count = User.count
            set_mock_auth('new-provider', 'new-id', test: 'create new user')
            request.cookies['remember_token'] = nil # no one is signed in
            get :oauth_callback, params: { provider: 'twitter' }
            @user = User.find(cookies['remember_token'].match(%r{/([0-9]+)$})[1].to_i)
          end
        end
        it 'should create a new user' do
          when_not_logged_in(request)
          expect(User.count).to eq(@pre_user_count + 1)
        end
        it 'should add a new authentication to the new user' do
          when_not_logged_in(request)
          expect(@user.authentications.count).to eq 1
        end
        it 'should make the new user the current user' do
          when_not_logged_in(request)
          # FIXME: acutally check that the new user has been set as the current user
          expect(@user).to be_a User
        end
      end
    end

    describe 'determining the user url from the auth data' do
      before(:all) do
        @user = FactoryGirl.create(:user, name: 'auth user url user')
        @user_token = @user.tokens.create(token: 'auth-user-url-token')
      end
      def user_is_signed_in(request)
        request.cookies['remember_token'] = "#{@user_token.token}/#{@user.id}"
      end
      it 'should figure out the twitter url' do
        user_is_signed_in(request)
        set_mock_auth(:twitter, 'twitteruid', 'info' => { 'nickname' => 'twitternickname' })
        get :oauth_callback, params: { provider: 'twitter' }
        @user.reload
        authentication = @user.authentications.where(provider: 'twitter').first
        expect(authentication.url).to eq 'https://twitter.com/twitternickname'
      end
      it 'should figure out the facebook url' do
        fb_url = 'http://facebook.com/facebookuser'
        user_is_signed_in(request)
        set_mock_auth(:facebook, 'facebookuid', 'urls' => { 'Facebook' => fb_url })
        get :oauth_callback, params: { provider: 'facebook' }
        @user.reload
        authentication = @user.authentications.where(provider: 'facebook').first
        expect(authentication.url).to eq fb_url
      end
      it 'should leave the url as nil if not facebook or twitter' do
        user_is_signed_in(request)
        # put in the data used to get facebook and twitter urls to make sure they don't get picked up
        set_mock_auth(
          :fake, 'fakeuid',
          'user_info' => { 'nickname' => 'faketwitter' }, 'urls' => { 'Facebook' => 'fake_facebook_url' }
        )
        get :oauth_callback, params: { provider: 'fake' }
        @user.reload
        authentication = @user.authentications.where(provider: 'fake').first
        expect(authentication.url).to be_nil
      end
    end
  end
end
