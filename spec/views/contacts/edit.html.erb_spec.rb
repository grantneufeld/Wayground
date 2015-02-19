require 'rails_helper'
require 'person'

describe 'contacts/edit.html.erb', type: :view do
  let(:person) { $person = Person.new(filename: 'prsn') }
  let(:contact_attrs) do
    $contact_attrs = {
      position: 12, is_public: true,
      confirmed_at: '2001-02-03 04:05 AM MST'.to_datetime,
      expires_at: '2002-03-04 05:06 AM MST'.to_datetime,
      name: 'Edit Name', organization: 'Edit Organization',
      email: 'edit@email.tld', twitter: 'edittwitter', url: 'http://edit.url/',
      phone: '123-456-7890', phone2: '234-567-8901', fax: '345-6789-012',
      address1: 'Edit Address', address2: '456 Street',
      city: 'Editville', province: 'Editia', country: 'Editland', postal: 'A1B 2C3'
    }
  end
  let(:contact) { $contact = person.contacts.build(contact_attrs) }

  before(:each) do
    assign(:item, person)
    allow(contact).to receive(:to_param).and_return('123')
    assign(:contact, contact)
    render
  end

  it 'renders edit contact form' do
    assert_select 'form', action: '/person/prsn/contacts/123', method: 'put' do
      assert_select 'input#contact_position',
        name: 'contact[position]', value: '12'
      assert_select 'input#contact_is_public',
        name: 'contact[is_public]', value: '1', checked: 'checked'
      assert_select 'input#contact_confirmed_at',
        name: 'contact[confirmed_at]', type: 'datetime', value: '2001-02-03 04:05 AM MST'
      assert_select 'input#contact_expires_at',
        name: 'contact[expires_at]', type: 'datetime', value: '2002-03-04 05:06 AM MST'
      assert_select 'input#contact_name',
        name: 'contact[name]', value: 'Edit Name'
      assert_select 'input#contact_organization',
        name: 'contact[organization]', value: 'Edit Organization'
      # TODO: test for the rest of the fields expected


    end
  end

end
