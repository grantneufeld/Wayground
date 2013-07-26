# encoding: utf-8
require 'spec_helper'
require 'level'

describe 'parties/show.html.erb' do
  let(:level) { $level = Level.new(filename: 'lvl', name: 'Level') }
  let(:party_attrs) do
    $party_attrs = {
      name: 'Stub Name', filename: 'stub_filename', aliases: ['Stub Alias 1', 'Stub Alias 2'],
      abbrev: 'Stub Abbrev', is_registered: true, colour: 'aqua', url: 'http://stub.url.tld/',
      established_on: '2001-02-03'.to_date, registered_on: '2002-03-04'.to_date,
      ended_on: '2009-08-07'.to_date, description: 'Stub description.'
    }
  end
  let(:party) do
    $party = level.parties.build(party_attrs)
    $party.level = level
    $party
  end

  before(:each) do
    assign(:level, level)
    assign(:party, party)
    render
  end
  it 'renders the name' do
    expect( rendered ).to match /<h1(?:| [^>]*)>.*Stub Name.*<\/h1>/
  end
  it 'renders the colour' do
    expect( rendered ).to match /<h1(?:| [^>]*) style="border-color:aqua"[^>]*>/
  end
  it 'renders the abbrev' do
    expect( rendered ).to match /\[Stub Abbrev\]/
  end
  it 'renders the aliases' do
    expect( rendered ).to match /Stub Alias 1, Stub Alias 2/
  end
  it 'renders the url' do
    expect( rendered ).to match /<a [^>]*href="#{party.url}"[^>]*>/
  end
  it 'renders the established_on date' do
    expect( rendered ).to match /February 3, 2001/
  end
  it 'renders the registered_on date' do
    expect( rendered ).to match /March 4, 2002/
  end
  it 'renders the ended_on date' do
    expect( rendered ).to match /August 7, 2009/
  end
  it 'renders the description' do
    expect( rendered ).to match /Stub description./
  end
  context 'when registered' do
    it 'does not render the heading with the “party-unregistered” class' do
      expect( rendered.match /<h1(?:| [^>]*)unregistered[^>]*>/ ).to be_false
    end
  end
  context 'when not registered' do
    let(:party_attrs) do
      $party_attrs = {
        name: 'Stub Name', filename: 'stub_filename', aliases: ['Stub Alias 1', 'Stub Alias 2'],
        abbrev: 'Stub Abbrev', is_registered: false, colour: 'aqua', url: 'http://stub.url.tld/',
        established_on: '2001-02-03'.to_date, registered_on: '2002-03-04'.to_date,
        ended_on: '2009-08-07'.to_date, description: 'Stub description.'
      }
    end
    it 'renders the heading with the “party-unregistered” class' do
      expect( rendered ).to match /<h1(?:| [^>]*) class="(?:|[^"]* )party-unregistered(?:| [^"]*)"[^>]*>/
    end
  end
end
