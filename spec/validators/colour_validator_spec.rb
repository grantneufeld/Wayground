require 'spec_helper'
require 'colour_validator'

class SpecClassWithColour
  include ActiveModel::Validations
  attr_accessor :colour
  validates :colour, colour: true
  def initialize(params={})
    self.colour = params[:colour]
  end
end

describe ColourValidator do
  let(:colour) { $colour = '#123ABC' }
  let(:item) { $item = SpecClassWithColour.new(colour: colour) }

  context 'with basic values' do
    it 'should be valid' do
      expect( item.valid? ).to be_true
    end
  end
  context 'with a 7-digit hexadecimal colour value' do
    let(:colour) { $colour = '#7654321' }
    it 'should be invalid' do
      expect( item.valid? ).to be_false
    end
  end
  context 'with a 6-digit hexadecimal colour value' do
    let(:colour) { $colour = '#ABCDEF' }
    it 'should be valid' do
      expect( item.valid? ).to be_true
    end
  end
  context 'with a 5-digit hexadecimal colour value' do
    let(:colour) { $colour = '#54321' }
    it 'should be invalid' do
      expect( item.valid? ).to be_false
    end
  end
  context 'with a 4-digit hexadecimal colour value' do
    let(:colour) { $colour = '#4321' }
    it 'should be invalid' do
      expect( item.valid? ).to be_false
    end
  end
  context 'with a 3-digit hexadecimal colour value' do
    let(:colour) { $colour = '#ABC' }
    it 'should be valid' do
      expect( item.valid? ).to be_true
    end
  end
  context 'with a 2-digit hexadecimal colour value' do
    let(:colour) { $colour = '#21' }
    it 'should be invalid' do
      expect( item.valid? ).to be_false
    end
  end
  context 'with aqua' do
    let(:colour) { $colour = 'aqua' }
    it 'should be valid' do
      expect( item.valid? ).to be_true
    end
  end
  #... black blue cyan fuchsia gray green lime magenta ...
  context 'with maroon' do
    let(:colour) { $colour = 'maroon' }
    it 'should be valid' do
      expect( item.valid? ).to be_true
    end
  end
  #... navy olive purple red silver teal white ...
  context 'with yellow' do
    let(:colour) { $colour = 'yellow' }
    it 'should be valid' do
      expect( item.valid? ).to be_true
    end
  end
  context 'with an invalid value' do
    let(:colour) { $colour = 'invalid' }
    it 'should be invalid' do
      expect( item.valid? ).to be_false
    end
    it "should report an error" do
      item.valid?
      expect( item.errors[:colour].present? ).to be_true
    end
  end

end
