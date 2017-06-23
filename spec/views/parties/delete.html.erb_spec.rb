require 'rails_helper'
require 'level'

describe 'parties/delete.html.erb', type: :view do
  let(:level) { $level = Level.new(filename: 'lvl') }
  let(:party) { $party = level.parties.build(name: 'Delete Me') }

  before(:each) do
    assign(:level, level)
    allow(party).to receive(:to_param).and_return('abc')
    assign(:party, party)
    render
  end

  it 'should render the deletion form' do
    assert_select 'form', action: '/levels/lvl/parties/abc', method: 'delete' do
      assert_select 'input', type: 'submit', value: 'Delete Party'
    end
  end
end
