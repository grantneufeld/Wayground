# encoding: utf-8
require 'spec_helper'
require 'level'

describe "offices/index.html.erb" do
  let(:level) { $level = Level.new(filename: 'lvl') }
  let(:office_attrs) do
    $office_attrs = { name: 'Stub Name', filename: 'stub_filename', url: 'http://stub.url.tld/' }
  end
  let(:office) { $office = level.offices.new(office_attrs) }

  before(:each) do
    assign(:level, level)
    office.stub(:to_param).and_return('abc')
    assign(:offices, [office, office])
    render
  end
  it "should present a list of the offices" do
    assert_select 'ul' do
      assert_select 'li', count: 2 do
        assert_select 'a', href: '/levels/lvl/offices/stub_filename', text: 'Stub Name'
      end
    end
  end

end
