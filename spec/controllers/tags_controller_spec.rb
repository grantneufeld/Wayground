require 'rails_helper'
require 'tags_controller'
require 'tag'

describe TagsController, type: :controller do
  before(:all) do
    Tag.delete_all
    @item1 = Event.first || FactoryGirl.create(:event, title: 'First Item')
    @item2 = Event.second || FactoryGirl.create(:event, title: 'Second Item')
    @tag1 = Tag.new(title: 'First Tag')
    @tag1.item = @item1
    @tag1.save!
    @tag2 = Tag.new(title: 'Second Tag')
    @tag2.item = @item2
    @tag2.save!
  end

  describe 'GET "index"' do
    it 'assigns tags_with_counts as a hash keyed on the tag string with the count of that tag as the value' do
      get 'index'
      expect(assigns(:tags_with_counts)).to eq({ 'firsttag' => 1, 'secondtag' => 1 })
    end
  end

  describe 'GET "tag"' do
    it 'assigns tag as the requested Tag' do
      tag = Tag.new(tag: 'abc')
      allow(Tag).to receive(:where).with(tag: 'abc').and_return([tag])
      get 'tag', tag: 'abc'
      expect(assigns(:tag)).to eq(tag)
    end
  end

end
