require 'rails_helper'
require 'contact'
require 'person'

describe Contact, type: :model do
  before(:all) do
    Contact.delete_all
    @item = Person.first || FactoryGirl.create(:person)
  end

  describe 'acts_as_authority_controlled' do
    it 'should be in the “Democracy” area' do
      expect(Contact.authority_area).to eq 'Democracy'
    end
  end

  describe '#item' do
    it 'should allow a user to be set' do
      item = Person.new
      contact = Contact.new
      contact.item = item
      expect(contact.item).to eq item
    end
  end

  describe 'validation' do
    let(:required) { $required = {} }
    it 'should validate with all required values' do
      expect(@item.contacts.build(required).valid?).to be_truthy
    end
    describe 'of item' do
      it 'should fail if item is not set' do
        expect(Contact.new(required).valid?).to be_falsey
      end
    end
    describe 'of email' do
      it 'should validate if email is nil' do
        expect(@item.contacts.build(required.merge(email: nil)).valid?).to be_truthy
      end
      it 'should validate if email is blank' do
        expect(@item.contacts.build(required.merge(email: '')).valid?).to be_truthy
      end
      it 'should validate if email is a proper email address' do
        expect(@item.contacts.build(required.merge(email: 'proper@email.tld')).valid?).to be_truthy
      end
      it 'should fail if email is an invalid format for an email address' do
        expect(@item.contacts.build(required.merge(email: '<improper@email.tld>')).valid?).to be_falsey
      end
    end
    describe 'of twitter' do
      it 'should validate if twitter is nil' do
        expect(@item.contacts.build(required.merge(twitter: nil)).valid?).to be_truthy
      end
      it 'should validate if twitter is blank' do
        expect(@item.contacts.build(required.merge(twitter: '')).valid?).to be_truthy
      end
      it 'should validate if twitter is lower-case characters' do
        new_contact = @item.contacts.build(required.merge(twitter: 'abcdefghijklmnopqrstuvwxyz'))
        expect(new_contact.valid?).to be_truthy
      end
      it 'should validate if twitter is upper-case characters' do
        new_contact = @item.contacts.build(required.merge(twitter: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'))
        expect(new_contact.valid?).to be_truthy
      end
      it 'should validate if twitter is integer digits' do
        expect(@item.contacts.build(required.merge(twitter: '0123456789')).valid?).to be_truthy
      end
      it 'should validate if twitter contains underscores and dashes' do
        expect(@item.contacts.build(required.merge(twitter: '_-')).valid?).to be_truthy
      end
      it 'should fail if twitter contains invalid characters' do
        expect(@item.contacts.build(required.merge(twitter: 'invalid: !')).valid?).to be_falsey
      end
    end
    describe 'of url' do
      it 'should validate if url is nil' do
        expect(@item.contacts.build(required.merge(url: nil)).valid?).to be_truthy
      end
      it 'should validate if url is blank' do
        expect(@item.contacts.build(required.merge(url: '')).valid?).to be_truthy
      end
      it 'should validate if a proper url' do
        new_contact = @item.contacts.build(required.merge(url: 'https://valid.url:123/stuff.etc'))
        expect(new_contact.valid?).to be_truthy
      end
      it 'should fail if an improper url' do
        expect(@item.contacts.build(required.merge(url: 'invalid://not.url/')).valid?).to be_falsey
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
        expect(@item.contacts.only_public.to_a).to eq [@contact2]
      end
    end
    describe 'default' do
      it 'should order the contacts in ascending order by position' do
        expect(@item.contacts.to_a).to eq [@contact1, @contact2, @contact3]
      end
    end
  end

  describe '#descriptor' do
    let(:item) { $item = Person.new(fullname: 'The Item') }
    context 'with all applicable values' do
      it 'should return the name' do
        contact = item.contacts.build(name: 'The Name', organization: 'The Org', position: 123)
        contact.item = item
        expect(contact.descriptor).to eq 'The Name'
      end
    end
    context 'with no name' do
      it 'should return the organization' do
        contact = item.contacts.build(organization: 'The Org', position: 123)
        contact.item = item
        expect(contact.descriptor).to eq 'The Org'
      end
    end
    context 'with no name or organization' do
      it 'should return the item descriptor and position' do
        contact = item.contacts.build(position: 123)
        contact.item = item
        expect(contact.descriptor).to eq 'The Item contact 123'
      end
    end
  end

  describe '#items_for_path' do
    context 'with a person as item' do
      it 'should return an array of the person and contact' do
        person = Person.new
        contact = person.contacts.build
        contact.item = person
        expect(contact.items_for_path).to eq [person, contact]
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
        expect(contact.items_for_path).to eq [level, election, ballot, candidate, contact]
      end
    end
  end
end
