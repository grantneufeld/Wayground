require 'rails_helper'
require 'person'

describe 'contacts/new.html.erb', type: :view do
  let(:person) { $person = Person.new(filename: 'prsn') }
  let(:contact) { $contact = person.contacts.build }

  before(:each) do
    assign(:item, person)
    assign(:contact, contact)
    render
  end

  it 'renders new contact form' do
    assert_select 'form', action: '/person/prsn/contacts', method: 'put' do
      assert_select 'input#contact_position',
        name: 'contact[position]'
      assert_select 'input#contact_is_public',
        name: 'contact[is_public]'
      assert_select 'input#contact_confirmed_at',
        name: 'contact[confirmed_at]', type: 'datetime'
      assert_select 'input#contact_expires_at',
        name: 'contact[expires_at]', type: 'datetime'
      assert_select 'input#contact_name',
        name: 'contact[name]'
      assert_select 'input#contact_organization',
        name: 'contact[organization]'
      # TODO: test for the rest of the fields expected


    end
  end

end
