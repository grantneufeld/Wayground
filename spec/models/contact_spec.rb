# encoding: utf-8
require 'spec_helper'
require 'contact'
require 'person'

describe Contact do

  before(:all) do
    Contact.delete_all
    @item = Person.first || FactoryGirl.create(:person)
  end

  describe 'acts_as_authority_controlled' do
    it 'should be in the “Democracy” area' do
      Contact.authority_area.should eq 'Democracy'
    end
  end

  describe 'attribute mass assignment security' do
    it 'should not allow item' do
      expect {
        Contact.new(item: Person.new)
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
    it 'should not allow item_type' do
      expect {
        Contact.new(item_type: 'Person')
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
    it 'should not allow item_id' do
      expect {
        Contact.new(item_id: 1)
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
    it 'should allow position' do
      expect( Contact.new(position: 123).position ).to eq 123
    end
    it 'should allow is_public' do
      expect( Contact.new(is_public: true).is_public ).to be_true
    end
    it 'should allow confirmed_at' do
      confirmed_at = DateTime.parse '2001-02-03 04:05:06'
      expect( Contact.new(confirmed_at: confirmed_at).confirmed_at ).to eq confirmed_at
    end
    it 'should allow expires_at' do
      expires_at = DateTime.parse '2007-08-09 10:11:12'
      expect( Contact.new(expires_at: expires_at).expires_at ).to eq expires_at
    end
    it 'should allow name' do
      name = 'example name'
      expect( Contact.new(name: name).name ).to eq name
    end
    it 'should allow organization' do
      organization = 'example organization'
      expect( Contact.new(organization: organization).organization ).to eq organization
    end
    it 'should allow email' do
      email = 'example email'
      expect( Contact.new(email: email).email ).to eq email
    end
    it 'should allow twitter' do
      twitter = 'example twitter'
      expect( Contact.new(twitter: twitter).twitter ).to eq twitter
    end
    it 'should allow url' do
      url = 'example url'
      expect( Contact.new(url: url).url ).to eq url
    end
    it 'should allow phone' do
      phone = 'example phone'
      expect( Contact.new(phone: phone).phone ).to eq phone
    end
    it 'should allow phone2' do
      phone2 = 'example phone2'
      expect( Contact.new(phone2: phone2).phone2 ).to eq phone2
    end
    it 'should allow fax' do
      fax = 'example fax'
      expect( Contact.new(fax: fax).fax ).to eq fax
    end
    it 'should allow address1' do
      address1 = 'example address1'
      expect( Contact.new(address1: address1).address1 ).to eq address1
    end
    it 'should allow address2' do
      address2 = 'example address2'
      expect( Contact.new(address2: address2).address2 ).to eq address2
    end
    it 'should allow city' do
      city = 'example city'
      expect( Contact.new(city: city).city ).to eq city
    end
    it 'should allow province' do
      province = 'example province'
      expect( Contact.new(province: province).province ).to eq province
    end
    it 'should allow country' do
      country = 'example country'
      expect( Contact.new(country: country).country ).to eq country
    end
    it 'should allow postal' do
      postal = 'example postal'
      expect( Contact.new(postal: postal).postal ).to eq postal
    end
  end

  describe '#item' do
    it 'should allow a user to be set' do
      item = Person.new
      contact = Contact.new
      contact.item = item
      expect( contact.item ).to eq item
    end
  end

  describe 'validation' do
    let(:required) { $required = {} }
    it 'should validate with all required values' do
      expect( @item.contacts.build(required).valid? ).to be_true
    end
    describe 'of item' do
      it 'should fail if item is not set' do
        expect( Contact.new(required).valid? ).to be_false
      end
    end
    describe 'of email' do
      it 'should validate if email is nil' do
        expect( @item.contacts.build(required.merge(email: nil)).valid? ).to be_true
      end
      it 'should validate if email is blank' do
        expect( @item.contacts.build(required.merge(email: '')).valid? ).to be_true
      end
      it 'should validate if email is a proper email address' do
        expect( @item.contacts.build(required.merge(email: 'proper@email.tld')).valid? ).to be_true
      end
      it 'should fail if email is an invalid format for an email address' do
        expect( @item.contacts.build(required.merge(email: '<improper@email.tld>')).valid? ).to be_false
      end
    end
    describe 'of twitter' do
      it 'should validate if twitter is nil' do
        expect( @item.contacts.build(required.merge(twitter: nil)).valid? ).to be_true
      end
      it 'should validate if twitter is blank' do
        expect( @item.contacts.build(required.merge(twitter: '')).valid? ).to be_true
      end
      it 'should validate if twitter is lower-case characters' do
        expect( @item.contacts.build(required.merge(twitter: 'abcdefghijklmnopqrstuvwxyz')).valid? ).to be_true
      end
      it 'should validate if twitter is upper-case characters' do
        expect( @item.contacts.build(required.merge(twitter: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')).valid? ).to be_true
      end
      it 'should validate if twitter is integer digits' do
        expect( @item.contacts.build(required.merge(twitter: '0123456789')).valid? ).to be_true
      end
      it 'should validate if twitter contains underscores and dashes' do
        expect( @item.contacts.build(required.merge(twitter: '_-')).valid? ).to be_true
      end
      it 'should fail if twitter contains invalid characters' do
        expect( @item.contacts.build(required.merge(twitter: 'invalid: !')).valid? ).to be_false
      end
    end
    describe 'of url' do
      it 'should validate if url is nil' do
        expect( @item.contacts.build(required.merge(url: nil)).valid? ).to be_true
      end
      it 'should validate if url is blank' do
        expect( @item.contacts.build(required.merge(url: '')).valid? ).to be_true
      end
      it 'should validate if a proper url' do
        expect( @item.contacts.build(required.merge(url: 'https://valid.url:123/stuff.etc')).valid? ).to be_true
      end
      it 'should fail if an improper url' do
        expect( @item.contacts.build(required.merge(url: 'invalid://not.url/')).valid? ).to be_false
      end
    end
  end

  describe 'scopes' do
    before(:all) do
      Contact.delete_all
      @contact2 = @item.contacts.create(is_public: true, name: '2 public', position: 2)
      @contact3 = @item.contacts.create(is_public: false, name: '3 private', position: 3)
      @contact1 = @item.contacts.create(is_public: false, name: '1 private', position: 1)
      @item.reload
    end
    describe '.only_public' do
      it 'should exclude contacts that have ‘is_public’ set to false' do
        expect( @item.contacts.only_public.to_a ).to eq [@contact2]
      end
    end
    describe 'default' do
      it 'should order the contacts in ascending order by position' do
        expect( @item.contacts.to_a ).to eq [@contact1, @contact2, @contact3]
      end
    end
  end

  describe '#descriptor' do
    let(:item) { $item = Person.new(fullname: 'The Item') }
    context 'with all applicable values' do
      it 'should return the name' do
        contact = item.contacts.build(name: 'The Name', organization: 'The Org', position: 123)
        contact.item = item
        expect( contact.descriptor ).to eq 'The Name'
      end
    end
    context 'with no name' do
      it 'should return the organization' do
        contact = item.contacts.build(organization: 'The Org', position: 123)
        contact.item = item
        expect( contact.descriptor ).to eq 'The Org'
      end
    end
    context 'with no name or organization' do
      it 'should return the item descriptor and position' do
        contact = item.contacts.build(position: 123)
        contact.item = item
        expect( contact.descriptor ).to eq 'The Item contact 123'
      end
    end
  end

  describe '#items_for_path' do
    context 'with a person as item' do
      it 'should return an array of the person and contact' do
        person = Person.new
        contact = person.contacts.build
        contact.item = person
        expect( contact.items_for_path ).to eq [person, contact]
      end
    end
    context 'with a candidate as item' do
      it 'should return an array of the level, election, ballot, candidate and contact' do
        level = Level.new
        election = level.elections.build
        election.level = level
        ballot = election.ballots.build
        ballot.election = election
        candidate = ballot.candidates.build
        candidate.ballot = ballot
        contact = candidate.contacts.build
        contact.item = candidate
        expect( contact.items_for_path ).to eq [level, election, ballot, candidate, contact]
      end
    end
  end

end
