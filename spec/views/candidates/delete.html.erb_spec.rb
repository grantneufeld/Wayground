require 'rails_helper'
require 'level'
require 'person'

describe 'candidates/delete.html.erb', type: :view do
  let(:level) { $level = Level.new(filename: 'lvl') }
  let(:person) { $person = Person.new(filename: 'prsn') }
  let(:office) do
    $office = level.offices.build(filename: 'offc', name: 'Stub Name')
    $office.level = level
    $office
  end
  let(:election) do
    $election = level.elections.build(filename: 'elct')
    $election.level = level
    $election
  end
  let(:ballot) do
    $ballot = election.ballots.build
    $ballot.election = election
    $ballot.office = office
    $ballot
  end
  let(:candidate) do
    $candidate = ballot.candidates.build(name: 'Delete me.')
    $candidate.ballot = ballot
    $candidate.person = person
    $candidate
  end

  before(:each) do
    assign(:level, level)
    assign(:election, election)
    assign(:ballot, ballot)
    allow(candidate).to receive(:to_param).and_return('abc')
    assign(:candidate, candidate)
    render
  end

  it "should render the deletion form" do
    assert_select 'form', action: '/levels/lvl/elections/elct/ballots/offc/candidates/abc', method: 'delete' do
      assert_select 'input', type: 'submit', value: 'Delete Candidate'
    end
  end

end
