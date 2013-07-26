# encoding: utf-8
require 'spec_helper'
require 'ballot'

describe Ballot do

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
      Ballot.authority_area.should eq 'Democracy'
    end
  end

  describe "attribute mass assignment security" do
    it "should not allow election" do
      expect {
        Ballot.new(election: Election.new)
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
    it "should not allow election_id" do
      expect {
        Ballot.new(election_id: 1)
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
    it "should not allow office" do
      expect {
        Ballot.new(office: Office.new)
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
    it "should not allow office_id" do
      expect {
        Ballot.new(office_id: 1)
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
    it "should allow term_start_on" do
      term_start_on = '2000-01-02'
      expect( Ballot.new(term_start_on: term_start_on).term_start_on.to_s ).to eq term_start_on
    end
    it "should allow term_end_on" do
      term_end_on = '2012-11-10'
      expect( Ballot.new(term_end_on: term_end_on).term_end_on.to_s ).to eq term_end_on
    end
    it "should allow is_byelection" do
      expect( Ballot.new(is_byelection: true).is_byelection ).to be_true
    end
    it "should allow url" do
      url = 'http://example.url/'
      expect( Ballot.new(url: url).url ).to eq url
    end
    it "should allow description" do
      description = 'Example Description'
      expect( Ballot.new(description: description).description ).to eq description
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
      expect( ballot.valid? ).to be_true
    end
    describe 'of election' do
      it 'should fail if election is not set' do
        ballot = Ballot.new(required)
        ballot.office = @office1
        expect( ballot.valid? ).to be_false
      end
    end
    describe 'of office' do
      it 'should fail if office is not set' do
        ballot = Ballot.new(required)
        ballot.office = @office1
        expect( ballot.valid? ).to be_false
      end
      it 'should fail if office is not the same level as the election' do
        ballot = @election.ballots.build(required)
        ballot.office = @other_level_office
        expect( ballot.valid? ).to be_false
      end
      it 'should fail if there is already a ballot for the office for the election' do
        existing_ballot = FactoryGirl.create(:ballot, election: @election, office: @office3)
        ballot = @election.ballots.build(required)
        ballot.office = @office3
        expect( ballot.valid? ).to be_false
      end
    end
    describe "of url" do
      it "should fail if url is not an url string" do
        ballot = @election.ballots.build(required.merge(url: 'not an url'))
        ballot.office = @office1
        expect( ballot.valid? ).to be_false
      end
      it "should pass if the url is a valid url" do
        ballot = @election.ballots.build(required.merge(url: 'https://valid.url:8080/should/pass'))
        ballot.office = @office1
        expect( ballot.valid? ).to be_true
      end
    end
    describe 'of term_end_on' do
      it 'should fail if term_end_on is before term_start_on' do
        ballot = @election.ballots.build(required.merge(term_start_on: '2001-02-03', term_end_on: '2001-02-02'))
        ballot.office = @office1
        expect( ballot.valid? ).to be_false
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

end
