# encoding: utf-8
require 'spec_helper'
require 'level'

describe "levels/index.html.erb" do
  let(:level_attrs) do
    $level_attrs = { name: 'Stub Name', filename: 'stub_filename', url: 'http://stub.url.tld/' }
  end
  let(:level) { $level = Level.new(level_attrs) }

  before(:each) do
    level.stub(:id).and_return(123)
    assign(:levels, [level, level])
    render
  end
  it "should present a list of the levels" do
    assert_select 'ul' do
      assert_select 'li', count: 2 do
        assert_select 'a', href: '/levels/stub_filename', text: 'Stub Name'
      end
    end
  end

end
