require 'rails_helper'
require 'level'

describe 'offices/delete.html.erb', type: :view do
  let(:level) { $level = Level.new(filename: 'lvl') }
  let(:office) { $office = level.offices.build(name: 'Delete Me') }

  before(:each) do
    assign(:level, level)
    allow(office).to receive(:to_param).and_return('abc')
    assign(:office, office)
    render
  end

  it 'should render the deletion form' do
    assert_select 'form', action: '/levels/lvl/offices/abc', method: 'delete' do
      assert_select 'input', type: 'submit', value: 'Delete Office'
    end
  end
end
