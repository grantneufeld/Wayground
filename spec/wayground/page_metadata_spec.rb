require 'spec_helper'
require 'page_metadata'

describe Wayground::PageMetadata do
  describe '#initialize' do
    # :title, :description, :nocache
    it 'should accept a title param' do
      expect(Wayground::PageMetadata.new(title: 'Title').title).to eq 'Title'
    end
    it 'should accept a description param' do
      expect(Wayground::PageMetadata.new(description: 'Description.').description).to eq 'Description.'
    end
    it 'should accept a nocache param' do
      expect(Wayground::PageMetadata.new(nocache: true).nocache).to be_truthy
    end
    context 'with no params' do
      it 'should default to nocache being false' do
        expect(Wayground::PageMetadata.new.nocache).to be_falsey
      end
    end
  end

  describe '#merge_params' do
    it 'should accept a title param' do
      meta = Wayground::PageMetadata.new
      meta.merge_params(title: 'Title')
      expect(meta.title).to eq 'Title'
    end
    it 'should accept a description param' do
      meta = Wayground::PageMetadata.new
      meta.merge_params(description: 'Description.')
      expect(meta.description).to eq 'Description.'
    end
    it 'should accept a nocache param' do
      meta = Wayground::PageMetadata.new
      meta.merge_params(nocache: true)
      expect(meta.nocache).to be_truthy
    end
    context 'with no params' do
      before(:all) do
        @meta = Wayground::PageMetadata.new(title: 'A', description: 'B', nocache: true)
        @meta.merge_params({})
      end
      it 'should not change title' do
        expect(@meta.title).to eq 'A'
      end
      it 'should not change description' do
        expect(@meta.description).to eq 'B'
      end
      it 'should not change nocache' do
        expect(@meta.nocache).to be_truthy
      end
    end
  end
end
