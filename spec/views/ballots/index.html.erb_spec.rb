# encoding: utf-8
require 'spec_helper'
require 'election'

describe "ballots/index.html.erb" do
  let(:level) { $level = Level.new(filename: 'lvl') }
  let(:office) do
    $office = level.offices.build(filename: 'offc', name: 'Stub Office')
    $office.level = level
    $office
  end
  let(:election) do
    $election = level.elections.build(filename: 'elct')
    $election.level = level
    $election
  end
  let(:ballot) do
    $ballot = election.ballots.build(is_byelection: true)
    $ballot.election = election
    $ballot.office = office
    $ballot
  end
  let(:candidate) do
    $candidate = ballot.candidates.build(filename: 'cnd', name: 'Stub Candidate')
    $candidate.ballot = ballot
    $candidate
  end
  
  before(:each) do
    assign(:level, level)
    assign(:election, election)
    ballot.stub(:to_param).and_return('abc')
    candidate
    ballot.stub_chain(:candidates, :running).and_return([candidate])
    assign(:ballots, [ballot, ballot])
    render
  end
  it "should present a list of the ballots" do
    assert_select 'h2' do
      assert_select 'a', href: '/levels/lvl/elections/elct/ballots/offc', text: 'Stub Office'
    end
  end
  it 'should list the candidates on the ballots' do
    assert_select 'div.vcard' do
      assert_select 'h3.fn', count: 2 do
        assert_select('a.url', href: '/levels/lvl/elections/elct/ballots/offc/candidates/cnd',
          text: 'Stub Candidate'
        )
      end
    end
  end

end
