# encoding: utf-8
require 'spec_helper'
require 'level'

describe 'candidates/show.html.erb' do
  let(:level) { $level = Level.new(filename: 'lvl') }
  let(:person) { $person = Person.new(filename: 'prsn') }
  let(:election) do
    $election = level.elections.build(filename: 'elct')
    $election.level = level
    $election
  end
  let(:office) do
    $office = level.offices.build(filename: 'offc')
    $office.level = level
    $office
  end
  let(:ballot) do
    $ballot = election.ballots.build
    $ballot.election = election
    $ballot.office = office
    $ballot
  end
  let(:candidate_attrs) do
    $candidate_attrs = {
      name: 'Stub Name', filename: 'stub_filename',
      announced_on: '2001-02-03'.to_date, quit_on: '2009-08-07'.to_date,
      is_confirmed: true, vote_count: '1234'
    }
  end
  let(:candidate) do
    $candidate = ballot.candidates.build(candidate_attrs)
    $candidate.ballot = ballot
    $candidate.person = person
    $candidate
  end
  let(:contact) do
    $contact = candidate.contacts.build(name: 'Stub Contact', email: 'stub@contact.test')
  end
  let(:external_link) do
    $external_link = candidate.external_links.build(title: 'Stub Link', url: 'http://link.test/')
  end

  before(:each) do
    assign(:level, level)
    assign(:election, election)
    assign(:ballot, ballot)
    assign(:candidate, candidate)
    assign(:contacts, [contact])
    assign(:external_links, [external_link])
    render
  end
  it 'renders the name' do
    expect( rendered ).to match /Stub Name/
  end
  it 'renders the announced_on date' do
    expect( rendered ).to match /February 3, 2001/
  end
  it 'renders the quit_on date' do
    expect( rendered ).to match /August 7, 2009/
  end

end
