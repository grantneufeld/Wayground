# encoding: utf-8
require 'spec_helper'
require 'person'

describe "people/show.html.erb" do
  let(:person_attrs) do
    $person_attrs = {
      fullname: 'Stub Name', aliases: ['Alias 1', 'Alias 2'], filename: 'stub_filename', bio: 'Stub bio.'
    }
  end
  let(:person) { $person = Person.new(person_attrs) }

  before(:each) do
    assign(:person, person)
    render
  end
  it "renders the fullname" do
    expect( rendered ).to match /<h1(?:| [^>]*)>.*Stub Name.*<\/h1>/
  end
  it "renders the aliases" do
    expect( rendered ).to match /Alias 1, Alias 2/
  end
  it "renders the bio" do
    expect( rendered ).to match />[\r\n]*#{person.bio}[\r\n]*</
  end

end
