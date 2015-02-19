require 'rails_helper'
require 'level'

describe 'parties/new.html.erb', type: :view do
  let(:level) { $level = Level.new(filename: 'lvl') }
  let(:party) do
    $party = level.parties.build
    $party.level = level
    $party
  end

  before(:each) do
    assign(:level, level)
    assign(:party, party)
    render
  end
  it 'renders new party form' do
    assert_select 'form', action: '/levels/lvl/parties', method: 'post' do
      assert_select 'input#party_name', name: 'party[name]'
      assert_select 'input#party_filename', name: 'party[filename]'
      assert_select 'input#party_aliases', name: 'party[aliases]', value: 'Stub Alias 1, Stub Alias 2'
      assert_select 'input#party_abbrev', name: 'party[abbrev]', value: 'Stub Abbrev'
      assert_select 'input#party_colour', name: 'party[colour]', value: 'aqua'
      assert_select 'input#party_url', name: 'party[url]', type: 'url'
      assert_select 'input#party_established_on', name: 'party[established_on]', type: 'date'
      assert_select 'input#party_is_registered', name: 'party[is_registered]'
      assert_select 'input#party_registered_on', name: 'party[registered_on]', type: 'date'
      assert_select 'input#party_ended_on', name: 'party[ended_on]', type: 'date'
      assert_select 'textarea#party_description', name: 'party[description]'
    end
  end

end
