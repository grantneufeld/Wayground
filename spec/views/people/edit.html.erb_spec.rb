# encoding: utf-8
require 'spec_helper'
require 'person'

describe "people/edit.html.erb" do
  let(:person_attrs) do
    $person_attrs = {
      fullname: 'Stub Name', aliases_string: 'Alias 1, Alias 2', filename: 'stub_filename', bio: 'Stub bio.'
    }
  end
  let(:person) { $person = Person.new(person_attrs) }

  before(:each) do
    assign(:person, person)
    render
  end
  it "renders edit person form" do
    assert_select 'form', action: '/people/stub_filename', method: 'patch' do
      assert_select 'input#person_fullname', name: 'person[fullname]', value: 'Stub Name'
      assert_select 'input#person_aliases_string', name: 'person[aliases_string]', value: 'Alias 1, Alias 2'
      assert_select 'input#person_filename', name: 'person[filename]', value: 'stub_filename'
      assert_select 'textarea#person_bio', name: 'person[bio]', value: 'Stub bio.'
    end
  end

end
