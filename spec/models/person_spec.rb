require 'rails_helper'
require 'person'

describe Person, type: :model do
  describe 'acts_as_authority_controlled' do
    it 'should be in the “Democracy” area' do
      expect(Person.authority_area).to eq 'Democracy'
    end
  end

  describe '#user' do
    it 'should allow a user to be set' do
      user = User.new
      person = Person.new
      person.user = user
      expect(person.user).to eq user
    end
  end

  describe '#submitter' do
    it 'should allow a submitter to be set' do
      submitter = User.new
      person = Person.new
      person.submitter = submitter
      expect(person.submitter).to eq submitter
    end
  end

  describe 'validations' do
    let(:required) { $required = { filename: 'required', fullname: 'Required' } }
    it 'should validate with all required values' do
      expect(Person.new(required).valid?).to be_truthy
    end
    describe 'of filename' do
      let(:required) { $required = { fullname: 'Required' } }
      it 'should fail if filename is blank' do
        expect(Person.new(required.merge(filename: '')).valid?).to be_falsey
      end
      it 'should fail if filename is nil' do
        expect(Person.new(required).valid?).to be_falsey
      end
      it 'should fail if filename is a duplicate ' do
        Person.new(fullname: 'Duplicate Filename', filename: 'duplicate-filename').save!
        expect(Person.new(required.merge(filename: 'duplicate-filename')).valid?).to be_falsey
      end
      it 'should fail if filename contains invalid characters' do
        expect(Person.new(required.merge(filename: 'Has invalid characters!')).valid?).to be_falsey
      end
    end
    describe 'of fullname' do
      let(:required) { $required = { filename: 'required' } }
      it 'should fail if fullname is blank' do
        expect(Person.new(required.merge(fullname: '')).valid?).to be_falsey
      end
      it 'should fail if fullname is nil' do
        expect(Person.new(required).valid?).to be_falsey
      end
    end
  end

  describe 'scopes' do
    describe '.from_param' do
      before(:all) do
        @person = Person.where(filename: 'the_param').first
        @person ||= FactoryGirl.create(:person, filename: 'the_param')
      end
      it 'should return the person that matches the param' do
        expect(Person.from_param('the_param')).to eq [@person]
      end
      it 'should return an empty list for a non-existent param' do
        expect(Person.from_param('non-existent-param')).to eq []
      end
    end
  end

  describe '#to_param' do
    it 'should return the filename' do
      expect(Person.new(filename: 'param').to_param).to eq 'param'
    end
  end

  describe '#descriptor' do
    it 'should return the fullname' do
      person = Person.new(fullname: 'The Name')
      expect(person.descriptor).to eq 'The Name'
    end
  end

  describe '#items_for_path' do
    it 'should return an array of just the person' do
      person = Person.new
      expect(person.items_for_path).to eq [person]
    end
  end
end
