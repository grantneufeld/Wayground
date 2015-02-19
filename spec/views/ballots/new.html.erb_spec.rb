require 'rails_helper'
require 'election'

describe 'ballots/new.html.erb', type: :view do
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
    $ballot = election.ballots.build
    $ballot.election = election
    $ballot.office = office
    $ballot
  end

  before(:each) do
    assign(:level, level)
    assign(:election, election)
    assign(:offices, [office])
    assign(:office_id, 'offc')
    assign(:ballot, ballot)
    render
  end
  it 'renders new ballot form' do
    assert_select 'form', action: '/levels/lvl/elections/elct/ballots', method: 'post' do
      assert_select 'select#office_id', name: 'office_id' do
        assert_select 'option', value: 'offc', selected: 'selected', text: 'Stub Name'
      end
      assert_select 'input#ballot_term_start_on', name: 'ballot[term_start_on]', type: 'date'
      assert_select 'input#ballot_term_end_on', name: 'ballot[term_end_on]', type: 'date'
      assert_select 'input#ballot_is_byelection', name: 'ballot[is_byelection]', value: '1'
      assert_select 'input#ballot_url', name: 'ballot[url]', type: 'url'
      assert_select 'textarea#ballot_description', name: 'ballot[description]'
    end
  end

end
