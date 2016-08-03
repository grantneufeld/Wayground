require 'rails_helper'

describe ExternalLink, type: :model do
  before(:all) do
    @item = FactoryGirl.create(:page)
  end

  describe "acts_as_authority_controlled" do
    it "should be in the “Content” area" do
      expect(ExternalLink.authority_area).to eq 'Content'
    end
  end

  describe "validation" do
    it "should pass if all required values are set" do
      elink = ExternalLink.new(:title => 'A', :url => 'http://validation.test/all/required/values')
      elink.position = 1
      expect(elink.valid?).to be_truthy
    end
    describe "of item" do
      it "should fail if Item is not set on update" do
        elink = ExternalLink.new(:title => 'A', :url => 'http://item.test/not.set')
        elink.item = @item
        elink.save!
        elink.item = nil
        expect(elink.valid?).to be_falsey
      end
    end
    describe "of title" do
      it "should set the title from the url if title is not set" do
        elink = ExternalLink.new(:url => 'http://nil.title.test/no-title')
        expect(elink.valid?).to be_truthy
        expect(elink.title).to eq 'nil.title.test'
      end
      it "should set the title from the url if title is blank" do
        elink = ExternalLink.new(:title => '', :url => 'http://blank.title.test/blank_title')
        expect(elink.valid?).to be_truthy
        expect(elink.title).to eq 'blank.title.test'
      end
      it "should fail if title is too long" do
        elink = ExternalLink.new(:title => ('A' * 256), :url => 'http://long.title.test/too/long#title')
        expect(elink.valid?).to be_falsey
      end
    end
    describe "of url" do
      it "should fail if url is not set" do
        elink = ExternalLink.new(:title => 'A')
        expect(elink.valid?).to be_falsey
      end
      it "should fail if url is blank" do
        elink = ExternalLink.new(:title => 'A', :url => '')
        expect(elink.valid?).to be_falsey
      end
      it "should fail if url is not an url string" do
        elink = ExternalLink.new(:title => 'A', :url => 'not actually an url')
        expect(elink.valid?).to be_falsey
      end
      it "should fail if url is too long" do
        elink = ExternalLink.new(title: 'A', url: 'http://url.test/' + ('c' * 1008))
        # (1008 == 1024 - 'http://url.test/'.size)
        expect(elink.valid?).to be_falsey
      end
    end
    describe "of position" do
      it "should fail if value is negative" do
        elink = ExternalLink.new(:title => 'A', :url => 'http://position.test/-negative')
        elink.position = -2
        expect(elink.valid?).to be_falsey
      end
      it "should fail if value is zero" do
        elink = ExternalLink.new(:title => 'A', :url => 'http://position.test/0/value')
        elink.position = 0
        expect(elink.valid?).to be_falsey
      end
      it "should fail if value is not an integer" do
        elink = ExternalLink.new(:title => 'A', :url => 'http://position.test/not_an_integer')
        elink.position = 3.14
        expect(elink.valid?).to be_falsey
      end
    end
  end

  describe "#set_default_position" do
    it "should set position to 1 if no other ExternalLinks are on the item" do
      external_links = double('external links on item')
      allow(external_links).to receive(:order).and_return(external_links)
      allow(external_links).to receive(:first).and_return(nil)
      allow(@item).to receive(:external_links).and_return(external_links)
      elink = ExternalLink.new
      elink.item = @item
      elink.set_default_position
      expect(elink.position).to eq 1
    end
    it "should set position to come after all other ExternalLinks on the item" do
      mock_link = double('external link')
      allow(mock_link).to receive(:position).and_return(72)
      external_links = double('external links on item')
      allow(external_links).to receive(:order).and_return(external_links)
      allow(external_links).to receive(:first).and_return(mock_link)
      allow(@item).to receive(:external_links).and_return(external_links)
      elink = ExternalLink.new
      elink.item = @item
      elink.set_default_position
      expect(elink.position).to eq 73
    end
    it "should automatically assign the position when creating an ExternalLink" do
      elink = ExternalLink.new(:title => 'New', :url => 'http://new.position.test/')
      elink.item = @item
      elink.save!
      expect(elink.position).to eq 1
    end
    it "should not overwrite position if already set" do
      elink = ExternalLink.new
      elink.item = @item
      elink.position = 123
      elink.set_default_position
      expect(elink.position).to eq 123
    end
  end

  describe "#set_title" do
    it "shoud do nothing when title is already set" do
      elink = ExternalLink.new(:url => 'http://test.tld/', :title => 'Already Set')
      elink.set_title
      expect(elink.title).to eq 'Already Set'
    end
    it "should default to using the domain name from the url" do
      elink = ExternalLink.new(:url => 'http://test.tld/')
      elink.set_title
      expect(elink.title).to eq 'test.tld'
    end
    it "should special-case Facebook event urls" do
      elink = ExternalLink.new(:url => 'http://www.facebook.com/events/1234/')
      elink.set_title
      expect(elink.title).to eq 'Facebook event'
    end
    it "should special-case Eventbrite urls" do
      elink = ExternalLink.new(:url => 'http://test.eventbrite.com/')
      elink.set_title
      expect(elink.title).to eq 'Event Registration (Eventbrite)'
    end
    it "should special-case Meetup event urls" do
      elink = ExternalLink.new(:url => 'http://www.meetup.com/group/events/1234/')
      elink.set_title
      expect(elink.title).to eq 'Meetup event'
    end
    it "should be called before validation" do
      elink = ExternalLink.new(:url => 'http://test.tld/')
      elink.valid?
      expect(elink.title).to eq 'test.tld'
    end
  end

  describe '#set_site' do
    context 'with the site already set' do
      it 'should leave the site as is' do
        elink = ExternalLink.new(url: 'http://test.tld/')
        elink.site = 'already.set'
        elink.set_site
        expect( elink.site ).to eq 'already.set'
      end
    end
    context 'with no url' do
      it 'should leave the site blank' do
        elink = ExternalLink.new
        elink.set_site
        expect( elink.site ).to be_nil
      end
    end
    context 'with an url with no domain' do
      it 'should leave the site blank' do
        elink = ExternalLink.new(url: '/no/domain')
        elink.set_site
        expect( elink.site ).to be_nil
      end
    end
    context 'with a facebook url' do
      it 'should set the site to “facebook”' do
        elink = ExternalLink.new(url: 'https://www.facebook.com/something')
        elink.set_site
        expect( elink.site ).to eq 'facebook'
      end
    end
    context 'with a youtube url' do
      it 'should set the site to “youtube”' do
        elink = ExternalLink.new(url: 'http://www.youtube.com/something')
        elink.set_site
        expect( elink.site ).to eq 'youtube'
      end
    end
    context 'with a google plus url' do
      it 'should set the site to “google”' do
        elink = ExternalLink.new(url: 'https://plus.google.com/1234567890/about')
        elink.set_site
        expect( elink.site ).to eq 'google'
      end
    end
  end

  describe "#url=" do
    it "should set the url attribute" do
      elink = ExternalLink.new
      elink.url = 'test'
      expect(elink.url).to eq 'test'
    end
    it "should clear the url attribute when nil is given" do
      elink = ExternalLink.new(url: 'http://wayground.ca/')
      elink.url = nil
      expect(elink.url).to be_nil
    end
    it "should try to clean up urls" do
      elink = ExternalLink.new
      elink.url = 'http://twitter.com/#!/wayground'
      expect(elink.url).to eq 'https://twitter.com/wayground'
    end
  end

  describe "#to_html" do
    before(:all) do
      @elink = ExternalLink.new(:title => 'ELink', :url => 'http://elink.tld/')
    end
    it "should generate an html anchor element" do
      expect(@elink.to_html).to eq '<a href="http://elink.tld/">ELink</a>'
    end
    it "should include the id attribute when passed in" do
      expect(@elink.to_html(:id => 'elink')).to eq '<a href="http://elink.tld/" id="elink">ELink</a>'
    end
    it "should include the class attribute when passed in" do
      expect(@elink.to_html(:class => 'e_link')).to eq '<a href="http://elink.tld/" class="e_link">ELink</a>'
    end
    it "should include the class attribute when the ExternalLink#site is set" do
      @elink.site = 'elink'
      expect(@elink.to_html).to eq '<a href="http://elink.tld/" class="elink">ELink</a>'
      @elink.site = nil
    end
    it "should include the class attribute, merged with the ExternalLink#site, when passed in" do
      @elink.site = 'site'
      expect(@elink.to_html(:class => 'e_link')).to eq '<a href="http://elink.tld/" class="e_link site">ELink</a>'
      @elink.site = nil
    end
    it "should include both the class and id attributes when passed in" do
      expect(@elink.to_html(:id => 'a1', :class => 'test')).to eq(
        '<a href="http://elink.tld/" id="a1" class="test">ELink</a>'
      )
    end
  end

  describe '#domain' do
    context 'with no url' do
      it 'should return nil' do
        link = ExternalLink.new
        expect( link.domain ).to be_nil
      end
    end
    context 'with an url' do
      it 'should return just the domain' do
        link = ExternalLink.new(url: 'https://an.url.with.lots.of.stuff:80/etc/etc.html')
        expect( link.domain ).to eq 'an.url.with.lots.of.stuff'
      end
    end
  end

  describe '#descriptor' do
    it 'should return the title' do
      link = ExternalLink.new(title: 'Test Link')
      expect( link.descriptor ).to eq 'Test Link'
    end
  end

  describe '#items_for_path' do
    context 'with an event as item' do
      it 'should return an array of the event and external_link' do
        event = Event.new
        external_link = event.external_links.build
        external_link.item = event
        expect( external_link.items_for_path ).to eq [event, external_link]
      end
    end
  end

end
