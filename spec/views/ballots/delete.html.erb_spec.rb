# encoding: utf-8
require 'spec_helper'
require 'election'

describe "ballots/delete.html.erb" do
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
  let(:ballot) do
    $ballot = election.ballots.new(description: 'Delete me.')
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

  it "should render the deletion form" do
    assert_select 'form', action: '/levels/lvl/elections/elct/ballots/abc', method: 'delete' do
      assert_select 'input', type: 'submit', value: 'Delete Ballot'
    end
  end

end
