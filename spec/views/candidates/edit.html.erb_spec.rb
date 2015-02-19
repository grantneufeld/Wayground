require 'rails_helper'
require 'level'
require 'person'
require 'democracy/candidate_form'

describe 'candidates/edit.html.erb', type: :view do
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
  let(:candidate_attrs) do
    $candidate_attrs = {
      filename: 'edit_filename', name: 'Edit Name',
      announced_on: '2001-02-03'.to_date, quit_on: '2009-08-07'.to_date,
      is_rumoured: true, is_confirmed: true, is_incumbent: true, is_leader: true,
      is_acclaimed: true, is_elected: true, vote_count: 1234
    }
  end
  let(:candidate) do
    $candidate = ballot.candidates.build(candidate_attrs)
    $candidate.ballot = ballot
    $candidate.person = person
    $candidate
  end
  let(:candidate_form) do
    $candidate_form = Wayground::Democracy::CandidateForm.new
    $candidate_form.candidate = candidate
    $candidate_form
  end

  before(:each) do
    assign(:level, level)
    assign(:election, election)
    assign(:ballot, ballot)
    allow(candidate).to receive(:to_param).and_return('abc')
    assign(:candidate, candidate)
    assign(:candidate_form, candidate_form)
    render
  end
  it 'renders edit candidate form' do
    assert_select 'form', action: '/levels/lvl/elections/elct/ballots/offc/candidates/abc', method: 'put' do
      assert_select 'input#wayground_democracy_candidate_form_filename',
        name: 'wayground_democracy_candidate_form[filename]', value: 'edit_filename'
      assert_select 'input#wayground_democracy_candidate_form_name',
        name: 'wayground_democracy_candidate_form[name]', value: 'Edit Name'
      assert_select 'input#wayground_democracy_candidate_form_announced_on',
        name: 'wayground_democracy_candidate_form[announced_on]', type: 'date', value: '2001-02-03'
      assert_select 'input#wayground_democracy_candidate_form_quit_on',
        name: 'wayground_democracy_candidate_form[quit_on]', type: 'date', value: '2009-08-07'
      assert_select 'input#wayground_democracy_candidate_form_is_rumoured',
        name: 'wayground_democracy_candidate_form[is_rumoured]', value: '1', checked: 'checked'
      assert_select 'input#wayground_democracy_candidate_form_is_confirmed',
        name: 'wayground_democracy_candidate_form[is_confirmed]', value: '1', checked: 'checked'
      assert_select 'input#wayground_democracy_candidate_form_is_incumbent',
        name: 'wayground_democracy_candidate_form[is_incumbent]', value: '1', checked: 'checked'
      assert_select 'input#wayground_democracy_candidate_form_is_leader',
        name: 'wayground_democracy_candidate_form[is_leader]', value: '1', checked: 'checked'
      assert_select 'input#wayground_democracy_candidate_form_is_acclaimed',
        name: 'wayground_democracy_candidate_form[is_acclaimed]', value: '1', checked: 'checked'
      assert_select 'input#wayground_democracy_candidate_form_is_elected',
        name: 'wayground_democracy_candidate_form[is_elected]', value: '1', checked: 'checked'
      assert_select 'input#wayground_democracy_candidate_form_vote_count',
        name: 'wayground_democracy_candidate_form[vote_count]', value: '1234'
    end
  end

end
