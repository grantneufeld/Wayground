require 'spec_helper'

describe Setting, type: :model do

  describe "acts_as_authority_controlled" do
    it "should be in the “Admin” area" do
      Setting.authority_area.should eq 'Admin'
    end
  end

  describe "validation" do
    describe "of key" do
      it "should require key to be set" do
        Setting.new(:key => 'set').valid?.should be_true
      end
      it "should fail if key is not set" do
        Setting.new.valid?.should be_false
      end
    end
  end

  describe ".[]" do
    it "should return the value of the setting with the specified key" do
      key = 'indexed lookup'
      val = 'from index'
      Setting.create(:key => key, :value => val)
      Setting[key].should eq val
    end
    it "should return nil if there is no setting matching the key" do
      Setting['non-existant'].should be_nil
    end
    it "should accept symbols for keys" do
      value = 'value for symbol'
      Setting.create(:key => 'symbolickey', :value => value)
      Setting[:symbolickey].should eq value
    end
  end

  describe ".[]=" do
    it "should set the value of the setting for the key" do
      key = 'exists to be changed'
      new_val = 'has been changed'
      Setting.create(:key => key, :value => 'original')
      Setting[key] = new_val
      Setting[key].should eq new_val
    end
    it "should create a setting for the key if one doesn’t exist" do
      key = 'not already existing'
      new_val = 'created with new value'
      Setting[key] = new_val
      Setting[key].should eq new_val
    end
    it "should accept symbols for keys" do
      value = 'assigned for symbol'
      Setting[:assignbysymbol] = value
      Setting['assignbysymbol'].should eq value
    end
  end

  describe ".destroy" do
    it "should destroy the setting for the key" do
      key = 'destroy this'
      Setting.create(:key => key, :value => 'to be removed')
      Setting.destroy(key)
      expect( Setting.where(key: key).first ).to be_nil
    end
    it "should do nothing if there is no setting for the key" do
      key = 'no setting for key'
      Setting.destroy(key)
      expect( Setting.where(key: key).first ).to be_nil
    end
    it "should accept symbols for keys" do
      key = 'symboldestroy'
      Setting.create(:key => key, :value => 'destroy via symbol')
      Setting.destroy(:symboldestroy)
      expect( Setting.where(key: key).first ).to be_nil
    end
  end

  describe ".set_defaults" do
    it "should set setting values when no pre-existing settings for the keys" do
      Setting.set_defaults({'abc'=>'123', 'def'=>'456'})
      Setting['abc'].should eq '123'
      Setting['def'].should eq '456'
    end
    it "should not overwrite existing values" do
      key = 'pre-existing'
      original_value = 'already exists'
      Setting.create(:key => key, :value => original_value)
      Setting.set_defaults({key=>'should not change'})
      Setting[key].should eq original_value
    end
  end
end
