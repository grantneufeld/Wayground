require 'rails_helper'
require 'person'

describe 'contacts/index.html.erb', type: :view do
  let(:person) { $person = Person.new(filename: 'prsn') }
  let(:contact_attrs) do
    $contact_attrs = {
      position: 12, is_public: true,
      confirmed_at: '2001-02-03 04:05 AM MST'.to_datetime,
      expires_at: '2002-03-04 05:06 AM MST'.to_datetime,
      name: 'Index Name', organization: 'Index Organization',
      email: 'index@email.tld', twitter: 'indextwitter', url: 'http://index.url/',
      phone: '123-456-7890', phone2: '234-567-8901', fax: '345-6789-012',
      address1: 'Index Address', address2: '456 Street',
      city: 'Indexville', province: 'Indexia', country: 'Indexland', postal: 'A1B 2C3'
    }
  end
  let(:contact) do
    $contact = person.contacts.build(contact_attrs)
    $contact.item = person
    $contact
  end

  before(:each) do
    assign(:item, person)
    allow(contact).to receive(:to_param).and_return('123')
    assign(:contacts, [contact, contact])
    render
  end

  it "should present a list of the contacts" do
    assert_select 'h2', count: 2 do
      assert_select 'a', href: '/person/prsn/contacts/123', text: 'Contact 12'
    end
    assert_select 'p.vcard', count: 2 do
      assert_select 'a', class: 'url', href: 'http://index.url/', text: 'index.url'
    end
  end

end
