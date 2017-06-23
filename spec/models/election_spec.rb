require 'rails_helper'
require 'election'

describe Election, type: :model do
  before(:all) do
    Election.delete_all
    Level.delete_all
    @level = FactoryGirl.create(:level)
    @level2 = FactoryGirl.create(:level)
    @level_with_lots = FactoryGirl.create(:level)
    @election3 = FactoryGirl.create(:election, level: @level_with_lots, end_on: '2013-12-11')
    @election2 = FactoryGirl.create(:election, level: @level_with_lots, end_on: '2009-09-09')
    @election4 = FactoryGirl.create(:election, level: @level_with_lots, end_on: '2023-04-05')
    @election1 = FactoryGirl.create(:election, level: @level_with_lots, end_on: '2001-01-01')
  end

  describe 'acts_as_authority_controlled' do
    it 'should be in the “Democracy” area' do
      expect(Election.authority_area).to eq 'Democracy'
    end
  end

  describe '#level' do
    it 'should allow a level to be set' do
      level = Level.new
      election = Election.new
      election.level = level
      expect(election.level).to eq level
    end
  end

  describe 'validations' do
    let(:required) { $required = { filename: 'required', name: 'Required', end_on: '2004-05-06' } }
    it 'should validate with all required values' do
      expect(@level.elections.build(required).valid?).to be_truthy
    end
    describe 'of level' do
      it 'should fail if level is not set' do
        expect(Election.new(required).valid?).to be_falsey
      end
    end
    describe 'of filename' do
      let(:required) { $required = { name: 'Required', end_on: '2006-07-08' } }
      it 'should fail if filename is blank' do
        expect(@level.elections.build(required.merge(filename: '')).valid?).to be_falsey
      end
      it 'should fail if filename is nil' do
        expect(@level.elections.build(required).valid?).to be_falsey
      end
      it 'should fail if filename is a duplicate for the level' do
        @level.elections.build(
          name: 'Duplicate for level', filename: 'duplicate-on-level', end_on: '2003-04-05'
        ).save!
        expect(@level.elections.build(required.merge(filename: 'duplicate-on-level')).valid?).to be_falsey
      end
      it 'should validate if filename is a duplicate, but not for the level' do
        @level2.elections.build(name: 'Original', filename: 'duplicate', end_on: '2003-04-05').save!
        expect(@level.elections.build(required.merge(filename: 'duplicate')).valid?).to be_truthy
      end
      it 'should fail if filename contains invalid characters' do
        new_election = @level.elections.build(required.merge(filename: 'Has invalid characters!'))
        expect(new_election.valid?).to be_falsey
      end
    end
    describe 'of name' do
      let(:required) { $required = { filename: 'required', end_on: '2007-08-09' } }
      it 'should fail if name is blank' do
        expect(@level.elections.build(required.merge(name: '')).valid?).to be_falsey
      end
      it 'should fail if name is nil' do
        expect(@level.elections.build(required).valid?).to be_falsey
      end
      it 'should fail if name is a duplicate for the level' do
        @level.elections.build(
          name: 'Duplicate', filename: 'duplicate-on-level', end_on: '2003-04-05'
        ).save!
        expect(@level.elections.build(required.merge(name: 'Duplicate')).valid?).to be_falsey
      end
      it 'should validate if name is a duplicate, but not for the level' do
        @level2.elections.build(
          name: 'Duplicate', filename: 'duplicate-not-for-level', end_on: '2003-04-05'
        ).save!
        expect(@level.elections.build(required.merge(name: 'Duplicate')).valid?).to be_truthy
      end
    end
    describe 'of url' do
      it 'should fail if url is not an url string' do
        expect(@level.elections.build(required.merge(url: 'not an url')).valid?).to be_falsey
      end
      it 'should pass if the url is a valid url' do
        election = @level.elections.build(required.merge(url: 'https://valid.url:8080/should/pass'))
        expect(election.valid?).to be_truthy
      end
    end
    describe 'of end_on' do
      it 'should fail if end_on is not set' do
        expect(@level.elections.build(required.merge(end_on: '')).valid?).to be_falsey
      end
      it 'should fail if end_on is before start_on' do
        params = required.merge(start_on: '2001-02-03', end_on: '2001-02-02')
        expect(@level.elections.build(params).valid?).to be_falsey
      end
    end
  end

  describe 'scopes' do
    describe '.from_param' do
      it 'should return the election that matches the param' do
        election = Election.where(filename: 'the_param').first
        unless election
          election = @level.elections.build(
            filename: 'the_param', name: 'Election From Param', end_on: '2002-03-04'
          )
          election.save!
        end
        expect(Election.from_param('the_param')).to eq [election]
      end
      it 'should return an empty list for a non-existent param' do
        expect(Election.from_param('non-existent-param')).to eq []
      end
    end
    describe '.order_by_date' do
      it 'should return the elections sorted in ascending order by end date' do
        elections = @level_with_lots.elections.order_by_date
        expect(elections).to eq [@election1, @election2, @election3, @election4]
      end
    end
    describe '.upcoming' do
      it 'should return the elections that occur on or after the date today' do
        allow(Time).to receive_message_chain(:zone, :today, :to_date).and_return(Date.parse('2013-12-11'))
        elections = @level_with_lots.elections.upcoming.order_by_date
        expect(elections).to eq [@election3, @election4]
      end
    end
  end

  describe '.current' do
    it 'should return the next election that ends on or after the date today' do
      allow(Time).to receive_message_chain(:zone, :today, :to_date).and_return(Date.parse('2013-12-11'))
      expect(Election.current).to eq @election3
    end
    it 'should return the last election if the date today is after any of the elections' do
      allow(Time).to receive_message_chain(:zone, :today, :to_date).and_return(Date.parse('2111-11-11'))
      expect(Election.current).to eq @election4
    end
  end

  describe '.current_for_level' do
    it 'should return the next election that ends on or after the date today' do
      allow(Time).to receive_message_chain(:zone, :today, :to_date).and_return(Date.parse('2013-12-11'))
      expect(Election.current_for_level(@level_with_lots)).to eq @election3
    end
    it 'should return the last election if the date today is after any of the elections' do
      allow(Time).to receive_message_chain(:zone, :today, :to_date).and_return(Date.parse('2111-11-11'))
      expect(Election.current_for_level(@level_with_lots)).to eq @election4
    end
  end

  describe '#to_param' do
    it 'should return the filename' do
      expect(Election.new(filename: 'param').to_param).to eq 'param'
    end
  end

  describe '#descriptor' do
    it 'should return the name' do
      election = Election.new(name: 'The Name')
      expect(election.descriptor).to eq 'The Name'
    end
  end

  describe '#items_for_path' do
    it 'should return an array of the level and self' do
      level = Level.new
      election = level.elections.build
      election.level = level
      expect(election.items_for_path).to eq [level, election]
    end
  end
end
