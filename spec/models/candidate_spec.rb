# encoding: utf-8
require 'spec_helper'
require 'candidate'

describe Candidate do

  before(:all) do
    Candidate.delete_all
    Person.delete_all
    @ballot = FactoryGirl.create(:ballot)
    @person = FactoryGirl.create(:person, filename: 'candidate_person_1')
  end

  describe "acts_as_authority_controlled" do
    it "should be in the “Democracy” area" do
      Candidate.authority_area.should eq 'Democracy'
    end
  end

  describe "attribute mass assignment security" do
    it "should not allow election" do
      expect {
        Candidate.new(ballot: Ballot.new)
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
    it "should not allow ballot_id" do
      expect {
        Candidate.new(ballot_id: 1)
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
    it "should not allow person" do
      expect {
        Candidate.new(person: Person.new)
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
    it "should not allow person_id" do
      expect {
        Candidate.new(person_id: 1)
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
    it "should not allow party" do
      expect {
        Candidate.new(party: Party.new)
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
    it "should not allow party_id" do
      expect {
        Candidate.new(party_id: 1)
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
    it "should allow filename" do
      filename = 'example_filename'
      expect( Candidate.new(filename: filename).filename ).to eq filename
    end
    it "should allow name" do
      name = 'Example Name'
      expect( Candidate.new(name: name).name ).to eq name
    end
    it "should allow is_rumoured" do
      expect( Candidate.new(is_rumoured: true).is_rumoured ).to be_true
    end
    it "should allow is_confirmed" do
      expect( Candidate.new(is_confirmed: true).is_confirmed ).to be_true
    end
    it "should allow is_incumbent" do
      expect( Candidate.new(is_incumbent: true).is_incumbent ).to be_true
    end
    it "should allow is_leader" do
      expect( Candidate.new(is_leader: true).is_leader ).to be_true
    end
    it "should allow is_acclaimed" do
      expect( Candidate.new(is_acclaimed: true).is_acclaimed ).to be_true
    end
    it "should allow is_elected" do
      expect( Candidate.new(is_elected: true).is_elected ).to be_true
    end
    it "should allow announced_on" do
      announced_on = '2000-01-02'
      expect( Candidate.new(announced_on: announced_on).announced_on.to_s ).to eq announced_on
    end
    it "should allow quit_on" do
      quit_on = '2012-11-10'
      expect( Candidate.new(quit_on: quit_on).quit_on.to_s ).to eq quit_on
    end
    it "should allow vote_count" do
      vote_count = '123'
      expect( Candidate.new(vote_count: vote_count).vote_count ).to eq vote_count.to_i
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
      candidate = @ballot.candidates.new(required)
      candidate.person = @person
      expect( candidate.valid? ).to be_true
    end
    describe 'of ballot' do
      it 'should fail if ballot is not set' do
        candidate = Candidate.new(required)
        candidate.person = @person
        expect( candidate.valid? ).to be_false
      end
    end
    describe 'of person' do
      it 'should fail if person is not set' do
        candidate = Candidate.new(required)
        candidate.person = @person
        expect( candidate.valid? ).to be_false
      end
      it 'should fail if there is already a candidate for the person for the ballot' do
        person = FactoryGirl.create(:person)
        existing_candidate = FactoryGirl.create(:candidate, ballot: @ballot, person: person)
        candidate = @ballot.candidates.new(required)
        candidate.person = person
        expect( candidate.valid? ).to be_false
      end
      it 'should validate if there is already a candidate for the person for a different ballot' do
        person = FactoryGirl.create(:person)
        different_ballot_candidacy = FactoryGirl.create(:candidate, person: person)
        candidate = @ballot.candidates.new(required)
        candidate.person = person
        expect( candidate.valid? ).to be_true
      end
    end
    describe "of filename" do
      let(:required) { $required = {name: 'Required'} }
      it "should fail if filename is blank" do
        candidate = @ballot.candidates.new(required.merge(filename: ''))
        candidate.person = @person
        expect( candidate.valid? ).to be_false
      end
      it "should fail if filename is nil" do
        candidate = @ballot.candidates.new(required)
        candidate.person = @person
        expect( candidate.valid? ).to be_false
      end
      it 'should fail if filename is a duplicate for the ballot' do
        FactoryGirl.create(:candidate, ballot: @ballot, filename: 'duplicate-on-ballot')
        candidate = @ballot.candidates.new(required.merge(filename: 'duplicate-on-ballot'))
        candidate.person = @person
        expect( candidate.valid? ).to be_false
      end
      it 'should validate if filename is a duplicate, but not for the ballot' do
        FactoryGirl.create(:candidate, person: @person, filename: 'duplicate')
        candidate = @ballot.candidates.new(required.merge(filename: 'duplicate'))
        candidate.person = @person
        expect( candidate.valid? ).to be_true
      end
      it 'should fail if filename contains invalid characters' do
        candidate = @ballot.candidates.new(required.merge(filename: 'Has invalid characters!'))
        candidate.person = @person
        expect( candidate.valid? ).to be_false
      end
    end
    describe "of name" do
      let(:required) { $required = {filename: 'required'} }
      it "should fail if name is blank" do
        candidate = @ballot.candidates.new(required.merge(name: ''))
        candidate.person = @person
        expect( candidate.valid? ).to be_false
      end
      it "should fail if name is nil" do
        candidate = @ballot.candidates.new(required)
        candidate.person = @person
        expect( candidate.valid? ).to be_false
      end
      it 'should fail if name is a duplicate for the ballot' do
        FactoryGirl.create(:candidate, ballot: @ballot, name: 'Duplicate On Ballot')
        candidate = @ballot.candidates.new(required.merge(name: 'Duplicate On Ballot'))
        candidate.person = @person
        expect( candidate.valid? ).to be_false
      end
      it 'should validate if name is a duplicate, but not for the ballot' do
        FactoryGirl.create(:candidate, person: @person, name: 'Duplicate')
        candidate = @ballot.candidates.new(required.merge(name: 'Duplicate'))
        candidate.person = @person
        expect( candidate.valid? ).to be_true
      end
      it 'should fail if name contains invalid characters' do
        candidate = @ballot.candidates.new(required.merge(name: "Invalid\r"))
        candidate.person = @person
        expect( candidate.valid? ).to be_false
      end
    end
    describe 'of quit_on' do
      it 'should fail if quit_on is before announced_on' do
        candidate = @ballot.candidates.new(required.merge(announced_on: '2001-02-03', quit_on: '2001-02-02'))
        candidate.person = @person
        expect( candidate.valid? ).to be_false
      end
    end
  end

  describe 'scopes' do
    before(:all) do
      @ballot = FactoryGirl.create(:ballot)
      @scoped_candidate1 = FactoryGirl.create(:candidate, ballot: @ballot, name: 'DEF', vote_count: 345)
      @scoped_candidate2 = FactoryGirl.create(:candidate, ballot: @ballot, name: 'GHI', vote_count: 123)
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
        expect( @ballot.candidates.by_vote_count.to_a ).to eq(
          [@scoped_candidate1, @scoped_candidate3, @scoped_candidate2]
        )
      end
    end
  end

  describe '#to_param' do
    it 'should return the filename' do
      expect( Candidate.new(filename: 'param').to_param ).to eq 'param'
    end
  end

end
