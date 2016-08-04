require 'rails_helper'
require 'ballot'

describe Ballot, type: :model do

  before(:all) do
    Ballot.delete_all
    @election = FactoryGirl.create(:election)
    @level = @election.level
    @office1 = FactoryGirl.create(:office, level: @level, filename: 'ballot_office_1')
    @office2 = FactoryGirl.create(:office, level: @level, filename: 'ballot_office_2')
    @office3 = FactoryGirl.create(:office, level: @level, filename: 'ballot_office_3')
    @other_level_office = FactoryGirl.create(:office, filename: 'other_level')
  end

  describe "acts_as_authority_controlled" do
    it "should be in the “Democracy” area" do
      expect(Ballot.authority_area).to eq 'Democracy'
    end
  end

  describe '#election' do
    it 'should allow an election to be set' do
      election = Election.new
      ballot = Ballot.new
      ballot.election = election
      expect( ballot.election ).to eq election
    end
  end

  describe '#office' do
    it 'should allow an office to be set' do
      office = Office.new
      ballot = Ballot.new
      ballot.office = office
      expect( ballot.office ).to eq office
    end
  end

  describe "validations" do
    let(:required) { $required = {} } # term_start_on: '2005-04-03'
    it "should validate with all required values" do
      ballot = @election.ballots.build(required)
      ballot.office = @office1
      expect( ballot.valid? ).to be_truthy
    end
    describe 'of election' do
      it 'should fail if election is not set' do
        ballot = Ballot.new(required)
        ballot.office = @office1
        expect( ballot.valid? ).to be_falsey
      end
    end
    describe 'of office' do
      it 'should fail if office is not set' do
        ballot = Ballot.new(required)
        ballot.office = @office1
        expect( ballot.valid? ).to be_falsey
      end
      it 'should fail if office is not the same level as the election' do
        ballot = @election.ballots.build(required)
        ballot.office = @other_level_office
        expect( ballot.valid? ).to be_falsey
      end
      it 'should fail if there is already a ballot for the office for the election' do
        existing_ballot = FactoryGirl.create(:ballot, election: @election, office: @office3)
        ballot = @election.ballots.build(required)
        ballot.office = @office3
        expect( ballot.valid? ).to be_falsey
      end
    end
    describe "of url" do
      it "should fail if url is not an url string" do
        ballot = @election.ballots.build(required.merge(url: 'not an url'))
        ballot.office = @office1
        expect( ballot.valid? ).to be_falsey
      end
      it "should pass if the url is a valid url" do
        ballot = @election.ballots.build(required.merge(url: 'https://valid.url:8080/should/pass'))
        ballot.office = @office1
        expect( ballot.valid? ).to be_truthy
      end
    end
    describe 'of term_end_on' do
      it 'should fail if term_end_on is before term_start_on' do
        ballot = @election.ballots.build(required.merge(term_start_on: '2001-02-03', term_end_on: '2001-02-02'))
        ballot.office = @office1
        expect( ballot.valid? ).to be_falsey
      end
    end
  end

  describe '#to_param' do
    it 'should return the office’s filename' do
      ballot = Ballot.new
      ballot.office = @office1
      expect( ballot.to_param ).to eq 'ballot_office_1'
    end
    it 'should return nil if there is no office' do
      ballot = Ballot.new
      expect( ballot.to_param ).to be_nil
    end
  end

  describe '#running_for' do
    it 'should return just the office title if it is the same as the office name' do
      ballot = Ballot.new
      ballot.office = Office.new(name: 'The Same', title: 'The Same')
      expect( ballot.running_for ).to eq 'The Same'
    end
    it 'should return the office title, “for”, and the office name, when title and name are different' do
      ballot = Ballot.new
      ballot.office = Office.new(name: 'Not The Same', title: 'Different')
      expect( ballot.running_for ).to eq 'Different for Not The Same'
    end
  end

  describe '#descriptor' do
    it 'should return the name of the office' do
      office = Office.new(name: 'The Name')
      ballot = office.ballots.build()
      ballot.office = office
      expect( ballot.descriptor ).to eq 'The Name'
    end
  end

  describe '#items_for_path' do
    it 'should return an array of the level, election and ballot' do
      level = Level.new
      election = level.elections.build
      election.level = level
      ballot = election.ballots.build
      ballot.election = election
      expect( ballot.items_for_path ).to eq [level, election, ballot]
    end
  end

end
