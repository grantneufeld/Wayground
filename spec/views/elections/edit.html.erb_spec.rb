# encoding: utf-8
require 'spec_helper'
require 'level'

describe 'elections/edit.html.erb' do
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
    election.stub(:to_param).and_return('abc')
    assign(:election, election)
    render
  end
  it 'renders edit election form' do
    assert_select 'form', action: '/levels/lvl/elections/abc', method: 'patch' do
      assert_select 'input#election_name', name: 'election[name]', value: 'Stub Name'
      assert_select 'input#election_filename', name: 'election[filename]', value: 'stub_filename'
      assert_select 'input#election_url', name: 'election[url]', type: 'url', value: 'http://stub.url.tld/'
      assert_select 'input#election_start_on', name: 'election[start_on]', type: 'date', value: '2001-02-03'
      assert_select 'input#election_end_on', name: 'election[end_on]', type: 'date', value: '2009-08-07'
      assert_select 'textarea#election_description', name: 'election[description]', value: 'Stub description.'
    end
  end

end
