require 'spec_helper'
require 'email_validator'

class SpecClassWithEmail
  include ActiveModel::Validations
  attr_accessor :email
  validates :email, email: true
  def initialize(params = {})
    self.email = params[:email]
  end
end

describe EmailValidator do
  let(:email) { $email = 'an-example+email@an-address.tld' }
  let(:item) { $item = SpecClassWithEmail.new(email: email) }

  context 'with basic values' do
    it 'should be valid' do
      expect(item.valid?).to be_truthy
    end
  end
  context 'with mixed-case letters' do
    let(:email) { $email = 'AMixedCase@Email.Address' }
    it 'should be valid' do
      expect(item.valid?).to be_truthy
    end
  end
  context 'with numeric digits' do
    let(:email) { $email = '0123456789@test.tld' }
    it 'should be valid' do
      expect(item.valid?).to be_truthy
    end
  end
  context 'with underscores' do
    let(:email) { $email = 'email_address@test.tld' }
    it 'should be valid' do
      expect(item.valid?).to be_truthy
    end
  end
  context 'with dashes' do
    let(:email) { $email = 'dashed-email@test.tld' }
    it 'should be valid' do
      expect(item.valid?).to be_truthy
    end
  end
  context 'with a plus sign' do
    let(:email) { $email = 'email+plus@test.tld' }
    it 'should be valid' do
      expect(item.valid?).to be_truthy
    end
  end
  context 'with a nil value' do
    let(:email) { $email = nil }
    it 'should be invalid' do
      expect(item.valid?).to be_falsey
    end
    it 'should report an error' do
      item.valid?
      expect(item.errors[:email].present?).to be_truthy
    end
  end
  context 'with a blank value' do
    let(:email) { $email = '' }
    it 'should be invalid' do
      expect(item.valid?).to be_falsey
    end
    it 'should report an error' do
      item.valid?
      expect(item.errors[:email].present?).to be_truthy
    end
  end
  context 'with an invalid value' do
    let(:email) { $email = 'invalid!' }
    it 'should be invalid' do
      expect(item.valid?).to be_falsey
    end
    it 'should report an error' do
      item.valid?
      expect(item.errors[:email].present?).to be_truthy
    end
  end
end
