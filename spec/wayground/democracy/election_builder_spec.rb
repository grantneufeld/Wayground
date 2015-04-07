# encoding: utf-8
require 'spec_helper'
require 'democracy/election_builder'
require 'event/events_by_date'
require 'event'

describe Wayground::Democracy::ElectionBuilder do

  describe "initialization" do
    let(:election) { $election ||= Election.new }
    let(:term_start_on) { $term_start_on ||= Time.zone.now }
    let(:term_end_on) { $term_end_on ||= Time.zone.now }
    it "should accept an election" do
      builder = Wayground::Democracy::ElectionBuilder.new(election: election)
      expect( builder.election ).to eq(election)
    end
    it "should accept a term_start_on" do
      builder = Wayground::Democracy::ElectionBuilder.new(term_start_on: term_start_on)
      expect( builder.term_start_on ).to eq(term_start_on)
    end
    it "should accept a term_end_on" do
      builder = Wayground::Democracy::ElectionBuilder.new(term_end_on: term_end_on)
      expect( builder.term_end_on ).to eq(term_end_on)
    end
  end

  describe '#generate_ballots' do
    it 'should create ballots for an election' do
      level = FactoryGirl.create(:level)
      office1 = FactoryGirl.create(:office, level: level)
      office2 = FactoryGirl.create(:office, level: level)
      office3 = FactoryGirl.create(:office, level: level)
      election = FactoryGirl.create(:election, level: level)
      builder = Wayground::Democracy::ElectionBuilder.new(election: election)
      new_ballots = []
      expect { new_ballots = builder.generate_ballots }.to change(Ballot, :count).by(3)
      expect(new_ballots.size).to eq 3
    end
  end

  describe '#offices_to_add_ballots_for' do
    context 'with no ballots for the election yet' do
      it 'should include all the level’s offices' do
        election = double('election')
        allow(election).to receive_message_chain(:ballots) { [] }
        builder = Wayground::Democracy::ElectionBuilder.new(election: election)
        expect(builder).to receive(:offices_for_level)
        builder.offices_to_add_ballots_for
      end
    end
    context 'with some existing ballots for the election' do
      it 'should figure out which offices to include' do
        election = double('election')
        allow(election).to receive_message_chain(:ballots) { [:ballot] }
        builder = Wayground::Democracy::ElectionBuilder.new(election: election)
        expect(builder).to receive(:offices_without_ballots)
        builder.offices_to_add_ballots_for
      end
    end
  end

  describe '#offices_without_ballots' do
    it 'should return a list of applicable offices that don’t have a ballot for the election' do
      office1 = double('office 1')
      allow(office1).to receive(:id).and_return(1)
      office2 = double('office 2')
      allow(office2).to receive(:id).and_return(2)
      election = double('election')
      allow(election).to receive_message_chain(:level, :offices) { [office1, office2] }
      allow(election).to receive_message_chain(:ballots, :where).with(office_id: 1) { [] }
      allow(election).to receive_message_chain(:ballots, :where).with(office_id: 2) { [:ballot] }
      builder = Wayground::Democracy::ElectionBuilder.new(election: election)
      expect( builder.offices_without_ballots ).to eq [office1]
    end
  end

  describe '#offices_for_level' do
    context 'with a term_start_on date' do
      it 'should just get the offices association from the election’s level association' do
        election = double('election')
        allow(election).to receive_message_chain(:level, :offices, :active_on).with(:term_start_on) { :active_offices }
        builder = Wayground::Democracy::ElectionBuilder.new(election: election, term_start_on: :term_start_on)
        expect( builder.offices_for_level ).to eq :active_offices
      end
    end
    context 'with no term_start_on date' do
      it 'should just get the offices association from the election’s level association' do
        election = double('election')
        allow(election).to receive_message_chain(:level, :offices) { :offices }
        builder = Wayground::Democracy::ElectionBuilder.new(election: election)
        expect( builder.offices_for_level ).to eq :offices
      end
    end
  end

end
