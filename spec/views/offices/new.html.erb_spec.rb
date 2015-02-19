require 'rails_helper'
require 'level'

describe 'offices/new.html.erb', type: :view do
  let(:level) { $level = Level.new(filename: 'lvl') }
  let(:office) do
    $office = level.offices.build(url: 'http://no.previous/')
    $office.level = level
    $office
  end

  before(:each) do
    assign(:level, level)
    assign(:office, office)
    render
  end
  it 'renders new office form' do
    assert_select 'form', action: '/levels/lvl/offices', method: 'post' do
      assert_select 'input#office_name', name: 'office[name]'
      assert_select 'input#office_filename', name: 'office[filename]'
      assert_select 'input#office_url', name: 'office[url]', type: 'url'
      assert_select 'input#office_title', name: 'office[title]'
      assert_select 'input#office_established_on', name: 'office[established_on]', type: 'date'
      assert_select 'input#office_ended_on', name: 'office[ended_on]', type: 'date'
      assert_select 'textarea#office_description', name: 'office[description]'
    end
  end
  context 'with a previous' do
    let(:office) do
      $office = level.offices.build(url: 'http://with.previous/')
      $office.level = level
      $office.previous = level.offices.build(name: 'Previous Office', filename: 'previous_office' )
      $office
    end
    before(:each) do
      assign(:previous, office.previous)
    end
    it 'should identify the previous' do
      assert_select 'p' do
        assert_select 'a', href: '/levels/lvl/offices/previous_office', text: 'Previous Office'
      end
    end
    it 'should include an input tag identifying the previous' do
      expect( rendered ).to match /<input [^>]*name="previous_id"[^>]* value="previous_office"/
    end
  end

end
