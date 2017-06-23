require 'rails_helper'
require 'level'

describe 'offices/edit.html.erb', type: :view do
  let(:level) { $level = Level.new(filename: 'lvl') }
  let(:office_attrs) do
    $office_attrs = {
      name: 'Stub Name', filename: 'stub_filename', url: 'http://stub.url.tld/',
      title: 'Stub Title', established_on: '2001-02-03'.to_date, ended_on: '2009-08-07'.to_date,
      description: 'Stub description.'
    }
  end
  let(:office) do
    $office = level.offices.build(office_attrs)
    $office.level = level
    $office
  end

  before(:each) do
    assign(:level, level)
    allow(office).to receive(:to_param).and_return('abc')
    assign(:office, office)
    render
  end
  it 'renders edit office form' do
    assert_select 'form', action: '/levels/lvl/offices/abc', method: 'patch' do
      assert_select 'input#office_name', name: 'office[name]', value: 'Stub Name'
      assert_select 'input#office_filename', name: 'office[filename]', value: 'stub_filename'
      assert_select 'input#office_url', name: 'office[url]', type: 'url', value: 'http://stub.url.tld/'
      assert_select 'input#office_title', name: 'office[title]', type: 'title', value: 'Stub Title'
      assert_select(
        'input#office_established_on', name: 'office[established_on]', type: 'date', value: '2001-02-03'
      )
      assert_select 'input#office_ended_on', name: 'office[ended_on]', type: 'date', value: '2009-08-07'
      assert_select 'textarea#office_description', name: 'office[description]', value: 'Stub description.'
    end
  end
end
