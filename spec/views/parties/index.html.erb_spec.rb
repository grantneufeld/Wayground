require 'rails_helper'
require 'rspec-html-matchers'
require 'level'

describe 'parties/index.html.erb', type: :view do
  include RSpecHtmlMatchers

  let(:level) { $level = Level.new(filename: 'lvl') }
  let(:party_attrs) do
    $party_attrs = {
      name: 'Stub Name', filename: 'stub_filename', url: 'http://stub.url.tld/'
      # is_registered
      # colour
      # ended_on
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
    assign(:parties, [party, party])
    render
  end
  it 'should present a list of the parties' do
    expect(rendered).to have_tag('ul') do
      with_tag('li', count: 2) do
        with_tag 'a', href: '/levels/lvl/parties/stub_filename', text: 'Stub Name'
      end
    end
  end
end
