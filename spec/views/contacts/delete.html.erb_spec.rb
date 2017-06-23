require 'rails_helper'
require 'person'

describe 'contacts/delete.html.erb', type: :view do
  let(:person) { $person = Person.new(filename: 'prsn') }
  let(:contact) { $contact = person.contacts.build(name: 'Delete me.') }

  before(:each) do
    assign(:item, person)
    allow(contact).to receive(:to_param).and_return('123')
    assign(:contact, contact)
    render
  end

  it 'should render the deletion form' do
    assert_select 'form', action: '/person/prsn/contacts/123', method: 'delete' do
      assert_select 'input', type: 'submit', value: 'Delete Contact'
    end
  end
end
