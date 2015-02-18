require 'rails_helper'
require 'user_token'
require 'user'

describe UserToken, type: :model do

  describe "attribute mass assignment security" do
    it "should allow expires_at" do
      expires_at = Time.now
      expect( UserToken.new(expires_at: expires_at).expires_at ).to eq expires_at
    end
    it "should allow token" do
      token = 'test token'
      expect( UserToken.new(token: token).token ).to eq token
    end
    it "should deny user id" do
      expect{
        UserToken.new(user_id: 1)
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "validations" do
    it "should validate with just a user and token" do
      user = User.new
      user.id = 123
      user_token = UserToken.new(token: 'abc')
      user_token.user = user
      expect( user_token.valid? ).to be_truthy
    end
    it "should not validate without a user" do
      user_token = UserToken.new(token: 'abc')
      expect( user_token.valid? ).to be_falsey
    end
    it "should not validate without a token" do
      user_token = UserToken.new
      user_token.user = User.new
      expect( user_token.valid? ).to be_falsey
    end
    it "should not validate on creation with an expiry datetime that has already passed" do
      user_token = UserToken.new(token: 'abc', expires_at: Time.now)
      user_token.user = User.new
      expect( user_token.valid? ).to be_falsey
    end
  end

  describe ".from_cookie_token" do
    it "should return a single UserToken" do
      user_token = UserToken.new(token: 'single-token')
      query_result = double('where on id token')
      query_sub_result = double('where on expiry')
      include_result = double('include user')
      allow(include_result).to receive(:first!).and_return(user_token)
      allow(query_result).to receive(:includes).with(:user).and_return(include_result)
      allow(UserToken).to receive(:where).with(user_id: 123, token: 'single-token').and_return(query_result)
      expect( UserToken.from_cookie_token('single-token/123') ).to eq user_token
    end
    it "should return a null token when no matching token found" do
      expect( UserToken.from_cookie_token('does not exist/987').user_id ).to be_nil
    end
    it "should return a null token when the token has expired" do
      user_token = UserToken.new(token: 'expired-token', expires_at: Time.now)
      query_result = double('where on id token')
      query_sub_result = double('where on expiry')
      include_result = double('include user')
      allow(include_result).to receive(:first!).and_return(user_token)
      allow(query_result).to receive(:includes).with(:user).and_return(include_result)
      allow(UserToken).to receive(:where).with(user_id: 345, token: 'expired-token').and_return(query_result)
      expect( UserToken.from_cookie_token('expired-token/345').user_id ).to be_nil
    end
  end

  describe ".cleanup_expired_tokens" do
    before(:all) do
      @user = FactoryGirl.create(:user)
    end
    it "should do nothing when there are no tokens" do
      UserToken.delete_all
      original_count = UserToken.count
      UserToken.cleanup_expired_tokens
      expect( UserToken.count ).to eq original_count
    end
    context "with existing tokens" do
      it "should remove any tokens that have expired" do
        keep = @user.tokens.create(token: 'keep token', expires_at: 1.minute.from_now)
        original_count = UserToken.count
        exp = @user.tokens.create(token: 'expires now token', expires_at: Time.now)
        exp = @user.tokens.create(token: 'expires 6 hours ago token', expires_at: 6.hours.ago)
        exp = @user.tokens.create(token: 'expires 7 hours ago token', expires_at: 7.hours.ago)
        UserToken.cleanup_expired_tokens
        expect( UserToken.count ).to eq (original_count)
        keep.delete
      end
      it "should not remove tokens that expire later than the current date & time" do
        original_count = UserToken.count
        @user.tokens.create(token: 'expires 1 minute from now token', expires_at: 1.minute.from_now)
        @user.tokens.create(token: 'expires 1 week from now token', expires_at: 1.week.from_now)
        UserToken.cleanup_expired_tokens
        expect( UserToken.count ).to eq (original_count + 2)
      end
      it "should not remove tokens that do not have an expiry set" do
        original_count = UserToken.count
        @user.tokens.create(token: 'no expiry', expires_at: nil)
        UserToken.cleanup_expired_tokens
        expect( UserToken.count ).to eq (original_count + 1)
      end
    end
  end

end
