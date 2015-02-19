require 'rails_helper'
require 'level'
require 'democracy/candidate_form'

describe 'candidates/new.html.erb', type: :view do
  let(:level) { $level = Level.new(filename: 'lvl') }
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
  let(:candidate_form) do
    $candidate_form = Wayground::Democracy::CandidateForm.new
    $candidate_form.ballot = ballot
    $candidate_form
  end

  before(:each) do
    assign(:level, level)
    assign(:election, election)
    assign(:ballot, ballot)
    assign(:candidate_form, candidate_form)
    render
  end
  it 'renders new candidate form' do
    assert_select 'form', action: '/levels/lvl/elections/elct/ballots/offc/candidates', method: 'put' do
      assert_select 'input#wayground_democracy_candidate_form_filename',
        name: 'wayground_democracy_candidate_form[filename]'
      assert_select 'input#wayground_democracy_candidate_form_name',
        name: 'wayground_democracy_candidate_form[name]'
      assert_select 'input#wayground_democracy_candidate_form_announced_on',
        name: 'wayground_democracy_candidate_form[announced_on]', type: 'date'
      assert_select 'input#wayground_democracy_candidate_form_quit_on',
        name: 'wayground_democracy_candidate_form[quit_on]', type: 'date'
      assert_select 'input#wayground_democracy_candidate_form_is_rumoured',
        name: 'wayground_democracy_candidate_form[is_rumoured]', value: '1'
      assert_select 'input#wayground_democracy_candidate_form_is_confirmed',
        name: 'wayground_democracy_candidate_form[is_confirmed]', value: '1'
      assert_select 'input#wayground_democracy_candidate_form_is_incumbent',
        name: 'wayground_democracy_candidate_form[is_incumbent]', value: '1'
      assert_select 'input#wayground_democracy_candidate_form_is_leader',
        name: 'wayground_democracy_candidate_form[is_leader]', value: '1'
      assert_select 'input#wayground_democracy_candidate_form_is_acclaimed',
        name: 'wayground_democracy_candidate_form[is_acclaimed]', value: '1'
      assert_select 'input#wayground_democracy_candidate_form_is_elected',
        name: 'wayground_democracy_candidate_form[is_elected]', value: '1'
      assert_select 'input#wayground_democracy_candidate_form_vote_count',
        name: 'wayground_democracy_candidate_form[vote_count]'
    end
  end

end
