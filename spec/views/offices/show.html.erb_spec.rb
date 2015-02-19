require 'rails_helper'
require 'level'

describe 'offices/show.html.erb', type: :view do
  let(:level) { $level = Level.new(filename: 'lvl') }
  let(:office_attrs) do
    $office_attrs = {
      name: 'Stub Name', filename: 'stub_filename', url: 'http://stub.url.tld/',
      title: 'Stub Title', established_on: '2001-02-03'.to_date, ended_on: '2009-08-07'.to_date,
      description: 'Stub description.'
    }
  end
  let(:office) { $office = level.offices.build(office_attrs) }

  before(:each) do
    assign(:level, level)
    assign(:office, office)
    render
  end
  it 'renders the name' do
    expect( rendered ).to match /<h1(?:| [^>]*)>.*Stub Name.*<\/h1>/
  end
  it 'renders the url' do
    expect( rendered ).to match /<a [^>]*href="#{office.url}"[^>]*>/
  end
  it 'renders the title' do
    expect( rendered ).to match /Stub Title/
  end
  it 'renders the established_on date' do
    expect( rendered ).to match /February 3, 2001/
  end
  it 'renders the ended_on date' do
    expect( rendered ).to match /August 7, 2009/
  end
  it 'renders the description' do
    expect( rendered ).to match /Stub description./
  end
  context 'with previous' do
    let(:previous_previous) { $previous_previous = level.offices.build(name: 'Previous Previous', filename: 'previous_previous') }
    let(:previous) do
      $previous = level.offices.build(name: 'Previous', filename: 'previous')
      $previous.previous = previous_previous
      $previous
    end
    let(:office) do
      $office = level.offices.build(office_attrs)
      $office.previous = previous
      $office
    end
    it 'should identify the previous' do
      expect( rendered ).to match /Previous Office: <a href="\/levels\/lvl\/offices\/previous">Previous<\/a>/
    end
  end

end
