require 'rails_helper'
require 'candidate'

describe Candidate, type: :model do

  before(:all) do
    Candidate.delete_all
    Person.delete_all
    @ballot = FactoryGirl.create(:ballot)
    @person = FactoryGirl.create(:person, filename: 'candidate_person_1')
    @person2 = FactoryGirl.create(:person, filename: 'candidate_person_2')
  end

  describe "acts_as_authority_controlled" do
    it "should be in the “Democracy” area" do
      expect(Candidate.authority_area).to eq 'Democracy'
    end
  end

  describe '#ballot' do
    it 'should allow an ballot to be set' do
      ballot = Ballot.new
      candidate = Candidate.new
      candidate.ballot = ballot
      expect( candidate.ballot ).to eq ballot
    end
  end

  describe '#person' do
    it 'should allow an person to be set' do
      person = Person.new
      candidate = Candidate.new
      candidate.person = person
      expect( candidate.person ).to eq person
    end
  end

  describe '#party' do
    it 'should allow an party to be set' do
      party = Party.new
      candidate = Candidate.new
      candidate.party = party
      expect( candidate.party ).to eq party
    end
  end

  describe '#submitter' do
    it 'should allow a submitter to be set' do
      user = User.new
      candidate = Candidate.new
      candidate.submitter = user
      expect( candidate.submitter ).to eq user
    end
  end

  describe "validations" do
    let(:required) { $required = {filename: 'required', name: 'required'} }
    it "should validate with all required values" do
      candidate = @ballot.candidates.build(required)
      candidate.person = @person
      expect( candidate.valid? ).to be_truthy
    end
    describe 'of ballot' do
      it 'should fail if ballot is not set' do
        candidate = Candidate.new(required)
        candidate.person = @person
        expect( candidate.valid? ).to be_falsey
      end
    end
    describe 'of person' do
      it 'should fail if person is not set' do
        candidate = Candidate.new(required)
        candidate.person = @person
        expect( candidate.valid? ).to be_falsey
      end
      it 'should fail if there is already a candidate for the person for the ballot' do
        person = FactoryGirl.create(:person)
        existing_candidate = FactoryGirl.create(:candidate, ballot: @ballot, person: person)
        candidate = @ballot.candidates.build(required)
        candidate.person = person
        expect( candidate.valid? ).to be_falsey
      end
      it 'should validate if there is already a candidate for the person for a different ballot' do
        person = FactoryGirl.create(:person)
        different_ballot_candidacy = FactoryGirl.create(:candidate, person: person)
        candidate = @ballot.candidates.build(required)
        candidate.person = person
        expect( candidate.valid? ).to be_truthy
      end
    end
    describe "of filename" do
      let(:required) { $required = {name: 'Required'} }
      it 'should fail if filename is a duplicate for the ballot' do
        FactoryGirl.create(:candidate, ballot: @ballot, filename: 'duplicate-on-ballot')
        candidate = @ballot.candidates.build(required.merge(filename: 'duplicate-on-ballot'))
        candidate.person = @person
        expect( candidate.valid? ).to be_falsey
      end
      it 'should validate if filename is a duplicate, but not for the ballot' do
        FactoryGirl.create(:candidate, person: @person, filename: 'duplicate')
        candidate = @ballot.candidates.build(required.merge(filename: 'duplicate'))
        candidate.person = @person
        expect( candidate.valid? ).to be_truthy
      end
    end
    describe "of name" do
      let(:required) { $required = {filename: 'required'} }
      it 'should fail if name is a duplicate for the ballot' do
        FactoryGirl.create(:candidate, ballot: @ballot, name: 'Duplicate On Ballot')
        candidate = @ballot.candidates.build(required.merge(name: 'Duplicate On Ballot'))
        candidate.person = @person
        expect( candidate.valid? ).to be_falsey
      end
      it 'should validate if name is a duplicate, but not for the ballot' do
        FactoryGirl.create(:candidate, person: @person, name: 'Duplicate')
        candidate = @ballot.candidates.build(required.merge(name: 'Duplicate'))
        candidate.person = @person
        expect( candidate.valid? ).to be_truthy
      end
    end
  end

  describe 'scopes' do
    before(:all) do
      @ballot = FactoryGirl.create(:ballot)
      @scoped_candidate1 = FactoryGirl.create(:candidate,
        ballot: @ballot, name: 'DEF', vote_count: 345, quit_on: 1.month.ago.to_date
      )
      @scoped_candidate2 = FactoryGirl.create(:candidate,
        ballot: @ballot, name: 'GHI', vote_count: 123, filename: 'the_param'
      )
      @scoped_candidate3 = FactoryGirl.create(:candidate, ballot: @ballot, name: 'ABC', vote_count: 234)
    end
    describe '.by_name' do
      it 'should order the candidates by the name attribute in ascending order' do
        expect( @ballot.candidates.by_name.to_a ).to eq(
          [@scoped_candidate3, @scoped_candidate1, @scoped_candidate2]
        )
      end
    end
    describe '.by_vote_count' do
      it 'should order the candidates by the vote_count in descending order' do
        expect( @ballot.candidates.unscoped.by_vote_count.to_a ).to eq(
          [@scoped_candidate1, @scoped_candidate3, @scoped_candidate2]
        )
      end
    end
    describe '.from_param' do
      it 'should return the election that matches the param' do
        election = Candidate.where(filename: 'the_param').first
        unless election
          election = @level.elections.new(filename: 'the_param', name: 'Candidate From Param', end_on: '2002-03-04')
          election.save!
        end
        expect( Candidate.from_param('the_param') ).to eq [election]
      end
      it 'should return an empty list for a non-existent param' do
        expect( Candidate.from_param('non-existent-param') ).to eq []
      end
    end
    describe '.running' do
      it 'should be all the candidates that have not quit' do
        expect( @ballot.candidates.running.by_name.to_a ).to eq(
          [@scoped_candidate3, @scoped_candidate2]
        )
      end
    end
    describe '.not_running' do
      it 'should be all the candidates that have quit' do
        expect( @ballot.candidates.not_running.to_a ).to eq [@scoped_candidate1]
      end
    end
  end

  describe '#to_param' do
    it 'should return the filename' do
      expect( Candidate.new(filename: 'param').to_param ).to eq 'param'
    end
  end

  describe '#descriptor' do
    it 'should return the name' do
      candidate = Candidate.new(name: 'The Name')
      expect( candidate.descriptor ).to eq 'The Name'
    end
  end

  describe '#items_for_path' do
    it 'should return an array of the level, election, ballot and candidate' do
      level = Level.new
      election = level.elections.build
      election.level = level
      ballot = election.ballots.build
      ballot.election = election
      candidate = ballot.candidates.build
      candidate.ballot = ballot
      expect( candidate.items_for_path ).to eq [level, election, ballot, candidate]
    end
  end

end
