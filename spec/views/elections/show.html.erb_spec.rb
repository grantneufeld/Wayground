require 'rails_helper'
require 'level'

describe 'elections/show.html.erb', type: :view do
  let(:level) { $level = Level.new(filename: 'lvl') }
  let(:election_attrs) do
    $election_attrs = {
      name: 'Stub Name', filename: 'stub_filename', url: 'http://stub.url.tld/',
      start_on: '2001-02-03'.to_date, end_on: '2009-08-07'.to_date,
      description: 'Stub description.'
    }
  end
  let(:election) do
    $election = level.elections.build(election_attrs)
    $election.level = level
    $election
  end

  before(:each) do
    assign(:level, level)
    assign(:election, election)
    render
  end
  it 'renders the name' do
    expect( rendered ).to match /<h1(?:| [^>]*)>.*Stub Name.*<\/h1>/
  end
  it 'renders the url' do
    expect( rendered ).to match /<a [^>]*href="#{election.url}"[^>]*>/
  end
  it 'renders the start_on date' do
    expect( rendered ).to match /February 3, 2001/
  end
  it 'renders the end_on date' do
    expect( rendered ).to match /August 7, 2009/
  end
  it 'renders the description' do
    expect( rendered ).to match /Stub description./
  end

end
