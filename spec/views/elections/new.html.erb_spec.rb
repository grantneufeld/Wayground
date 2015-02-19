require 'rails_helper'
require 'level'

describe 'elections/new.html.erb', type: :view do
  let(:level) { $level = Level.new(filename: 'lvl') }
  let(:election) do
    $election = level.elections.build
    $election.level = level
    $election
  end

  before(:each) do
    assign(:level, level)
    assign(:election, election)
    render
  end
  it 'renders new election form' do
    assert_select 'form', action: '/levels/lvl/elections', method: 'post' do
      assert_select 'input#election_name', name: 'election[name]'
      assert_select 'input#election_filename', name: 'election[filename]'
      assert_select 'input#election_url', name: 'election[url]', type: 'url'
      assert_select 'input#election_start_on', name: 'election[start_on]', type: 'date'
      assert_select 'input#election_end_on', name: 'election[end_on]', type: 'date'
      assert_select 'textarea#election_description', name: 'election[description]'
    end
  end

end
