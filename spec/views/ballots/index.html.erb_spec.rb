# encoding: utf-8
require 'spec_helper'
require 'election'

describe "ballots/index.html.erb" do
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
    $ballot = election.ballots.new(is_byelection: true)
    $ballot.election = election
    $ballot.office = office
    $ballot
  end
  
  before(:each) do
    assign(:level, level)
    assign(:election, election)
    ballot.stub(:to_param).and_return('abc')
    assign(:ballots, [ballot, ballot])
    render
  end
  it "should present a list of the ballots" do
    assert_select 'ul' do
      assert_select 'li', count: 2 do
        assert_select 'a', href: '/levels/lvl/elections/elct/ballots/stub_filename', text: 'Stub Name'
      end
    end
  end

end
