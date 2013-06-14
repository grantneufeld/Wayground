# encoding: utf-8
require 'spec_helper'
require 'filename_validator'

class SpecClassWithFilename
  include ActiveModel::Validations
  attr_accessor :filename
  validates :filename, filename: true
  def initialize(params={})
    self.filename = params[:filename]
  end
end

describe FilenameValidator do
  let(:filename) { $filename = 'an_example-with_everything_1' }
  let(:item) { $item = SpecClassWithFilename.new(filename: filename) }

  context 'with basic values' do
    it 'should be valid' do
      expect( item.valid? ).to be_true
    end
  end
  # /\A[a-z0-9_\-]+\z/
  context 'with lower-case letters' do
    let(:filename) { $filename = 'abcdefghijklmnopqrstuvwxyz' }
    it 'should be valid' do
      expect( item.valid? ).to be_true
    end
  end
  context 'with numeric digits' do
    let(:filename) { $filename = '0123456789' }
    it 'should be valid' do
      expect( item.valid? ).to be_true
    end
  end
  context 'with underscores' do
    let(:filename) { $filename = '_' }
    it 'should be valid' do
      expect( item.valid? ).to be_true
    end
  end
  context 'with dashes' do
    let(:filename) { $filename = '-' }
    it 'should be valid' do
      expect( item.valid? ).to be_true
    end
  end
  context 'with an upper-case letter' do
    let(:filename) { $filename = 'Abc' }
    it 'should be invalid' do
      expect( item.valid? ).to be_false
    end
  end
  context 'with an invalid value' do
    let(:filename) { $filename = 'invalid!' }
    it 'should be invalid' do
      expect( item.valid? ).to be_false
    end
    it "should report an error" do
      item.valid?
      expect( item.errors[:filename].present? ).to be_true
    end
  end

end
