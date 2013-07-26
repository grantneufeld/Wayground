# encoding: utf-8
require 'spec_helper'
require 'election'

describe 'ballots/edit.html.erb' do
  let(:level) { $level = Level.new(filename: 'lvl') }
  let(:office) do
    $office = level.offices.new(filename: 'offc', name: 'Stub Name', filename: 'stub_filename')
    $office.level = level
    $office
  end
  let(:election) do
    $election = level.elections.new(filename: 'elct')
    $election.level = level
    $election
  end
  let(:ballot_attrs) do
    $ballot_attrs = {
      term_start_on: '2001-02-03'.to_date, term_end_on: '2009-08-07'.to_date,
      is_byelection: true,
      url: 'http://stub.url.tld/', description: 'Stub description.'
    }
  end
  let(:ballot) do
    $ballot = election.ballots.new(ballot_attrs)
    $ballot.election = election
    $ballot.office = office
    $ballot
  end

  before(:each) do
    assign(:level, level)
    assign(:election, election)
    ballot.stub(:to_param).and_return('abc')
    assign(:ballot, ballot)
    render
  end
  it 'renders edit ballot form' do
    assert_select 'form', action: '/levels/lvl/elections/elct/ballots/abc', method: 'patch' do
      assert_select 'input#ballot_term_start_on', name: 'ballot[term_start_on]', type: 'date', value: '2001-02-03'
      assert_select 'input#ballot_term_end_on', name: 'ballot[term_end_on]', type: 'date', value: '2009-08-07'
      assert_select 'input#ballot_is_byelection', name: 'ballot[is_byelection]', value: '1', checked: 'checked'
      assert_select 'input#ballot_url', name: 'ballot[url]', type: 'url', value: 'http://stub.url.tld/'
      assert_select 'textarea#ballot_description', name: 'ballot[description]', value: 'Stub description.'
    end
  end

end
