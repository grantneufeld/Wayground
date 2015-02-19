require 'rails_helper'
require 'person'

describe 'contacts/show.html.erb', type: :view do
  let(:person) { $person = Person.new(filename: 'prsn') }
  let(:contact_attrs) do
    $contact_attrs = {
      position: 12, is_public: true,
      confirmed_at: '2001-02-03 04:05 AM MST'.to_datetime,
      expires_at: '2002-03-04 05:06 AM MST'.to_datetime,
      name: 'Show Name', organization: 'Show Organization',
      email: 'show@email.tld', twitter: 'showtwitter', url: 'http://show.url/',
      phone: '123-456-7890', phone2: '234-567-8901', fax: '345-6789-012',
      address1: 'Show Address', address2: '456 Street',
      city: 'Showville', province: 'Showia', country: 'Showland', postal: 'A1B 2C3'
    }
  end
  let(:contact) { $contact = person.contacts.build(contact_attrs) }

  before(:each) do
    assign(:item, person)
    assign(:contact, contact)
    render
  end

  it 'renders the name' do
    expect( rendered ).to match /Show Name/
  end
  it 'renders a link to the url' do
    expect( rendered ).to match /<a(?: [^>]*)? href="http:\/\/show.url\/"[^>]*>show.url/
  end
  # TODO: check that the other contact fields are rendered

end
