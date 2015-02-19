require 'rails_helper'
require 'level'

describe 'levels/show.html.erb', type: :view do
  let(:level_attrs) do
    $level_attrs = { name: 'Stub Name', filename: 'stub_filename', url: 'http://stub.url.tld/' }
  end
  let(:level) { $level = Level.new(level_attrs) }

  before(:each) do
    assign(:level, level)
    render
  end
  it "renders the name" do
    expect( rendered ).to match /<h1(?:| [^>]*)>.*Stub Name.*<\/h1>/
  end
  it "renders the url" do
    expect( rendered ).to match /<a [^>]*href="#{level.url}"[^>]*>/
  end
  context 'with parents' do
    let(:grandparent) { $grandparent = Level.new(name: 'Grandparent', filename: 'grandparent') }
    let(:parent) do
      $parent = Level.new(name: 'Parent', filename: 'parent')
      $parent.parent = grandparent
      $parent
    end
    let(:level) do
      $level = Level.new(level_attrs)
      $level.parent = parent
      $level
    end
    it 'should identify the parents' do
      expect( rendered ).to match /Stub Name, <a href="\/levels\/parent">Parent<\/a>, <a href="\/levels\/grandparent">Grandparent<\/a>/
    end
  end

end
