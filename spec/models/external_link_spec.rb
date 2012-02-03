# encoding: utf-8
require 'spec_helper'

describe ExternalLink do
  describe "acts_as_authority_controlled" do
    it "should be in the “Content” area" do
      ExternalLink.authority_area.should eq 'Content'
    end
  end

  describe "attr_accessible" do
    it "should allow title to be set" do
      elink = ExternalLink.new(:title => 'set title')
      elink.title.should eq 'set title'
    end
    it "should allow url to be set" do
      elink = ExternalLink.new(:url => 'set url')
      elink.url.should eq 'set url'
    end
    it "should not allow position to be set" do
      elink = ExternalLink.new(:position => 123)
      elink.position.should be_nil
    end
    it "should not allow item to be set" do
      item = Factory.build(:page)
      elink = ExternalLink.new(:item => item)
      elink.item.should be_nil
    end
    it "should not allow item_type to be set" do
      elink = ExternalLink.new(:item_type => 'Page')
      elink.item_type.should be_nil
    end
    it "should not allow item_id to be set" do
      elink = ExternalLink.new(:item_id => 1)
      elink.item_id.should be_nil
    end
    it "should not allow site to be set" do
      elink = ExternalLink.new(:site => 'somesite')
      elink.site.should be_nil
    end
  end

  describe "validation" do
    before(:all) do
      @item = Factory.create(:page)
    end
    it "should pass if all required values are set" do
      elink = ExternalLink.new(:title => 'A', :url => 'http://validation.test/all/required/values')
      elink.position = 1
      elink.valid?.should be_true
    end
    describe "of item" do
      it "should fail if Item is not set on update" do
        elink = ExternalLink.new(:title => 'A', :url => 'http://item.test/not.set')
        elink.item = @item
        elink.save!
        elink.item = nil
        elink.valid?.should be_false
      end
    end
    describe "of title" do
      it "should set the title from the url if title is not set" do
        elink = ExternalLink.new(:url => 'http://nil.title.test/no-title')
        elink.valid?.should be_true
        elink.title.should eq 'nil.title.test'
      end
      it "should set the title from the url if title is blank" do
        elink = ExternalLink.new(:title => '', :url => 'http://blank.title.test/blank_title')
        elink.valid?.should be_true
        elink.title.should eq 'blank.title.test'
      end
      it "should fail if title is too long" do
        elink = ExternalLink.new(:title => ('A' * 256), :url => 'http://long.title.test/too/long#title')
        elink.valid?.should be_false
      end
    end
    describe "of url" do
      it "should fail if url is not set" do
        elink = ExternalLink.new(:title => 'A')
        elink.valid?.should be_false
      end
      it "should fail if url is blank" do
        elink = ExternalLink.new(:title => 'A', :url => '')
        elink.valid?.should be_false
      end
      it "should fail if url is not an url string" do
        elink = ExternalLink.new(:title => 'A', :url => 'not actually an url')
        elink.valid?.should be_false
      end
      it "should fail if url is too long" do
        elink = ExternalLink.new(:title => 'A', :url => 'http://url.test/' + ('c' * 1008)) # 1024 - 'http://url.test/'.size
        elink.valid?.should be_false
      end
    end
    describe "of position" do
      it "should fail if value is negative" do
        elink = ExternalLink.new(:title => 'A', :url => 'http://position.test/-negative')
        elink.position = -2
        elink.valid?.should be_false
      end
      it "should fail if value is zero" do
        elink = ExternalLink.new(:title => 'A', :url => 'http://position.test/0/value')
        elink.position = 0
        elink.valid?.should be_false
      end
      it "should fail if value is not an integer" do
        elink = ExternalLink.new(:title => 'A', :url => 'http://position.test/not_an_integer')
        elink.position = 3.14
        elink.valid?.should be_false
      end
    end
  end

  describe "#set_default_position" do
    before(:each) do
      @item = Factory.create(:page)
    end
    it "should set position to 1 if no other ExternalLinks are on the item" do
      @elink = ExternalLink.new
      @elink.item = @item
      @elink.set_default_position
      @elink.position.should eq 1
    end
    it "should set position to come after all other ExternalLinks on the item" do
      @elink = Factory.create(:external_link, :item => @item, :position => 36)
      @elink = Factory.create(:external_link, :item => @item, :position => 72)
      @elink = Factory.create(:external_link, :item => @item, :position => 45)
      @elink = ExternalLink.new
      @elink.item = @item
      @elink.set_default_position
      @elink.position.should eq 73
    end
    it "should automatically assign the position when creating an ExternalLink" do
      @elink = ExternalLink.new(:title => 'New', :url => 'http://new.position.test/')
      @elink.item = @item
      @elink.save!
      @elink.position.should eq 1
    end
    it "should not overwrite an existing position" do
      @elink = ExternalLink.new
      @elink.item = @item
      @elink.position = 123
      @elink.set_default_position
      @elink.position.should eq 123
    end
  end

  describe "#to_html" do
    before(:all) do
      @elink = ExternalLink.new(:title => 'ELink', :url => 'http://elink.tld/')
    end
    it "should generate an html anchor element" do
      @elink.to_html.should eq '<a href="http://elink.tld/">ELink</a>'
    end
    it "should include the id attribute when passed in" do
      @elink.to_html(:id => 'elink').should eq '<a href="http://elink.tld/" id="elink">ELink</a>'
    end
    it "should include the class attribute when passed in" do
      @elink.to_html(:class => 'e_link').should eq '<a href="http://elink.tld/" class="e_link">ELink</a>'
    end
    it "should include the class attribute when the ExternalLink#site is set" do
      @elink.site = 'elink'
      @elink.to_html.should eq '<a href="http://elink.tld/" class="elink">ELink</a>'
      @elink.site = nil
    end
    it "should include the class attribute, merged with the ExternalLink#site, when passed in" do
      @elink.site = 'site'
      @elink.to_html(:class => 'e_link').should eq '<a href="http://elink.tld/" class="e_link site">ELink</a>'
      @elink.site = nil
    end
    it "should include both the class and id attributes when passed in" do
      @elink.to_html(:id => 'a1', :class => 'test').should eq(
        '<a href="http://elink.tld/" id="a1" class="test">ELink</a>'
      )
    end
  end
end
