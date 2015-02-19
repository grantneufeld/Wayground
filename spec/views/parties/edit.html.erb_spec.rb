require 'rails_helper'
require 'level'

describe 'parties/edit.html.erb', type: :view do
  let(:level) { $level = Level.new(filename: 'lvl') }
  let(:party_attrs) do
    $party_attrs = {
      name: 'Stub Name', filename: 'stub_filename', url: 'http://stub.url.tld/',
      established_on: '2001-02-03'.to_date, registered_on: '2002-03-04'.to_date,
      ended_on: '2009-08-07'.to_date,
      aliases: ['Stub Alias 1', 'Stub Alias 2'],
      abbrev: 'Stub Abbrev',
      is_registered: true,
      colour: 'aqua',
      description: 'Stub description.'
    }
  end
  let(:party) do
    $party = level.parties.build(party_attrs)
    $party.level = level
    $party
  end

  before(:each) do
    assign(:level, level)
    allow(party).to receive(:to_param).and_return('abc')
    assign(:party, party)
    render
  end
  it 'renders edit party form' do
    assert_select 'form', action: '/levels/lvl/parties/abc', method: 'patch' do
      assert_select 'input#party_filename', name: 'party[filename]', value: 'stub_filename'
      assert_select 'input#party_name', name: 'party[name]', value: 'Stub Name'
      assert_select 'input#party_aliases', name: 'party[aliases]', value: 'Stub Alias 1, Stub Alias 2'
      assert_select 'input#party_abbrev', name: 'party[abbrev]', value: 'Stub Abbrev'
      assert_select 'input#party_colour', name: 'party[colour]', value: 'aqua'
      assert_select 'input#party_url', name: 'party[url]', type: 'url', value: 'http://stub.url.tld/'
      assert_select 'input#party_established_on', name: 'party[established_on]', type: 'date', value: '2001-02-03'
      assert_select 'input#party_is_registered', name: 'party[is_registered]', value: '1', is_checked: 'is_checked'
      assert_select 'input#party_registered_on', name: 'party[registered_on]', type: 'date', value: '2002-03-04'
      assert_select 'input#party_ended_on', name: 'party[ended_on]', type: 'date', value: '2009-08-07'
      assert_select 'textarea#party_description', name: 'party[description]', value: 'Stub description.'
    end
  end

end
