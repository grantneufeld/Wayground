require 'spec_helper'
require 'authentication'

describe Authentication, type: :model do
  describe "#label" do
    it "should make a special case for Twitter" do
      authentication = Authentication.new(provider: 'twitter', uid: '123', nickname: 'nick')
      expect(authentication.label).to eq '@nick'
    end
    it "should use the nickname, if present" do
      authentication = Authentication.new(provider: :test, uid: '123', name: 'A Name', nickname: 'Nick')
      expect(authentication.label).to eq 'Nick'
    end
    it "should use the name, if present and no nickname" do
      authentication = Authentication.new(provider: :test, uid: '123', name: 'A Name')
      expect(authentication.label).to eq 'A Name'
    end
    it "should fall back on the uid, if nothing else" do
      authentication = Authentication.new(provider: :test, uid: '123')
      expect(authentication.label).to eq '123'
    end
  end
end
