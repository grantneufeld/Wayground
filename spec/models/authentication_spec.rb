# encoding: utf-8
require 'spec_helper'

describe Authentication do
	def mock_user(stubs = {})
		@mock_user = mock_model(User, stubs)
	end

	describe ".authenticate" do
		before(:all) do
			Authentication.delete_all
			User.delete_all
		end
		before(:each) do
			@authentication = Factory.build(:authentication)
			#debugger
			@authentication.save!
			@auth = {'provider' => @authentication.provider, 'uid' => @authentication.uid}
		end
		it "should return nils if the authentication doesn’t exist" do
			authentication, user = Authentication.authenticate(
				{'provider' => 'absent-provider', 'uid' => 'absent-uid'}
			)
			authentication.should be_nil
		end
		it "should throw an error when the authentication’s user doesn’t match the given user" do
			expect {
				Authentication.authenticate(@auth, mock_user)
			}.to raise_exception(Wayground::WrongUserForAuthentication)
		end
		it "should succeed when the authentication exists and no user was given" do
			authentication, user = Authentication.authenticate(@auth)
			authentication.should eq @authentication
		end
		it "should succeed when the authentication exists and matches the given user" do
			authentication, user = Authentication.authenticate(@auth, @authentication.user)
			authentication.should eq @authentication
		end
	end

	describe ".create_with_auth!" do
		def mock_auth(stubs = {})
			{'provider' => 'mock-provider', 'uid' => 'mock-uid',
				'user_info' => {'name' => 'Mock User'}
			}.merge(stubs)
		end
		it "should set the url if the provider is Facebook" do
			url = 'http://facebook.com/mockuser'
			auth = mock_auth({'provider' => 'facebook', 'urls' => {'Facebook' => url}})
			authentication, user = Authentication.create_with_auth!(auth)
			authentication.url.should eq url
		end
		it "should set the url if the provider is Twitter" do
			auth = mock_auth({'provider' => 'twitter',
				'user_info' => {'name' => 'Mock User', 'nickname' => 'mockuser'}
			})
			authentication, user = Authentication.create_with_auth!(auth)
			authentication.url.should eq 'http://twitter.com/mockuser'
		end
		it "should have no url if the provider isn’t recognized" do
			authentication, user = Authentication.create_with_auth!(mock_auth)
			authentication.url.should be_blank
		end
		it "should add the authentication to the given user" do
			given_user = Factory.create :user
			authentication, user = Authentication.create_with_auth!(mock_auth, given_user)
			given_user.authentications[0].should_not be_nil
		end
		it "should create a new user if no user given" do
			authentication, user = Authentication.create_with_auth!(mock_auth)
		end
	end
end
