# encoding: utf-8
require 'spec_helper'
require 'level'

describe "levels/new.html.erb" do
  let(:level) { $level = Level.new(url: 'http://no.parent/') }

  before(:each) do
    assign(:level, level)
    render
  end
  it "renders new level form" do
    assert_select 'form', action: levels_path, method: 'put' do
      assert_select 'input#level_name', name: 'level[name]'
      assert_select 'input#level_filename', name: 'level[filename]'
      assert_select 'input#level_url', name: 'level[url]', type: 'url'
    end
  end
  context 'with a parent' do
    let(:level) do
      $level = Level.new(url: 'http://with.parent/')
      $level.parent = Level.new(name: 'Parent Level', filename: 'parent_level' )
      $level
    end
    before(:each) do
      assign(:parent, level.parent)
    end
    it 'should identify the parent' do
      assert_select 'p' do
        assert_select 'a', href: '/levels/parent_level', text: 'Parent Level'
      end
    end
    it 'should include an input tag identifying the parent' do
      expect( rendered ).to match /<input [^>]*name="parent_id"[^>]* value="parent_level"/
    end
  end

end
