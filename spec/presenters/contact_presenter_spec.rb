# encoding: utf-8
require 'spec_helper'
require 'contact_presenter'
require_relative 'view_double'
require 'person'

describe ContactPresenter do
  before(:all) do
    User.delete_all
    @admin_user = FactoryGirl.create(:user)
    @normal_user = FactoryGirl.create(:user)
  end

  let(:view) { $view = ViewDouble.new }
  let(:item) do
    $item = Person.new(filename: 'item')
  end
  let(:contact_attrs) { $contact_attrs = { name: 'Contact'} }
  let(:contact) do
    $contact = item.contacts.build(contact_attrs)
    $contact.item = item
    $contact.id = 123
    $contact
  end
  let(:user) { $user = nil }

  let(:presenter) { $presenter = ContactPresenter.new(view: view, contact: contact, user: user) }

  describe 'initialization' do
    it 'should take a view parameter' do
      expect( ContactPresenter.new(view: :view).view ).to eq :view
    end
    it 'should take a contact parameter' do
      expect( ContactPresenter.new(contact: :contact).contact ).to eq :contact
    end
    it 'should take a user parameter' do
      expect( ContactPresenter.new(user: :user).user ).to eq :user
    end
  end

  describe '#present_attributes' do
    let(:contact_attrs) do
      $contact_attrs = {
        url: 'http://example.tld/', email: 'email@example.tld', phone: '123-456-7890',
        phone2: '234-567-8901', fax: '345-6789-012',
        address1: 'The Location', address2: '123 Street',
        city: 'Townsville', province: 'Somewhere', country: 'Stateland', postal: 'A1B 2C3',
        twitter: 'twitter_example'
      }
    end
    it 'should be the presented url, email, phone, short address, and twitter' do
      allow(presenter).to receive(:present_url).and_return('url')
      allow(presenter).to receive(:present_email).and_return('email')
      allow(presenter).to receive(:present_phone).and_return('phone')
      allow(presenter).to receive(:present_phone2).and_return('phone2')
      allow(presenter).to receive(:present_fax).and_return('fax')
      allow(presenter).to receive(:present_address).and_return('address')
      allow(presenter).to receive(:present_twitter).and_return('twitter')
      expect( presenter.present_attributes ).to eq "url\nemail\nphone\nphone2\nfax\naddress\ntwitter"
    end
    it 'should not include blank parts' do
      allow(presenter).to receive(:present_url).and_return('')
      allow(presenter).to receive(:present_email).and_return('')
      allow(presenter).to receive(:present_phone).and_return('phone')
      allow(presenter).to receive(:present_phone2).and_return('')
      allow(presenter).to receive(:present_fax).and_return('')
      allow(presenter).to receive(:present_address).and_return('')
      allow(presenter).to receive(:present_twitter).and_return('')
      expect( presenter.present_attributes ).to eq "phone"
    end
    it 'should accept a custom separator' do
      allow(presenter).to receive(:present_url).and_return('url')
      allow(presenter).to receive(:present_email).and_return('email')
      allow(presenter).to receive(:present_phone).and_return('phone')
      allow(presenter).to receive(:present_phone2).and_return('phone2')
      allow(presenter).to receive(:present_fax).and_return('fax')
      allow(presenter).to receive(:present_address).and_return('address')
      allow(presenter).to receive(:present_twitter).and_return('twitter')
      expect( presenter.present_attributes('•') ).to eq "url•email•phone•phone2•fax•address•twitter"
    end
    it 'should be html safe' do
      expect( presenter.present_attributes.html_safe? ).to be_truthy
    end
  end

  describe '#present_attributes_short' do
    let(:contact_attrs) do
      $contact_attrs = {
        url: 'http://example.tld/', email: 'email@example.tld', phone: '123-456-7890',
        address1: 'The Location', address2: '123 Street', twitter: 'twitter_example'
      }
    end
    it 'should not include phone2' do
      contact.phone2 = '•'
      expect( presenter.present_attributes_short ).not_to match /•/
    end
    it 'should not include fax' do
      contact.fax = '•'
      expect( presenter.present_attributes_short ).not_to match /•/
    end
    it 'should not include city' do
      contact.city = '•'
      expect( presenter.present_attributes_short ).not_to match /•/
    end
    it 'should not include province' do
      contact.province = '•'
      expect( presenter.present_attributes_short ).not_to match /•/
    end
    it 'should not include country' do
      contact.country = '•'
      expect( presenter.present_attributes_short ).not_to match /•/
    end
    it 'should not include postal' do
      contact.postal = '•'
      expect( presenter.present_attributes_short ).not_to match /•/
    end
    it 'should be the presented url, email, phone, short address, and twitter' do
      allow(presenter).to receive(:present_url).and_return('url')
      allow(presenter).to receive(:present_email).and_return('email')
      allow(presenter).to receive(:present_phone).and_return('phone')
      allow(presenter).to receive(:present_address_short).and_return('address')
      allow(presenter).to receive(:present_twitter).and_return('twitter')
      expect( presenter.present_attributes_short ).to eq "url\nemail\nphone\naddress\ntwitter"
    end
    it 'should not include blank parts' do
      allow(presenter).to receive(:present_url).and_return('')
      allow(presenter).to receive(:present_email).and_return('')
      allow(presenter).to receive(:present_phone).and_return('phone')
      allow(presenter).to receive(:present_address_short).and_return('')
      allow(presenter).to receive(:present_twitter).and_return('')
      expect( presenter.present_attributes_short ).to eq "phone"
    end
    it 'should accept a custom separator' do
      allow(presenter).to receive(:present_url).and_return('url')
      allow(presenter).to receive(:present_email).and_return('email')
      allow(presenter).to receive(:present_phone).and_return('phone')
      allow(presenter).to receive(:present_address_short).and_return('address')
      allow(presenter).to receive(:present_twitter).and_return('twitter')
      expect( presenter.present_attributes_short('•') ).to eq "url•email•phone•address•twitter"
    end
    it 'should be html safe' do
      expect( presenter.present_attributes_short.html_safe? ).to be_truthy
    end
  end

  describe '#present_url' do
    context 'with no url set' do
      it 'should return an empty string' do
        expect( presenter.present_url ).to eq ''
      end
      it 'should be html safe' do
        expect( presenter.present_url.html_safe? ).to be_truthy
      end
    end
    context 'with url set' do
      let(:contact_attrs) { $contact_attrs = {url: 'http://example.tld/'} }
      it 'should should include a link to the url' do
        expect( presenter.present_url ).to match /<a(?: [^>]*)? href="http:\/\/example.tld\/"/
      end
      it 'should should set the link class to “url”' do
        expect( presenter.present_url ).to match /<a(?: [^>]*)? class="url"/
      end
      it 'should should strip away the “http://” part and trailing “/” when showing the url' do
        expect( presenter.present_url ).to match />example.tld</
      end
      it 'should wrap the response in a span element of class “home”' do
        expect( presenter.present_url ).to match /\A<span(?: [^>]*)? class="home"[^>]*>/
        expect( presenter.present_url ).to match /<\/span>[\r\n]*\z/
      end
      it 'should include a “Website:” label' do
        expect( presenter.present_url ).to match(
          /<span(?: [^>]*)? class="label"[^>]*>Website: <\/span>/
        )
      end
      it 'should be html safe' do
        expect( presenter.present_url.html_safe? ).to be_truthy
      end
    end
  end

  describe '#present_email' do
    context 'with no email set' do
      it 'should return an empty string' do
        expect( presenter.present_email ).to eq ''
      end
      it 'should be html safe' do
        expect( presenter.present_email.html_safe? ).to be_truthy
      end
    end
    context 'with email set' do
      let(:contact_attrs) { $contact_attrs = { email: 'example@email.tld' } }
      it 'should should include a link to the email account' do
        expect( presenter.present_email ).to match(
          /<a href="mailto:example@email.tld"[^>]*>example@email.tld<\/a>/
        )
      end
      it 'should should set the link class to “url”' do
        expect( presenter.present_email ).to match /<a(?: [^>]*)? class="email"/
      end
      it 'should wrap the response in a span element of class “email”' do
        expect( presenter.present_email ).to match /\A<span(?: [^>]*)? class="emailadr"[^>]*>/
        expect( presenter.present_email ).to match /<\/span>[\r\n]*\z/
      end
      it 'should include a “Email:” label' do
        expect( presenter.present_email ).to match(
          /<span(?: [^>]*)? class="label"[^>]*>Email: <\/span>/
        )
      end
      it 'should be html safe' do
        expect( presenter.present_email.html_safe? ).to be_truthy
      end
    end
  end

  describe '#present_phone' do
    context 'with no phone set' do
      it 'should return an empty string' do
        expect( presenter.present_phone ).to eq ''
      end
      it 'should be html safe' do
        expect( presenter.present_phone.html_safe? ).to be_truthy
      end
    end
    context 'with phone set' do
      let(:contact_attrs) { $contact_attrs = { phone: '123-456-7890' } }
      it 'should should include the phone, wrapped in a span of class “tel”' do
        expect( presenter.present_phone ).to match /<span class="tel"[^>]*>123-456-7890<\/span>/
      end
      it 'should wrap the response in a span element of class “phone”' do
        expect( presenter.present_phone ).to match /\A<span(?: [^>]*)? class="phone"[^>]*>/
        expect( presenter.present_phone ).to match /<\/span>[\r\n]*\z/
      end
      it 'should include a “Phone:” label' do
        expect( presenter.present_phone ).to match(
          /<span(?: [^>]*)? class="label"[^>]*>Phone: <\/span>/
        )
      end
      it 'should be html safe' do
        expect( presenter.present_phone.html_safe? ).to be_truthy
      end
    end
  end

  describe '#present_phone2' do
    context 'with no phone2 set' do
      it 'should return an empty string' do
        expect( presenter.present_phone2 ).to eq ''
      end
      it 'should be html safe' do
        expect( presenter.present_phone2.html_safe? ).to be_truthy
      end
    end
    context 'with phone2 set' do
      let(:contact_attrs) { $contact_attrs = { phone2: '234-567-8901' } }
      it 'should should include the phone2, wrapped in a span of class “tel”' do
        expect( presenter.present_phone2 ).to match /<span class="tel"[^>]*>234-567-8901<\/span>/
      end
      it 'should wrap the response in a span element of class “phone”' do
        expect( presenter.present_phone2 ).to match /\A<span(?: [^>]*)? class="phone"[^>]*>/
        expect( presenter.present_phone2 ).to match /<\/span>[\r\n]*\z/
      end
      it 'should include a “Phone:” label' do
        expect( presenter.present_phone2 ).to match(
          /<span(?: [^>]*)? class="label"[^>]*>Phone: <\/span>/
        )
      end
      it 'should be html safe' do
        expect( presenter.present_phone2.html_safe? ).to be_truthy
      end
    end
  end

  describe '#present_fax' do
    context 'with no fax set' do
      it 'should return an empty string' do
        expect( presenter.present_fax ).to eq ''
      end
      it 'should be html safe' do
        expect( presenter.present_fax.html_safe? ).to be_truthy
      end
    end
    context 'with fax set' do
      let(:contact_attrs) { $contact_attrs = { fax: '345-6789-012' } }
      it 'should should include the fax, wrapped in a span of class “tel”' do
        expect( presenter.present_fax ).to match /<span class="value"[^>]*>345-6789-012<\/span>/
      end
      it 'should wrap the response in a span element of class “fax tel”' do
        expect( presenter.present_fax ).to match /\A<span(?: [^>]*)? class="fax tel"[^>]*>/
        expect( presenter.present_fax ).to match /<\/span>[\r\n]*\z/
      end
      it 'should include a “Fax:” label' do
        expect( presenter.present_fax ).to match(
          /<span(?: [^>]*)? class="label type"[^>]*>Fax: <\/span>/
        )
      end
      it 'should be html safe' do
        expect( presenter.present_fax.html_safe? ).to be_truthy
      end
    end
  end

  describe '#present_address' do
    context 'with no address or locality set' do
      it 'should return an empty string' do
        expect( presenter.present_address ).to eq ''
      end
      it 'should be html safe' do
        expect( presenter.present_address.html_safe? ).to be_truthy
      end
    end
    context 'with with both address and locality set' do
      let(:contact_attrs) { $contact_attrs = { address1: 'The Location', city: 'Townsville' } }
      it 'should wrap the response in a span element of class “address”' do
        expect( presenter.present_address ).to match /\A<span(?: [^>]*)? class="address"/
        expect( presenter.present_address ).to match /<\/span>[\r\n]*\z/
      end
      it 'should include a “Address:” label' do
        expect( presenter.present_address ).to match(
          /<span(?: [^>]*)? class="label"[^>]*>Address: <\/span>/
        )
      end
      it 'should should include the address and locality, wrapped in a span of class “adr”' do
        allow(presenter).to receive(:present_street_address).and_return('•')
        allow(presenter).to receive(:present_locality).and_return('¶')
        expect( presenter.present_address(':') ).to match(/<span class="adr">•:¶<\/span>/)
      end
      it 'should use a default separator' do
        allow(presenter).to receive(:present_street_address).and_return('•')
        allow(presenter).to receive(:present_locality).and_return('¶')
        expect( presenter.present_address ).to match(/•;\n¶/)
      end
      it 'should be html safe' do
        expect( presenter.present_address.html_safe? ).to be_truthy
      end
    end
    context 'with with just the address set' do
      let(:contact_attrs) { $contact_attrs = { address1: 'The Location' } }
      it 'should should include the address , wrapped in a span of class “adr”' do
        allow(presenter).to receive(:present_street_address).and_return('•')
        expect( presenter.present_address(':') ).to match(/<span class="adr">•<\/span>/)
      end
    end
    context 'with with just the locality set' do
      let(:contact_attrs) { $contact_attrs = { city: 'Townsville' } }
      it 'should should include the address , wrapped in a span of class “adr”' do
        allow(presenter).to receive(:present_locality).and_return('¶')
        expect( presenter.present_address(':') ).to match(/<span class="adr">¶<\/span>/)
      end
    end
  end

  describe '#present_address_short' do
    context 'with no address lines set' do
      it 'should return an empty string' do
        expect( presenter.present_address_short ).to eq ''
      end
      it 'should be html safe' do
        expect( presenter.present_address_short.html_safe? ).to be_truthy
      end
    end
    context 'with with both address1 and address2 set' do
      let(:contact_attrs) { $contact_attrs = { address1: 'The Location', address2: '123 Street' } }
      it 'should should include the street address, wrapped in a span of class “adr”' do
        allow(presenter).to receive(:present_street_address).and_return('•')
        expect( presenter.present_address_short ).to match(/<span class="adr">•<\/span>/)
      end
      it 'should wrap the response in a span element of class “address”' do
        expect( presenter.present_address_short ).to match /\A<span(?: [^>]*)? class="address"[^>]*>/
        expect( presenter.present_address_short ).to match /<\/span>[\r\n]*\z/
      end
      it 'should include a “Address:” label' do
        expect( presenter.present_address_short ).to match(
          /<span(?: [^>]*)? class="label"[^>]*>Address: <\/span>/
        )
      end
      it 'should be html safe' do
        expect( presenter.present_address_short.html_safe? ).to be_truthy
      end
    end
  end

  describe '#present_street_address' do
    context 'with no address lines set' do
      it 'should return an empty string' do
        expect( presenter.present_street_address ).to eq ''
      end
      it 'should be html safe' do
        expect( presenter.present_street_address.html_safe? ).to be_truthy
      end
    end
    context 'with address1 set' do
      let(:contact_attrs) { $contact_attrs = { address1: 'The Location' } }
      it 'should return the address wrapped in a span of class “street-address”' do
        expect( presenter.present_street_address ).to eq '<span class="street-address">The Location</span>'
      end
      it 'should be html safe' do
        expect( presenter.present_street_address.html_safe? ).to be_truthy
      end
    end
    context 'with address2 set' do
      let(:contact_attrs) { $contact_attrs = { address2: '123 Street' } }
      it 'should return the address wrapped in a span of class “street-address”' do
        expect( presenter.present_street_address ).to eq '<span class="street-address">123 Street</span>'
      end
      it 'should be html safe' do
        expect( presenter.present_street_address.html_safe? ).to be_truthy
      end
    end
    context 'with with both address1 and address2 set' do
      let(:contact_attrs) { $contact_attrs = { address1: 'The Location', address2: '123 Street' } }
      it 'should return the address wrapped in a span of class “street-address”' do
        expect( presenter.present_street_address ).to eq(
          '<span class="street-address">The Location; 123 Street</span>'
        )
      end
      it 'should be html safe' do
        expect( presenter.present_street_address.html_safe? ).to be_truthy
      end
    end
  end

  describe '#present_locality' do
    context 'with no locality set' do
      it 'should return an empty string' do
        expect( presenter.present_locality ).to eq ''
      end
      it 'should be html safe' do
        expect( presenter.present_locality.html_safe? ).to be_truthy
      end
    end
    context 'with just city set' do
      let(:contact_attrs) { $contact_attrs = { city: 'Townsville' } }
      it 'should should be a span of class “locality” wrapped around the city' do
        expect( presenter.present_locality ).to eq '<span class="locality">Townsville</span>'
      end
      it 'should be html safe' do
        expect( presenter.present_locality.html_safe? ).to be_truthy
      end
    end
    context 'with just province set' do
      let(:contact_attrs) { $contact_attrs = { province: 'Chunkland' } }
      it 'should should be a span of class “region” wrapped around the province' do
        expect( presenter.present_locality ).to eq '<span class="region">Chunkland</span>'
      end
      it 'should be html safe' do
        expect( presenter.present_locality.html_safe? ).to be_truthy
      end
    end
    context 'with just country set' do
      let(:contact_attrs) { $contact_attrs = { country: 'Landistan' } }
      it 'should should be a span of class “country-name” wrapped around the country' do
        expect( presenter.present_locality ).to eq '<span class="country-name">Landistan</span>'
      end
      it 'should be html safe' do
        expect( presenter.present_locality.html_safe? ).to be_truthy
      end
    end
    context 'with just postal set' do
      let(:contact_attrs) { $contact_attrs = { postal: 'T2T 2T2' } }
      it 'should return an empty string' do
        expect( presenter.present_locality ).to eq ''
      end
      it 'should be html safe' do
        expect( presenter.present_locality.html_safe? ).to be_truthy
      end
    end
    context 'with all locality fields set' do
      let(:contact_attrs) do
        $contact_attrs = {
          city: 'Townsville', province: 'Chunkland', country: 'Landistan', postal: 'T2T 2T2'
        }
      end
      it 'should should be a span of class “country-name” wrapped around the country' do
        expect( presenter.present_locality ).to eq(
          '<span class="locality">Townsville</span>, ' +
          '<span class="region">Chunkland</span>, ' +
          '<span class="country-name">Landistan</span>, ' +
          '<span class="postal-code">T2T 2T2</span>'
        )
      end
      it 'should be html safe' do
        expect( presenter.present_locality.html_safe? ).to be_truthy
      end
    end
  end

  describe '#present_twitter' do
    context 'with no twitter set' do
      it 'should return an empty string' do
        expect( presenter.present_twitter ).to eq ''
      end
      it 'should be html safe' do
        expect( presenter.present_twitter.html_safe? ).to be_truthy
      end
    end
    context 'with twitter set' do
      let(:contact_attrs) { $contact_attrs = { twitter: 'example' } }
      it 'should should include a link to the twitter account' do
        expect( presenter.present_twitter ).to match(
          /<a href="https:\/\/twitter.com\/example"[^>]*>@example<\/a>/
        )
      end
      it 'should should set the link class to “url”' do
        expect( presenter.present_twitter ).to match /<a(?: [^>]*)? class="url"/
      end
      it 'should wrap the response in a span element of class “twitter”' do
        expect( presenter.present_twitter ).to match /\A<span(?: [^>]*)? class="twitter"[^>]*>/
        expect( presenter.present_twitter ).to match /<\/span>[\r\n]*\z/
      end
      it 'should include a “Twitter:” label' do
        expect( presenter.present_twitter ).to match(
          /<span(?: [^>]*)? class="label"[^>]*>Twitter: <\/span>/
        )
      end
      it 'should be html safe' do
        expect( presenter.present_twitter.html_safe? ).to be_truthy
      end
    end
  end

  describe '#present_dates' do
    context 'with no dates' do
      it 'should return an empty string' do
        expect( presenter.present_dates ).to eq ''
      end
      it 'should be html safe' do
        expect( presenter.present_dates.html_safe? ).to be_truthy
      end
    end
    context 'with confirmed_at set' do
      let(:contact_attrs) { $contact_attrs = { confirmed_at: DateTime.parse('2001-02-03 04:05 AM MST') } }
      it 'should return the date and time prefaced with “Established at”' do
        expect( presenter.present_dates ).to match /Established at 4:05 AM on Saturday, February 3, 2001/
      end
      it 'should wrap the response in a paragraph element' do
        expect( presenter.present_dates ).to match /\A<p(?: [^>]*)?>/
        expect( presenter.present_dates ).to match /<\/p>[\r\n]*\z/
      end
      it 'should be html safe' do
        expect( presenter.present_dates.html_safe? ).to be_truthy
      end
    end
    context 'with expires_at set to the past' do
      let(:contact_attrs) { $contact_attrs = { expires_at: DateTime.parse('2002-03-04 05:06 AM MST') } }
      it 'should return the date and time prefaced with “Expired at”' do
        expect( presenter.present_dates ).to match /Expired at 5:06 AM on Monday, March 4, 2002/
      end
      it 'should wrap the response in a paragraph element' do
        expect( presenter.present_dates ).to match /\A<p(?: [^>]*)?>/
        expect( presenter.present_dates ).to match /<\/p>[\r\n]*\z/
      end
      it 'should be html safe' do
        expect( presenter.present_dates.html_safe? ).to be_truthy
      end
    end
    context 'with expires_at set to the future' do
      let(:contact_attrs) { $contact_attrs = { expires_at: DateTime.parse('2123-04-05 06:07 AM MST') } }
      it 'should return the date and time prefaced with “Expired at”' do
        expect( presenter.present_dates ).to match /Expires at 6:07 AM on Monday, April 5, 2123/
      end
      it 'should wrap the response in a paragraph element' do
        expect( presenter.present_dates ).to match /\A<p(?: [^>]*)?>/
        expect( presenter.present_dates ).to match /<\/p>[\r\n]*\z/
      end
      it 'should be html safe' do
        expect( presenter.present_dates.html_safe? ).to be_truthy
      end
    end
    context 'with both dates set' do
      let(:contact_attrs) do
        $contact_attrs = {
          confirmed_at: DateTime.parse('2001-02-03 04:05 AM MST'),
          expires_at: DateTime.parse('2002-03-04 05:06 AM MST')
        }
      end
      it 'should default to a line-break element separator' do
        expect( presenter.present_dates ).to match /<br \/>/
      end
      it 'should use a given separator' do
        expect( presenter.present_dates('CUSTOM') ).to match /CUSTOM/
      end
      it 'should return include both dates, separated by the separator' do
        expect( presenter.present_dates('•') ).to match(
          /4:05 AM on Saturday, February 3, 2001.*•.+5:06 AM on Monday, March 4, 2002/
        )
      end
      it 'should be html safe' do
        expect( presenter.present_dates.html_safe? ).to be_truthy
      end
    end
  end

  describe '#present_actions' do
    context 'with no user' do
      it 'should return an empty string' do
        expect( presenter.present_actions ).to eq ''
      end
      it 'should be html safe' do
        expect( presenter.present_actions.html_safe? ).to be_truthy
      end
    end
    context 'with a user' do
      let(:user) { $user = @normal_user }
      it 'should return an empty string' do
        expect( presenter.present_actions ).to eq ''
      end
      it 'should be html safe' do
        expect( presenter.present_actions.html_safe? ).to be_truthy
      end
    end
    context 'with an admin user' do
      let(:user) { $user = @admin_user }
      it 'should contain an edit link' do
        expect( presenter.present_actions ).to match(
          /<a (?:[^>]* )?href="\/people\/item\/contacts\/123\/edit"[^>]*>Edit/
        )
      end
      it 'should contain a delete link' do
        expect( presenter.present_actions ).to match(
          /<a (?:[^>]* )?href="\/people\/item\/contacts\/123\/delete"[^>]*>Delete/
        )
      end
      it 'should be html safe' do
        expect( presenter.present_actions.html_safe? ).to be_truthy
      end
    end
  end

end
