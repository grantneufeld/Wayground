# encoding: utf-8
require 'spec_helper'
require 'level'

describe 'parties/index.html.erb' do
  let(:level) { $level = Level.new(filename: 'lvl') }
  let(:party_attrs) do
    $party_attrs = {
      name: 'Stub Name', filename: 'stub_filename', url: 'http://stub.url.tld/'
      #is_registered
      #colour
      #ended_on
    }
  end
  let(:party) do
    $party = level.parties.new(party_attrs)
    $party.level = level
    $party
  end

  before(:each) do
    assign(:level, level)
    party.stub(:to_param).and_return('abc')
    assign(:parties, [party, party])
    render
  end
  it 'should present a list of the parties' do
    assert_select 'ul' do
      assert_select 'li', count: 2 do
        assert_select 'a', href: '/levels/lvl/parties/stub_filename', text: 'Stub Name'
      end
    end
  end

end
