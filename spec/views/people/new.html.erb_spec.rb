# encoding: utf-8
require 'spec_helper'
require 'person'

describe "people/new.html.erb" do
  let(:person) { $person = Person.new }

  before(:each) do
    assign(:person, person)
    render
  end
  it "renders new person form" do
    assert_select 'form', action: people_path, method: 'post' do
      assert_select 'input#person_fullname', name: 'person[fullname]'
      assert_select 'input#person_aliases', name: 'person[aliases]'
      assert_select 'input#person_filename', name: 'person[filename]'
      assert_select 'textarea#person_bio', name: 'person[bio]'
    end
  end

end
