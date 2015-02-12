require 'spec_helper'
require 'tag'

describe Tag, type: :model do

  before(:all) do
    Event.delete_all
    User.delete_all
    @event = Event.new
  end

  describe "attribute mass assignment security" do
    it "should allow tag" do
      alt_text = 'Example Alt Text'
      expect( Tag.new(tag: 'test').tag ).to eq 'test'
    end
    it "should allow title" do
      title = 'Example Tag Title'
      expect( Tag.new(title: title).title ).to eq title
    end
    it "should allow is_meta" do
      expect( Tag.new(is_meta: true).is_meta ).to be_true
    end
    it "should not allow item" do
      item = Event.new
      expect { Tag.new(item: item) }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should not allow item_type" do
      expect { Tag.new(item_type: 'Event') }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should not allow item_id" do
      expect { Tag.new(item_id: 123) }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should not allow user" do
      user = User.new
      expect { Tag.new(user: user) }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should not allow user_id" do
      expect { Tag.new(user_id: 123) }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
  end

  describe "validations" do
    it "should validate with the minimum required values" do
      expect( Tag.new(tag: 'test').valid? ).to be_true
    end
    it "should validate given an item" do
      expect( @event.tags.build(tag: 'test').valid? ).to be_true
    end
    it "should fail without a tag" do
      expect( Tag.new.valid? ).to be_false
    end
    it "should fail with a tag with uppercase characters" do
      expect( Tag.new(tag: 'Test').valid? ).to be_false
    end
    it "should fail with a tag with uppercase characters" do
      expect( Tag.new(tag: 'Test').valid? ).to be_false
    end
    it "should fail with a tag with accented characters" do
      expect( Tag.new(tag: 'tést').valid? ).to be_false
    end
    it "should fail with a tag with white-space" do
      expect( Tag.new(tag: 'te st').valid? ).to be_false
    end
    it "should fail with a tag with punctuation" do
      expect( Tag.new(tag: 'test.').valid? ).to be_false
    end
    it "should pass with a blank title" do
      tag = Tag.new(title: '')
      tag.tag = 'test'
      expect( tag.valid? ).to be_true
    end
    it "should pass if title matches tag" do
      tag = Tag.new(title: 'Tést.')
      tag.tag = 'test'
      expect( tag.valid? ).to be_true
    end
    it "should fail if title doesn’t match the tag" do
      tag = Tag.new(title: 'no match')
      tag.tag = 'test'
      expect( tag.valid? ).to be_false
    end
  end

  describe '#title=' do
    context 'with a blank title' do
      it 'should leave tag alone' do
        tag = Tag.new(tag: 'leave')
        tag.title = ''
        expect( tag.tag ).to eq 'leave'
      end
      it 'should blank out the title' do
        tag = Tag.new
        tag.title = ''
        expect( tag.title ).to eq ''
      end
    end
    context 'with just white-space in the title' do
      it 'should leave tag alone' do
        tag = Tag.new(tag: 'old')
        tag.title = "\t \r\n"
        expect( tag.tag ).to eq 'old'
      end
      it 'should blank out the title' do
        tag = Tag.new
        tag.title = "\t \r\n"
        expect( tag.title ).to eq ''
      end
    end
    context 'with a usable title' do
      it 'should set the tag to a taggified version of the title' do
        tag = Tag.new(tag: 'old')
        tag.title = 'Tîtle 1!'
        expect( tag.tag ).to eq 'title1'
      end
      it 'should store the title' do
        tag = Tag.new
        tag.title = 'Title'
        expect( tag.read_attribute(:title) ).to eq 'Title'
      end
    end
  end

  describe '#taggify_text' do
    it "should convert to lower-case" do
      expect( Tag.new.taggify_text('AbCdEfG') ).to eq 'abcdefg'
    end
    it "should strip white-space" do
      expect( Tag.new.taggify_text("\ta bc def\t\r\n ghi\t ") ).to eq 'abcdefghi'
    end
    it "should strip punctuation" do
      expect( Tag.new.taggify_text('"z"y-x—w_vu’t.!?') ).to eq 'zyxwvut'
    end
    it "should transliterate accented characters" do
      expect( Tag.new.taggify_text('åéîøüÅÈÎØÜ') ).to eq 'aeiouaeiou'
    end
  end

end
