require 'rails_helper'
require 'party'

describe Party, type: :model do

  before(:all) do
    Party.delete_all
    @level = Level.first || FactoryGirl.create(:level)
    @level2 = Level.offset(1).first || FactoryGirl.create(:level)
  end

  describe 'acts_as_authority_controlled' do
    it 'should be in the “Democracy” area' do
      expect(Party.authority_area).to eq 'Democracy'
    end
  end

  describe '#level' do
    it 'should allow a level to be set' do
      level = Level.new
      party = Party.new
      party.level = level
      expect( party.level ).to eq level
    end
  end

  describe 'validations' do
    before(:all) do
      @level.parties.build(name: 'Duplicate for level', filename: 'duplicate-on-level', abbrev: 'dupe').save!
      @level2.parties.build(name: 'Duplicate on Other', filename: 'duplicate-on-other', abbrev: 'dup2').save!
    end
    let(:required) { $required = {filename: 'required', name: 'Required', abbrev: 'Req'} }
    it 'should validate with all required values' do
      expect( @level.parties.build(required).valid? ).to be_truthy
    end
    describe 'of level' do
      it 'should fail if level is not set' do
        expect( Party.new(required).valid? ).to be_falsey
      end
    end
    describe 'of filename' do
      let(:required) { $required = {name: 'Required', abbrev: 'Req'} }
      it 'should fail if filename is blank' do
        expect( @level.parties.build(required.merge(filename: '')).valid? ).to be_falsey
      end
      it 'should fail if filename is nil' do
        expect( @level.parties.build(required).valid? ).to be_falsey
      end
      it 'should fail if filename is a duplicate for the level' do
        expect( @level.parties.build(required.merge(filename: 'duplicate-on-level')).valid? ).to be_falsey
      end
      it 'should validate if filename is a duplicate, but not for the level' do
        expect( @level.parties.build(required.merge(filename: 'duplicate-on-other')).valid? ).to be_truthy
      end
      it 'should fail if filename contains invalid characters' do
        expect( @level.parties.build(required.merge(filename: 'Has invalid characters!')).valid? ).to be_falsey
      end
    end
    describe 'of name' do
      let(:required) { $required = {filename: 'required', abbrev: 'Req'} }
      it 'should fail if name is blank' do
        expect( @level.parties.build(required.merge(name: '')).valid? ).to be_falsey
      end
      it 'should fail if name is nil' do
        expect( @level.parties.build(required).valid? ).to be_falsey
      end
      it 'should fail if name is a duplicate for the level' do
        expect( @level.parties.build(required.merge(name: 'Duplicate for level')).valid? ).to be_falsey
      end
      it 'should validate if name is a duplicate, but not for the level' do
        expect( @level.parties.build(required.merge(name: 'Duplicate on Other')).valid? ).to be_truthy
      end
    end
    describe 'of abbrev' do
      let(:required) { $required = {name: 'Required', filename: 'required'} }
      it 'should fail if abbrev is blank' do
        expect( @level.parties.build(required.merge(abbrev: '')).valid? ).to be_falsey
      end
      it 'should fail if abbrev is nil' do
        expect( @level.parties.build(required).valid? ).to be_falsey
      end
      it 'should fail if abbrev is a duplicate for the level' do
        expect( @level.parties.build(required.merge(abbrev: 'dupe')).valid? ).to be_falsey
      end
      it 'should validate if abbrev is a duplicate, but not for the level' do
        expect( @level.parties.build(required.merge(abbrev: 'dup2')).valid? ).to be_truthy
      end
    end
    describe 'of colour' do
      it 'should validate if colour is a blank value' do
        expect( @level.parties.build(required.merge(colour: '')).valid? ).to be_truthy
      end
      it 'should validate if colour is a hexadecimal value' do
        expect( @level.parties.build(required.merge(colour: '#ABCDEF')).valid? ).to be_truthy
      end
      it 'should validate if colour is a named colour value' do
        expect( @level.parties.build(required.merge(colour: 'purple')).valid? ).to be_truthy
      end
      it 'should fail if colour is an invalid value' do
        expect( @level.parties.build(required.merge(colour: 'invalid')).valid? ).to be_falsey
      end
    end
    describe 'of url' do
      it 'should fail if url is not an url string' do
        expect( @level.parties.build(required.merge(url: 'not an url')).valid? ).to be_falsey
      end
      it 'should pass if the url is a valid url' do
        level = @level.parties.build(required.merge(url: 'https://valid.url:8080/should/pass')).valid?
        expect( level ).to be_truthy
      end
    end
    describe 'of registered_on' do
      it 'should fail if registered_on is before established_on' do
        params = required.merge(established_on: '2002-03-04', registered_on: '2002-03-03')
        expect( @level.parties.build(params).valid? ).to be_falsey
      end
    end
    describe 'of ended_on' do
      it 'should fail if ended_on is before established_on' do
        params = required.merge(established_on: '2001-02-03', ended_on: '2001-02-02')
        expect( @level.parties.build(params).valid? ).to be_falsey
      end
      it 'should fail if ended_on is before registered_on' do
        params = required.merge(registered_on: '2003-04-05', ended_on: '2003-04-04')
        expect( @level.parties.build(params).valid? ).to be_falsey
      end
    end
  end

  describe 'scopes' do
    before(:all) do
      @level = FactoryGirl.create(:level)
      @scoped_party4 = FactoryGirl.create(:party, level: @level, name: '4 Jkl')
      @scoped_party2 = FactoryGirl.create(:party, level: @level, name: '2 Def')
      @scoped_party3 = FactoryGirl.create(:party, level: @level, name: '3 Ghi', filename: '3_ghi')
      @scoped_party1 = FactoryGirl.create(:party, level: @level, name: '1 Abc')
    end
    describe '.from_param' do
      it 'should return the election that matches the param' do
        expect( @level.parties.from_param('3_ghi') ).to eq [@scoped_party3]
      end
      it 'should return an empty list for a non-existent param' do
        expect( @level.parties.from_param('non-existent-param') ).to eq []
      end
    end
    describe '.by_name' do
      it 'should order the parties by the name attribute in ascending order' do
        expect( @level.parties.by_name ).to eq [@scoped_party1, @scoped_party2, @scoped_party3, @scoped_party4]
      end
    end
  end

  describe '#to_param' do
    it 'should return the filename' do
      expect( Party.new(filename: 'param').to_param ).to eq 'param'
    end
  end

end