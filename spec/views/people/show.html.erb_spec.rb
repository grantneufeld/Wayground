require 'spec_helper'
require 'person'

describe 'people/show.html.erb', type: :view do
  let(:level) do
    $level = Level.new(filename: 'lvl')
  end
  let(:office) do
    $office = Office.new(filename: 'ofc', name: 'Stub Office', title: 'Stub Office')
  end
  let(:election) do
    $election = Election.new(filename: 'elct', name: 'Stub Election')
    $election.level = level
    $election
  end
  let(:ballot) do
    $ballot = Ballot.new
    $ballot.office = office
    $ballot.election = election
    $ballot
  end
  let(:candidate) do
    $candidate = Candidate.new(filename: 'cnd')
    $candidate.ballot = ballot
    $candidate
  end
  let(:person_attrs) do
    $person_attrs = {
      fullname: 'Stub Name', filename: 'stub_filename', bio: 'Stub bio.', aliases_string: 'AKA, Nick'
    }
  end
  let(:person) do
    $person = Person.new(person_attrs)
    $person.candidacies << candidate
    $person
  end

  before(:each) do
    assign(:person, person)
    render
  end
  it 'renders the fullname' do
    expect(rendered).to match(/Stub Name/)
  end
  it 'renders the aliases' do
    expect(rendered).to match(/AKA, Nick/)
  end
  it 'renders the bio' do
    expect(rendered).to match(/>[\r\n]*#{person.bio}[\r\n]*</)
  end
  it 'renders the candidacies' do
    expect(rendered).to match(
      %r{Stub Election: <a href="/levels/lvl/elections/elct/ballots/ofc/candidates/cnd">Stub Office}
    )
  end
end
