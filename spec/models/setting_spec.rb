require 'rails_helper'

describe Setting, type: :model do
  describe 'acts_as_authority_controlled' do
    it 'should be in the “Admin” area' do
      expect(Setting.authority_area).to eq 'Admin'
    end
  end

  describe 'validation' do
    describe 'of key' do
      it 'should require key to be set' do
        expect(Setting.new(key: 'set').valid?).to be_truthy
      end
      it 'should fail if key is not set' do
        expect(Setting.new.valid?).to be_falsey
      end
    end
  end

  describe '.[]' do
    it 'should return the value of the setting with the specified key' do
      key = 'indexed lookup'
      val = 'from index'
      Setting.create(key: key, value: val)
      expect(Setting[key]).to eq val
    end
    it 'should return nil if there is no setting matching the key' do
      expect(Setting['non-existant']).to be_nil
    end
    it 'should accept symbols for keys' do
      value = 'value for symbol'
      Setting.create(key: 'symbolickey', value: value)
      expect(Setting[:symbolickey]).to eq value
    end
  end

  describe '.[]=' do
    it 'should set the value of the setting for the key' do
      key = 'exists to be changed'
      new_val = 'has been changed'
      Setting.create(key: key, value: 'original')
      Setting[key] = new_val
      expect(Setting[key]).to eq new_val
    end
    it 'should create a setting for the key if one doesn’t exist' do
      key = 'not already existing'
      new_val = 'created with new value'
      Setting[key] = new_val
      expect(Setting[key]).to eq new_val
    end
    it 'should accept symbols for keys' do
      value = 'assigned for symbol'
      Setting[:assignbysymbol] = value
      expect(Setting['assignbysymbol']).to eq value
    end
  end

  describe '.destroy' do
    it 'should destroy the setting for the key' do
      key = 'destroy this'
      Setting.create(key: key, value: 'to be removed')
      Setting.destroy(key)
      expect(Setting.where(key: key).first).to be_nil
    end
    it 'should do nothing if there is no setting for the key' do
      key = 'no setting for key'
      Setting.destroy(key)
      expect(Setting.where(key: key).first).to be_nil
    end
    it 'should accept symbols for keys' do
      key = 'symboldestroy'
      Setting.create(key: key, value: 'destroy via symbol')
      Setting.destroy(:symboldestroy)
      expect(Setting.where(key: key).first).to be_nil
    end
  end

  describe '.assign_missing_with_defaults' do
    it 'should set setting values when no pre-existing settings for the keys' do
      Setting.assign_missing_with_defaults('abc' => '123', 'def' => '456')
      expect(Setting['abc']).to eq '123'
      expect(Setting['def']).to eq '456'
    end
    it 'should not overwrite existing values' do
      key = 'pre-existing'
      original_value = 'already exists'
      Setting.create(key: key, value: original_value)
      Setting.assign_missing_with_defaults(key => 'should not change')
      expect(Setting[key]).to eq original_value
    end
  end
end
