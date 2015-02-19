require 'spec_helper'
require 'cookie_token'

describe Wayground::CookieToken do

  describe "initialization" do
    it "should take a user and id" do
      user = double(:user)
      allow(user).to receive(:id).and_return(2345)
      cookie_token = Wayground::CookieToken.new(remember: user, token: 'token-234')
      expect( cookie_token.instance_values ).to eq({'id' => 2345, 'token' => 'token-234'})
    end
  end

  describe "#to_s" do
    it "should return a string formated as “token/id”" do
      user = double(:user)
      allow(user).to receive(:id).and_return(3456)
      expect( Wayground::CookieToken.new(remember: user, token: 'token-345').to_s ).to eq 'token-345/3456'
    end
  end

end
