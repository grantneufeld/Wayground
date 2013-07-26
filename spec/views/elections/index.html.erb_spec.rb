# encoding: utf-8
require 'spec_helper'
require 'level'

describe "elections/index.html.erb" do
  let(:level) { $level = Level.new(filename: 'lvl') }
  let(:election_attrs) do
    $election_attrs = { name: 'Stub Name', filename: 'stub_filename', url: 'http://stub.url.tld/' }
  end
  let(:election) { $election = level.elections.build(election_attrs) }

  before(:each) do
    assign(:level, level)
    election.stub(:to_param).and_return('abc')
    assign(:elections, [election, election])
    render
  end
  it "should present a list of the elections" do
    assert_select 'ul' do
      assert_select 'li', count: 2 do
        assert_select 'a', href: '/levels/lvl/elections/stub_filename', text: 'Stub Name'
      end
    end
  end

end
