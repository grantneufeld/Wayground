require 'spec_helper'
require 'rememberer'
require 'user'
require 'user_token'

module Wayground
  describe Rememberer do
    describe '#initialize' do
      it 'should accept an object to remember' do
        expect(Rememberer.new(remember: 'a user').remember).to eq 'a user'
      end
      it 'should accept a token' do
        expect(Rememberer.new(token: 'a token').token).to eq 'a token'
      end
    end

    describe '#cookie_token' do
      before(:all) do
        User.delete_all
        @user = FactoryGirl.create(:user)
      end
      context 'with an existing token for the remembered object' do
        before(:all) do
          @user.tokens.delete_all
          @user_token = @user.tokens.create(token: 'existing token')
        end
        it 'should use an existing token for the remembered object if there is one' do
          rememberer = Rememberer.new(remember: @user)
          cookie_token = rememberer.cookie_token
          expect(cookie_token).to eq "#{@user_token.token}/#{@user.id}"
        end
      end
      context 'with no existing tokens for the remembered object' do
        before(:each) do
          @user.tokens.delete_all
        end
        it 'should create a token' do
          Rememberer.new(remember: @user).cookie_token
          expect(@user.tokens.count).to eq 1
        end
      end
      it 'should return a token string formatted for use in a cookie' do
        expect(Rememberer.new(remember: @user).cookie_token).to match(%r{\A.+/[0-9]+\z})
      end
    end
  end
end
