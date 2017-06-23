require 'rails_helper'
require 'office'

describe Office, type: :model do
  before(:all) do
    @level = Level.first || FactoryGirl.create(:level)
    @level2 = Level.offset(1).first || FactoryGirl.create(:level)
  end

  describe 'acts_as_authority_controlled' do
    it 'should be in the “Democracy” area' do
      expect(Office.authority_area).to eq 'Democracy'
    end
  end

  describe '#level' do
    it 'should allow a level to be set' do
      level = Level.new
      office = Office.new
      office.level = level
      expect(office.level).to eq level
    end
  end

  describe '#previous' do
    it 'should allow a previous office to be set' do
      previous = Office.new
      office = Office.new
      office.previous = previous
      expect(office.previous).to eq previous
    end
  end

  describe 'validations' do
    let(:required) { $required = { filename: 'required', name: 'Required' } }
    it 'should validate with all required values' do
      expect(@level.offices.build(required).valid?).to be_truthy
    end
    describe 'of level' do
      it 'should fail if level is not set' do
        expect(Office.new(required).valid?).to be_falsey
      end
    end
    describe 'of filename' do
      let(:required) { $required = { name: 'Required' } }
      it 'should fail if filename is blank' do
        expect(@level.offices.build(required.merge(filename: '')).valid?).to be_falsey
      end
      it 'should fail if filename is nil' do
        expect(@level.offices.build(required).valid?).to be_falsey
      end
      it 'should fail if filename is a duplicate for the level' do
        @level.offices.build(name: 'Duplicate for level', filename: 'duplicate-on-level').save!
        expect(@level.offices.build(required.merge(filename: 'duplicate-on-level')).valid?).to be_falsey
      end
      it 'should validate if filename is a duplicate, but not for the level' do
        @level2.offices.build(name: 'Original', filename: 'duplicate').save!
        expect(@level.offices.build(required.merge(filename: 'duplicate')).valid?).to be_truthy
      end
      it 'should fail if filename contains invalid characters' do
        expect(@level.offices.build(required.merge(filename: 'Has invalid characters!')).valid?).to be_falsey
      end
    end
    describe 'of name' do
      let(:required) { $required = { filename: 'required' } }
      it 'should fail if name is blank' do
        expect(@level.offices.build(required.merge(name: '')).valid?).to be_falsey
      end
      it 'should fail if name is nil' do
        expect(@level.offices.build(required).valid?).to be_falsey
      end
    end
    describe 'of url' do
      it 'should fail if url is not an url string' do
        expect(@level.offices.build(required.merge(url: 'not an url')).valid?).to be_falsey
      end
      it 'should pass if the url is a valid url' do
        level = @level.offices.build(required.merge(url: 'https://valid.url:8080/should/pass')).valid?
        expect(level).to be_truthy
      end
    end
    describe 'of ended_on' do
      it 'should fail if ended_on is before established_on' do
        params = required.merge(established_on: '2001-02-03', ended_on: '2001-02-02')
        expect(@level.offices.build(params).valid?).to be_falsey
      end
    end
  end

  describe 'scopes' do
    describe '.active_on' do
      before(:all) do
        @level.offices.destroy_all
        @office1 = FactoryGirl.create(:office, level: @level)
        @office2 = FactoryGirl.create(:office, level: @level, established_on: '2001-01-01')
        @office3 = FactoryGirl.create(
          :office, level: @level, established_on: '2001-01-01', ended_on: '2001-01-31'
        )
        @office4 = FactoryGirl.create(:office, level: @level, established_on: '2001-01-02')
      end
      it 'should exclude offices that are established after the given date' do
        expect(@level.offices.active_on('2001-01-01').order(:id)).to eq [@office1, @office2, @office3]
      end
      it 'should exclude offices that ended before the given date' do
        expect(@level.offices.active_on('2001-02-01').order(:id)).to eq [@office1, @office2, @office4]
      end
    end
    describe '.from_param' do
      before(:all) do
        @office = Office.where(filename: 'the_param').first
        @office ||= FactoryGirl.create(:office, filename: 'the_param')
      end
      it 'should return the office that matches the param' do
        expect(Office.from_param('the_param')).to eq [@office]
      end
      it 'should return an empty list for a non-existent param' do
        expect(Office.from_param('non-existent-param')).to eq []
      end
    end
  end

  describe '#to_param' do
    it 'should return the filename' do
      expect(Office.new(filename: 'param').to_param).to eq 'param'
    end
  end

  describe '#descriptor' do
    it 'should return the name' do
      expect(Office.new(name: 'Described').descriptor).to eq 'Described'
    end
  end
end
