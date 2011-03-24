# encoding: utf-8
require 'spec_helper'

describe Authentication do
	def mock_user(stubs = {})
		@mock_user = mock_model(User, stubs)
	end
	def mock_auth(stubs = {})
		{'provider' => 'mock-provider', 'uid' => 'mock-uid',
			'user_info' => {'name' => 'Mock User'}
		}.merge(stubs)
	end

	describe ".authenticate_callback!" do
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
		describe "with existing authentication" do
			it "should throw an error when the authentication’s user doesn’t match the given user" do
				expect {
					Authentication.authenticate_callback!(@auth, mock_user)
				}.to raise_exception(Wayground::WrongUserForAuthentication)
			end
			it "should succeed when the authentication exists and no user was given" do
				authentication = Authentication.authenticate_callback!(@auth)
				authentication.should eq @authentication
			end
			it "should succeed when the authentication exists and matches the given user" do
				authentication = Authentication.authenticate_callback!(@auth, @authentication.user)
				authentication.should eq @authentication
			end
		end
		describe "with no existing authentication" do
			it "should add the authentication to the given user" do
				given_user = Factory.create :user
				authentication = Authentication.authenticate_callback!(mock_auth, given_user)
				given_user.authentications[0].should_not be_nil
			end
			it "should create a new user if no user given" do
				authentication = Authentication.authenticate_callback!(mock_auth)
				authentication.user.should_not be_nil
			end
		end
	end

	describe ".create_with_auth!" do
		it "should add the authentication to the given user" do
			given_user = Factory.create :user
			authentication = Authentication.create_with_auth!(mock_auth, given_user)
			given_user.authentications[0].should_not be_nil
		end
		it "should create a new user if no user given" do
			authentication = Authentication.create_with_auth!(mock_auth)
			authentication.user.should_not be_nil
		end
	end

	describe ".user_attrs_from_auth" do
		it "should be all nil values if an empty hash is given" do
			attrs = Authentication.user_attrs_from_auth({})
			# clear all key-value pairs where the value is nil
			attrs.delete_if {|key,value| value.nil?}
			# there should be none left
			attrs.should have(0).items
		end
		it "should fill in everything from the hash" do
			Authentication.user_attrs_from_auth({
				'provider' => 'twitter', 'uid' => 'testuser',
				'user_info' => {
					'nickname' => 'testnick', 'name' => 'Test User',
					'email' => 'test@email.tld', 'location' => 'Test Location',
					'image' => 'http://host.tld/img.png', 'description' => 'A test authentication.'
				}
			}).should eq({
				:provider => 'twitter', :uid => 'testuser', :nickname => 'testnick',
				:name => 'Test User', :email => 'test@email.tld', :location => 'Test Location',
				:image_url => 'http://host.tld/img.png', :description => 'A test authentication.',
				:url => 'https://twitter.com/testnick'
			})
		end
	end

	describe ".url_from_provider_auth" do
		it "should set the url if the provider is Facebook" do
			url = 'https://facebook.com/mockuser'
			auth = mock_auth({'provider' => 'facebook', 'urls' => {'Facebook' => url}})
			Authentication.url_from_provider_auth(auth).should eq url
		end
		it "should set the url if the provider is Twitter" do
			auth = mock_auth({'provider' => 'twitter',
				'user_info' => {'name' => 'Mock User', 'nickname' => 'mockuser'}
			})
			Authentication.url_from_provider_auth(auth).should eq 'https://twitter.com/mockuser'
		end
		it "should have no url if the provider isn’t recognized" do
			Authentication.url_from_provider_auth(mock_auth).should be_blank
		end
	end

	describe "#new_user?" do
		it "should be false if an authentication was created for an existing user" do
			authentication = Authentication.create_with_auth!(mock_auth, Factory.build(:user))
			authentication.new_user?.should be_false
		end
		it "should be true if the user was created for the authentication" do
			authentication = Authentication.create_with_auth!(mock_auth)
			authentication.new_user?.should be_true
		end
	end
end
