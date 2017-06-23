require 'spec_helper'
require 'person'

describe 'people/delete.html.erb', type: :view do
  let(:person) { $person = Person.new(fullname: 'Delete Me', filename: 'bob') }

  before(:each) do
    assign(:person, person)
    render
  end

  it 'should render the deletion form' do
    assert_select 'form', action: '/people/bob', method: 'delete' do
      assert_select 'input', type: 'submit', value: 'Delete Person'
    end
  end
end
