require 'spec_helper'
require 'parsed_cookie_token'

describe Wayground::ParsedCookieToken do
  describe 'initialization' do
    it 'should parse a valid cookie token into token and id' do
      parsed_token = Wayground::ParsedCookieToken.new('token-456/4567')
      expect(parsed_token.instance_values).to eq('id' => 4567, 'token' => 'token-456')
    end
    it 'should raise an error on an invalid cookie token' do
      expect { Wayground::ParsedCookieToken.new('invalid token') }.to raise_exception(
        Wayground::ParsedCookieToken::InvalidToken
      )
    end
  end

  describe '#token' do
    it 'should return the token from the cookie token' do
      expect(Wayground::ParsedCookieToken.new('the token/567').token).to eq 'the token'
    end
  end

  describe '#id' do
    it 'should return the id from the token as an integer' do
      expect(Wayground::ParsedCookieToken.new('token-678/6789').id).to eq 6789
    end
  end
end
