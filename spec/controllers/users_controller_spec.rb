require 'spec_helper'

describe UsersController, type: :controller do

  before(:all) do
    User.destroy_all
  end

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, {:id => 123, :email => 'test+mock@wayground.ca'}.merge(stubs))
  end

  def set_logged_in(stubs={})
    allow(controller).to receive(:current_user).and_return(mock_user(stubs))
  end

  describe "GET 'profile'" do
    let(:user) { @user = FactoryGirl.create(:user) }
    it "should be successful" do
      get 'profile', :id => user.id
      expect(response).to be_success
    end
    it "should show the specified user’s profile" do
      get 'profile', :id => user.id
      expect(assigns(:profile_user)).to eq user
    end
  end

  describe "GET 'show'" do
    it "should be successful" do
      set_logged_in
      get 'show'
      expect(response).to be_success
    end
    it "should redirect to the signin page if the user is not signed-in" do
      get 'show'
      expect(response).to redirect_to(signin_url)
    end
  end

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      # TODO: more descriptive check of the new user form
      expect(response).to be_success
      # should not be a redirect:
      expect(response.location.blank?).to be_truthy
    end
    it "should not show the form if the user is already signed-in" do
      set_logged_in
      get 'new'
      expect(flash[:notice]).to match /You are already signed up/i
      expect(response).to redirect_to(account_url)
    end
  end

  describe "POST 'create'" do
    it "should not accept the user registration if the user is already signed-in" do
      set_logged_in
      post 'create'
      expect(flash[:notice]).to match /You are already signed up/i
      expect(response).to redirect_to(account_url)
    end
    it "should fail if empty form submitted" do
      post 'create'
      # TODO: check that there are errors reported
      expect(response.location.blank?).to be_truthy
    end
    it "should fail if invalid form submitted" do
      post 'create', :user => {:email => 'invalid email address',
        :password => 'invalid', :password_confirmation => 'doesn’t match'
      }
      # TODO: check that there are errors reported
      expect(response.location.blank?).to be_truthy
    end
    it "should create a new user record as an admin when valid form submitted" do
      # clear out any existing users so this will be the first, so be made an admin
      Authority.delete_all
      User.delete_all
      post 'create', :user => {:email => 'test+new@wayground.ca',
        :password => 'password', :password_confirmation => 'password'
      }
      expect(flash[:notice]).to match /You are now registered as an administrator for this site/i
      expect(response).to redirect_to(account_url)
    end
    it "should create a new user record when valid form submitted" do
      # have an existing user so we don’t default to creating an admin
      FactoryGirl.create(:user)
      post 'create', :user => {:email => 'test+new@wayground.ca',
        :password => 'password', :password_confirmation => 'password'
      }
      expect(flash[:notice]).to match /You are now registered on this site/i
      expect(response).to redirect_to(account_url)
    end
    it "should sign in the new user record when valid form submitted" do
      post 'create', :user => {:email => 'test+new@wayground.ca',
        :password => 'password', :password_confirmation => 'password'
      }
      expect(cookies['remember_token']).to match /^.+\/[0-9]+$/
    end
  end

  describe "GET 'confirm'" do
    it "should set the user’s email_confirmation to true" do
      set_logged_in({:email_confirmed => false, :confirm_code! => true})
      get 'confirm', :confirmation_code => 'abc123'
      expect(flash[:notice]).to match /Thank-you for confirming your email address/i
      expect(response).to redirect_to(account_url)
    end
    it "should fail if the database is not working, or some other exception occurs" do
      set_logged_in({:email_confirmed => false}) #, :confirm_code! => true})
      allow(mock_user).to receive(:confirm_code!).and_raise(:fail)
      get 'confirm', :confirmation_code => 'abc123'
      expect(flash[:alert]).to match /There was a problem/i
      expect(response.status).to eq 500
      expect(response.location).to eq account_url
    end
    it "should redirect to sign-in if the user is not signed-in" do
      get 'confirm', :confirmation_code => 'abc123'
      expect(response).to redirect_to(signin_url)
    end
    it "should not confirm the user if the wrong code is supplied" do
      set_logged_in({:email_confirmed => false, :confirm_code! => false})
      get 'confirm', :confirmation_code => 'wrong code'
      expect(flash[:alert]).to match /Invalid confirmation code/i
      expect(response).to redirect_to(account_url)
    end
    it "should not confirm the user if they are already confirmed" do
      set_logged_in({:email_confirmed => true})
      get 'confirm', :confirmation_code => 'abc123'
      expect(flash[:notice]).to match /Your email address was already confirmed/i
      expect(response).to redirect_to(account_url)
    end
  end

end
