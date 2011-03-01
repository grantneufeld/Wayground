require 'spec_helper'

describe SessionsController do
	
	before(:each) do
		User.stub!(:find).with(123).and_return(mock_user)
	end
	
	def mock_user(stubs={})
		@mock_user ||= mock_model(User, {:id => 123, :email => 'test+session@wayground.ca'}.merge(stubs))
	end
		

	describe "GET 'new'" do
		it "should redirect to the account page if already signed in" do
			session[:user_id] = mock_user.id
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
			delete 'destroy'
			session[:user_id].should be_nil
		end
		it "should direct the user to the sign in page after signing out" do
			session[:user_id] = mock_user.id
			delete 'destroy'
			response.location.should eq root_url #match /^[a-z]+:\/*[^\/]+\/sign_in$/
		end
		it "should notify the user that they are signed out after sign out" do
			session[:user_id] = mock_user.id
			delete 'destroy'
			flash[:notice].should match /You are now signed out/
		end
	end

end
