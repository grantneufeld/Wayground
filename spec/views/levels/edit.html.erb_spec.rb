# encoding: utf-8
require 'spec_helper'
require 'level'

describe "levels/edit.html.erb" do
  let(:level_attrs) do
    $level_attrs = { name: 'Stub Name', filename: 'stub_filename', url: 'http://stub.url.tld/' }
  end
  let(:level) { $level = Level.new(level_attrs) }

  before(:each) do
    level.stub(:id).and_return(123)
    assign(:level, level)
    render
  end
  it "renders edit level form" do
    assert_select 'form', action: '/levels/123', method: 'patch' do
      assert_select 'input#level_name', name: 'level[name]', value: 'Stub Name'
      assert_select 'input#level_filename', name: 'level[filename]', value: 'stub_filename'
      assert_select 'input#level_url', name: 'level[url]', type: 'url', value: 'http://stub.url.tld/'
    end
  end

end
