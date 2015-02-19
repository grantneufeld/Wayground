# encoding: utf-8
require 'spec_helper'
require 'person'

describe 'people/index.html.erb', type: :view do
  let(:person_attrs) do
    $person_attrs = { fullname: 'Stub Name', filename: 'stub_filename', bio: 'Stub bio.' }
  end
  let(:person) { $person = Person.new(person_attrs) }

  before(:each) do
    assign(:people, [person, person])
    render
  end
  it "should present a list of the people" do
    assert_select 'ul' do
      assert_select 'li', count: 2 do
        assert_select 'a', href: '/people/stub_filename', text: 'Stub Name'
      end
    end
  end

end
