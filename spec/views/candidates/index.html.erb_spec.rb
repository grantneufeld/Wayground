require 'rails_helper'
require 'level'
require 'person'

describe 'candidates/index.html.erb', type: :view do
  let(:level) { $level = Level.new(filename: 'lvl') }
  let(:person) { $person = Person.new(filename: 'prsn') }
  let(:office) do
    $office = level.offices.build(filename: 'offc')
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
    $candidate = ballot.candidates.build(name: 'Stub Name', filename: 'stub_filename')
    $candidate.ballot = ballot
    $candidate.person = person
    $candidate
  end

  before(:each) do
    assign(:level, level)
    assign(:election, election)
    assign(:ballot, ballot)
    assign(:person, person)
    allow(candidate).to receive(:to_param).and_return('abc')
    assign(:candidates, [candidate, candidate])
    render
  end
  it "should present a list of the candidates" do
    assert_select 'ul' do
      assert_select 'li', count: 2 do
        assert_select 'a', href: '/levels/lvl/elections/elct/ballots/offc/candidates/stub_filename',
          text: 'Stub Name'
      end
    end
  end

end
