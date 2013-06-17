# encoding: utf-8
require 'spec_helper'
require 'election'

describe 'ballots/show.html.erb' do
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
    assign(:ballot, ballot)
    render
  end
  it 'renders the name' do
    expect( rendered ).to match /<h1(?:| [^>]*)>.*Stub Name.*<\/h1>/
  end
  it 'renders the url' do
    expect( rendered ).to match /<a [^>]*href="#{ballot.url}"[^>]*>/
  end
  it 'renders the term_start_on date' do
    expect( rendered ).to match /February 3, 2001/
  end
  it 'renders the term_end_on date' do
    expect( rendered ).to match /August 7, 2009/
  end
  it 'renders the description' do
    expect( rendered ).to match /Stub description./
  end

end
