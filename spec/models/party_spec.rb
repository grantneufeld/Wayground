# encoding: utf-8
require 'spec_helper'
require 'party'

describe Party do

  before(:all) do
    Party.delete_all
    @level = Level.first || FactoryGirl.create(:level)
    @level2 = Level.offset(1).first || FactoryGirl.create(:level)
  end

  describe 'acts_as_authority_controlled' do
    it 'should be in the “Democracy” area' do
      Party.authority_area.should eq 'Democracy'
    end
  end

  describe 'attribute mass assignment security' do
    it 'should not allow level' do
      expect {
        Party.new(level: Level.new)
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
    it 'should not allow level_id' do
      expect {
        Party.new(level_id: 1)
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
    it 'should allow filename' do
      filename = 'example-filename'
      expect( Party.new(filename: filename).filename ).to eq filename
    end
    it 'should allow name' do
      name = 'Example Name'
      expect( Party.new(name: name).name ).to eq name
    end
    it 'should allow aliases' do
      aliases = ['A.K.A.', 'Nick-Name']
      expect( Party.new(aliases: aliases).aliases ).to eq aliases
    end
    it 'should allow abbrev' do
      abbrev = 'Examp.'
      expect( Party.new(abbrev: abbrev).abbrev ).to eq abbrev
    end
    it 'should allow is_registered' do
      expect( Party.new(is_registered: true).is_registered ).to be_true
    end
    it 'should allow colour' do
      colour = '#abc123'
      expect( Party.new(colour: colour).colour ).to eq colour
    end
    it 'should allow url' do
      url = 'http://example.url/'
      expect( Party.new(url: url).url ).to eq url
    end
    it 'should allow description' do
      description = 'Example description.'
      expect( Party.new(description: description).description ).to eq description
    end
    it 'should allow established_on' do
      established_on = '2000-01-02'
      expect( Party.new(established_on: established_on).established_on.to_s ).to eq established_on
    end
    it 'should allow registered_on' do
      registered_on = '2001-02-03'
      expect( Party.new(registered_on: registered_on).registered_on.to_s ).to eq registered_on
    end
    it 'should allow ended_on' do
      ended_on = '2012-11-10'
      expect( Party.new(ended_on: ended_on).ended_on.to_s ).to eq ended_on
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
      expect( @level.parties.build(required).valid? ).to be_true
    end
    describe 'of level' do
      it 'should fail if level is not set' do
        expect( Party.new(required).valid? ).to be_false
      end
    end
    describe 'of filename' do
      let(:required) { $required = {name: 'Required', abbrev: 'Req'} }
      it 'should fail if filename is blank' do
        expect( @level.parties.build(required.merge(filename: '')).valid? ).to be_false
      end
      it 'should fail if filename is nil' do
        expect( @level.parties.build(required).valid? ).to be_false
      end
      it 'should fail if filename is a duplicate for the level' do
        expect( @level.parties.build(required.merge(filename: 'duplicate-on-level')).valid? ).to be_false
      end
      it 'should validate if filename is a duplicate, but not for the level' do
        expect( @level.parties.build(required.merge(filename: 'duplicate-on-other')).valid? ).to be_true
      end
      it 'should fail if filename contains invalid characters' do
        expect( @level.parties.build(required.merge(filename: 'Has invalid characters!')).valid? ).to be_false
      end
    end
    describe 'of name' do
      let(:required) { $required = {filename: 'required', abbrev: 'Req'} }
      it 'should fail if name is blank' do
        expect( @level.parties.build(required.merge(name: '')).valid? ).to be_false
      end
      it 'should fail if name is nil' do
        expect( @level.parties.build(required).valid? ).to be_false
      end
      it 'should fail if name is a duplicate for the level' do
        expect( @level.parties.build(required.merge(name: 'Duplicate for level')).valid? ).to be_false
      end
      it 'should validate if name is a duplicate, but not for the level' do
        expect( @level.parties.build(required.merge(name: 'Duplicate on Other')).valid? ).to be_true
      end
    end
    describe 'of abbrev' do
      let(:required) { $required = {name: 'Required', filename: 'required'} }
      it 'should fail if abbrev is blank' do
        expect( @level.parties.build(required.merge(abbrev: '')).valid? ).to be_false
      end
      it 'should fail if abbrev is nil' do
        expect( @level.parties.build(required).valid? ).to be_false
      end
      it 'should fail if abbrev is a duplicate for the level' do
        expect( @level.parties.build(required.merge(abbrev: 'dupe')).valid? ).to be_false
      end
      it 'should validate if abbrev is a duplicate, but not for the level' do
        expect( @level.parties.build(required.merge(abbrev: 'dup2')).valid? ).to be_true
      end
    end
    describe 'of colour' do
      it 'should validate if colour is a blank value' do
        expect( @level.parties.build(required.merge(colour: '')).valid? ).to be_true
      end
      it 'should validate if colour is a hexadecimal value' do
        expect( @level.parties.build(required.merge(colour: '#ABCDEF')).valid? ).to be_true
      end
      it 'should validate if colour is a named colour value' do
        expect( @level.parties.build(required.merge(colour: 'purple')).valid? ).to be_true
      end
      it 'should fail if colour is an invalid value' do
        expect( @level.parties.build(required.merge(colour: 'invalid')).valid? ).to be_false
      end
    end
    describe 'of url' do
      it 'should fail if url is not an url string' do
        expect( @level.parties.build(required.merge(url: 'not an url')).valid? ).to be_false
      end
      it 'should pass if the url is a valid url' do
        level = @level.parties.build(required.merge(url: 'https://valid.url:8080/should/pass')).valid?
        expect( level ).to be_true
      end
    end
    describe 'of registered_on' do
      it 'should fail if registered_on is before established_on' do
        params = required.merge(established_on: '2002-03-04', registered_on: '2002-03-03')
        expect( @level.parties.build(params).valid? ).to be_false
      end
    end
    describe 'of ended_on' do
      it 'should fail if ended_on is before established_on' do
        params = required.merge(established_on: '2001-02-03', ended_on: '2001-02-02')
        expect( @level.parties.build(params).valid? ).to be_false
      end
      it 'should fail if ended_on is before registered_on' do
        params = required.merge(registered_on: '2003-04-05', ended_on: '2003-04-04')
        expect( @level.parties.build(params).valid? ).to be_false
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
