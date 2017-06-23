require 'rails_helper'
require 'election'

describe 'ballots/delete.html.erb', type: :view do
  let(:level) { $level = Level.new(filename: 'lvl') }
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
    $ballot = election.ballots.build(description: 'Delete me.')
    $ballot.election = election
    $ballot.office = office
    $ballot
  end

  before(:each) do
    assign(:level, level)
    assign(:election, election)
    allow(ballot).to receive(:to_param).and_return('abc')
    assign(:ballot, ballot)
    render
  end

  it 'should render the deletion form' do
    assert_select 'form', action: '/levels/lvl/elections/elct/ballots/abc', method: 'delete' do
      assert_select 'input', type: 'submit', value: 'Delete Ballot'
    end
  end
end
