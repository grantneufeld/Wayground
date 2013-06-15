# encoding: utf-8
require 'spec_helper'
require 'level'

describe "levels/delete.html.erb" do
  let(:level) { $level = Level.new(name: 'Delete Me') }

  before(:each) do
    level.stub(:id).and_return(123)
    assign(:level, level)
    render
  end

  it "should render the deletion form" do
    assert_select 'form', action: '/levels/123', method: 'delete' do
      assert_select 'input', type: 'submit', value: 'Delete Level'
    end
  end

end
