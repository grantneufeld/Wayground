require 'rails_helper'
require 'level'

describe 'elections/delete.html.erb', type: :view do
  let(:level) { $level = Level.new(filename: 'lvl') }
  let(:election) { $election = level.elections.build(name: 'Delete Me') }

  before(:each) do
    assign(:level, level)
    allow(election).to receive(:to_param).and_return('abc')
    assign(:election, election)
    render
  end

  it "should render the deletion form" do
    assert_select 'form', action: '/levels/lvl/elections/abc', method: 'delete' do
      assert_select 'input', type: 'submit', value: 'Delete Election'
    end
  end

end
