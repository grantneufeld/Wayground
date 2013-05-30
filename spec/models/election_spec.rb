# encoding: utf-8
require 'spec_helper'
require 'election'

describe Election do

  before(:all) do
    Election.delete_all
    @level = Level.first || FactoryGirl.create(:level)
    @level2 = Level.offset(1).first || FactoryGirl.create(:level)
    @level_with_lots = FactoryGirl.create(:level)
    @election3 = FactoryGirl.create(:election, level: @level_with_lots, end_on: '2013-12-11')
    @election2 = FactoryGirl.create(:election, level: @level_with_lots, end_on: '2009-09-09')
    @election4 = FactoryGirl.create(:election, level: @level_with_lots, end_on: '2023-04-05')
    @election1 = FactoryGirl.create(:election, level: @level_with_lots, end_on: '2001-01-01')
  end

  describe "acts_as_authority_controlled" do
    it "should be in the “Democracy” area" do
      Election.authority_area.should eq 'Democracy'
    end
  end

  describe "attribute mass assignment security" do
    it "should not allow level" do
      expect {
        Election.new(level: Level.new)
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
    it "should not allow level_id" do
      expect {
        Election.new(level_id: 1)
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
    it "should allow filename" do
      filename = 'example-filename'
      expect( Election.new(filename: filename).filename ).to eq filename
    end
    it "should allow name" do
      name = 'Example Name'
      expect( Election.new(name: name).name ).to eq name
    end
    it "should allow start_on" do
      start_on = '2000-01-02'
      expect( Election.new(start_on: start_on).start_on.to_s ).to eq start_on
    end
    it "should allow end_on" do
      end_on = '2012-11-10'
      expect( Election.new(end_on: end_on).end_on.to_s ).to eq end_on
    end
    it "should allow description" do
      description = 'Example Description'
      expect( Election.new(description: description).description ).to eq description
    end
    it "should allow url" do
      url = 'http://example.url/'
      expect( Election.new(url: url).url ).to eq url
    end
  end

  describe '#level' do
    it 'should allow a level to be set' do
      level = Level.new
      election = Election.new
      election.level = level
      expect( election.level ).to eq level
    end
  end

  describe "validations" do
    let(:required) { $required = {filename: 'required', name: 'Required', end_on: '2004-05-06'} }
    it "should validate with all required values" do
      expect( @level.elections.new(required).valid? ).to be_true
    end
    describe 'of level' do
      it 'should fail if level is not set' do
        expect( Election.new(required).valid? ).to be_false
      end
    end
    describe "of filename" do
      let(:required) { $required = {name: 'Required', end_on: '2006-07-08'} }
      it "should fail if filename is blank" do
        expect( @level.elections.new(required.merge(filename: '')).valid? ).to be_false
      end
      it "should fail if filename is nil" do
        expect( @level.elections.new(required).valid? ).to be_false
      end
      it 'should fail if filename is a duplicate for the level' do
        @level.elections.new(name: 'Duplicate for level', filename: 'duplicate-on-level', end_on: '2003-04-05').save!
        expect( @level.elections.new(required.merge(filename: 'duplicate-on-level')).valid? ).to be_false
      end
      it 'should validate if filename is a duplicate, but not for the level' do
        @level2.elections.new(name: 'Original', filename: 'duplicate', end_on: '2003-04-05').save!
        expect( @level.elections.new(required.merge(filename: 'duplicate')).valid? ).to be_true
      end
      it 'should fail if filename contains invalid characters' do
        expect( @level.elections.new(required.merge(filename: 'Has invalid characters!')).valid? ).to be_false
      end
    end
    describe "of name" do
      let(:required) { $required = {filename: 'required', end_on: '2007-08-09'} }
      it "should fail if name is blank" do
        expect( @level.elections.new(required.merge(name: '')).valid? ).to be_false
      end
      it "should fail if name is nil" do
        expect( @level.elections.new(required).valid? ).to be_false
      end
      it 'should fail if name is a duplicate for the level' do
        @level.elections.new(name: 'Duplicate', filename: 'duplicate-on-level', end_on: '2003-04-05').save!
        expect( @level.elections.new(required.merge(name: 'Duplicate')).valid? ).to be_false
      end
      it 'should validate if name is a duplicate, but not for the level' do
        @level2.elections.new(name: 'Duplicate', filename: 'duplicate-not-for-level', end_on: '2003-04-05').save!
        expect( @level.elections.new(required.merge(name: 'Duplicate')).valid? ).to be_true
      end
    end
    describe "of url" do
      it "should fail if url is not an url string" do
        expect( @level.elections.new(required.merge(url: 'not an url')).valid? ).to be_false
      end
      it "should pass if the url is a valid url" do
        election = @level.elections.new(required.merge(url: 'https://valid.url:8080/should/pass'))
        expect( election.valid? ).to be_true
      end
    end
    describe 'of end_on' do
      it 'should fail if end_on is not set' do
        expect( @level.elections.new(required.merge(end_on: '')).valid? ).to be_false
      end
      it 'should fail if end_on is before start_on' do
        params = required.merge(start_on: '2001-02-03', end_on: '2001-02-02')
        expect( @level.elections.new(params).valid? ).to be_false
      end
    end
  end

  describe 'scopes' do
    describe '.from_param' do
      it 'should return the election that matches the param' do
        election = Election.where(filename: 'the_param').first
        unless election
          election = @level.elections.new(filename: 'the_param', name: 'Election From Param', end_on: '2002-03-04')
          election.save!
        end
        expect( Election.from_param('the_param') ).to eq [election]
      end
      it 'should return an empty list for a non-existent param' do
        expect( Election.from_param('non-existent-param') ).to eq []
      end
    end
    describe '.order_by_date' do
      it 'should return the elections sorted in ascending order by end date' do
        elections = @level_with_lots.elections.order_by_date
        expect( elections ).to eq [@election1, @election2, @election3, @election4]
      end
    end
    describe '.upcoming' do
      it 'should return the elections that occur on or after the date today' do
        Date.stub(:today).and_return(Date.parse('2013-12-11'))
        elections = @level_with_lots.elections.upcoming.order_by_date
        expect( elections ).to eq [@election3, @election4]
      end
    end
  end

  describe '.current' do
    it 'should return the next election that ends on or after the date today' do
      Date.stub(:today).and_return(Date.parse('2013-12-11'))
      expect( Election.current ).to eq @election3
    end
    it 'should return the last election if the date today is after any of the elections' do
      Date.stub(:today).and_return(Date.parse('2111-11-11'))
      expect( Election.current ).to eq @election4
    end
  end

  describe '.current_for_level' do
    it 'should return the next election that ends on or after the date today' do
      Date.stub(:today).and_return(Date.parse('2013-12-11'))
      expect( Election.current_for_level(@level_with_lots) ).to eq @election3
    end
    it 'should return the last election if the date today is after any of the elections' do
      Date.stub(:today).and_return(Date.parse('2111-11-11'))
      expect( Election.current_for_level(@level_with_lots) ).to eq @election4
    end
  end

  describe '#to_param' do
    it 'should return the filename' do
      expect( Election.new(filename: 'param').to_param ).to eq 'param'
    end
  end

end
