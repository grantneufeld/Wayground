require 'spec_helper'
require 'login/oauth_login'
require_relative 'login_interface'
require 'authentication'
require 'user'

module Wayground
  module Login
    describe Wayground::Login::OauthLogin do

      before(:all) do
        Authentication.delete_all
        User.delete_all
        @user = FactoryGirl.build(:user, name: 'Oauth User')
        @provider = 'testprovider'
        @uid = 'testuser'
        @authentication = @user.authentications.build(provider: @provider, uid: @uid)
        @user.save!
      end

      it_behaves_like 'Login Interface', OauthLogin.new

      describe "initialization" do
        it "should set the current_user" do
          expect( OauthLogin.new(current_user: 'current user').current_user ).to eq 'current user'
        end
        it "should set the password" do
          expect( OauthLogin.new(auth: 'auth').auth ).to eq 'auth'
        end
      end

      describe "#user" do
        context "with an existing authentication" do
          context "when not logged in" do
            it "should return the authentication user" do
              auth_hash = {'provider' => @provider, 'uid' => @uid}
              expect( OauthLogin.new(auth: auth_hash).user ).to eq @user
            end
          end
        end
        context "with no existing authentication" do
          context "with a current user" do
            it "should add a new authentication to the user" do
              @user.authentications.delete_all
              provider = 'newproviderforuser'
              uid = 'newuidforuser'
              auth_hash = {'provider' => provider, 'uid' => uid}
              user = OauthLogin.new(current_user: @user, auth: auth_hash).user
              authentication = user.authentications.where(provider: provider).first
              expect( authentication.uid ).to eq uid
            end
          end
          context "with no current user" do
            before(:all) do
              @new_provider = 'newprovideranduser'
              @new_uid = 'newuidanduser'
              auth_hash = {'provider' => @new_provider, 'uid' => @new_uid}
              @new_user = OauthLogin.new(auth: auth_hash).user
            end
            it "should create a new user" do
              expect( @new_user ).to be_a User
            end
            it "should add a new authentication to the new user" do
              authentication = @new_user.authentications.where(provider: @new_provider).first
              expect( authentication.uid ).to eq @new_uid
            end
          end
        end
        context '...' do
          before(:each) do
            @user.authentications.delete_all
          end
          it 'should figure out the facebook url' do
            provider = 'facebook'
            fb_url = 'http://facebook.com/fburl'
            auth_hash = {'provider' => provider, 'uid' => 'facebookuid', 'urls' => {'Facebook' => fb_url}}
            user = OauthLogin.new(current_user: @user, auth: auth_hash).user
            authentication = user.authentications.where(provider: provider).first
            expect( authentication.url ).to eq fb_url
          end
          it 'should figure out the twitter url' do
            provider = 'twitter'
            auth_hash = {'provider' => provider, 'uid' => 'twitteruid',
              'info' => { 'nickname' => 'twitteruser' }
            }
            user = OauthLogin.new(current_user: @user, auth: auth_hash).user
            authentication = user.authentications.where(provider: provider).first
            expect( authentication.url ).to eq 'https://twitter.com/twitteruser'
          end
          it 'should leave the url as nil if not facebook or twitter' do
            provider = 'nourl'
            auth_hash = {'provider' => provider, 'uid' => 'nourluid',
              # include the facebook and twitter data to make sure it’s not accidentally getting picked up
              'user_info' => {'nickname' => 'wrong'},
              'info' => { 'nickname' => 'alsowrong' },
              'urls' => {'Facebook' => 'http://facebook.com/wrong'}
            }
            user = OauthLogin.new(current_user: @user, auth: auth_hash).user
            authentication = user.authentications.where(provider: provider).first
            expect( authentication.url ).to be_nil
          end
        end
      end

    end
  end
end
