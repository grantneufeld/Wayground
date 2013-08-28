# encoding: utf-8
require 'spec_helper'
require 'level'

describe Level do

  describe "acts_as_authority_controlled" do
    it "should be in the “Democracy” area" do
      Level.authority_area.should eq 'Democracy'
    end
  end

  describe "attribute mass assignment security" do
    it "should allow filename" do
      filename = 'example-filename'
      expect( Level.new(filename: filename).filename ).to eq filename
    end
    it "should allow name" do
      name = 'Example Name'
      expect( Level.new(name: name).name ).to eq name
    end
    it "should allow url" do
      url = 'http://example.url/'
      expect( Level.new(url: url).url ).to eq url
    end
    it "should not allow parent" do
      expect {
        Level.new(parent: Level.new)
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
    it "should not allow parent_id" do
      expect {
        Level.new(parent_id: 1)
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe '#parent' do
    it 'should allow a parent level to be set' do
      parent = Level.new
      level = Level.new
      level.parent = parent
      expect( level.parent ).to eq parent
    end
  end

  describe '#children' do
    it 'should access levels that have this level as a parent' do
      level = FactoryGirl.create(:level)
      child1 = FactoryGirl.create(:level, parent: level)
      child2 = FactoryGirl.create(:level, parent: level)
      expect( level.children ).to eq [child1, child2]
    end
  end

  describe "validations" do
    let(:required) { $required = {filename: 'required', name: 'Required'} }
    it "should validate with all required values" do
      expect( Level.new(required).valid? ).to be_true
    end
    describe "of filename" do
      let(:required) { $required = {name: 'Required'} }
      it "should fail if filename is blank" do
        expect( Level.new(required.merge(filename: '')).valid? ).to be_false
      end
      it "should fail if filename is nil" do
        expect( Level.new(required).valid? ).to be_false
      end
      it 'should fail if filename is a duplicate' do
        FactoryGirl.create(:level, filename: 'duplicate')
        expect( Level.new(required.merge(filename: 'duplicate')).valid? ).to be_false
      end
      it 'should fail if filename contains invalid characters' do
        expect( Level.new(required.merge(filename: 'Has invalid characters!')).valid? ).to be_false
      end
    end
    describe "of name" do
      let(:required) { $required = {filename: 'required'} }
      it "should fail if name is blank" do
        expect( Level.new(required.merge(name: '')).valid? ).to be_false
      end
      it "should fail if name is nil" do
        expect( Level.new(required).valid? ).to be_false
      end
    end
    describe "of url" do
      it "should fail if url is not an url string" do
        expect( Level.new(required.merge(url: 'not an url')).valid? ).to be_false
      end
      it "should pass if the url is a valid url" do
        expect( Level.new(required.merge(url: 'https://valid.url:8080/should/pass')).valid? ).to be_true
      end
    end
  end

  describe 'scopes' do
    describe '.from_param' do
      before(:all) do
        @level = Level.where(filename: 'the_param').first || FactoryGirl.create(:level, filename: 'the_param')
      end
      it 'should return the level that matches the param' do
        expect( Level.from_param('the_param') ).to eq [@level]
      end
      it 'should return an empty list for a non-existent param' do
        expect( Level.from_param('non-existent-param') ).to eq []
      end
    end
  end

  describe '#parent_chain' do
    context 'with no parent' do
      it 'should return an empty array' do
        expect( Level.new().parent_chain ).to eq []
      end
    end
    context 'with one parent' do
      it 'should return an array with the parent' do
        parent = Level.new
        level = Level.new
        level.parent = parent
        expect( level.parent_chain ).to eq [parent]
      end
    end
    context 'with multiple parents' do
      it 'should return an array with the parents' do
        great_grandparent = Level.new
        grandparent = Level.new
        grandparent.parent = great_grandparent
        parent = Level.new
        parent.parent = grandparent
        level = Level.new
        level.parent = parent
        expect( level.parent_chain ).to eq [great_grandparent, grandparent, parent]
      end
    end
  end

  describe '#to_param' do
    it 'should return the filename' do
      expect( Level.new(filename: 'param').to_param ).to eq 'param'
    end
  end

  describe '#items_for_path' do
    it 'should return an array of just the level' do
      level = Level.new
      expect( level.items_for_path ).to eq [level]
    end
  end

end
