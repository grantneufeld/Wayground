require 'spec_helper'
require 'url_cleaner'

describe UrlCleaner do

  describe ".clean" do
    it "should recognize Facebook urls" do
      UrlCleaner.clean(
        'http://www.facebook.com/events/123/declines/?test=1'
      ).should eq 'https://www.facebook.com/events/123/'
    end
    it "should recognize Facebook urls" do
      UrlCleaner.clean(
        'http://www.facebook.com/events/123/declines/?test=1'
      ).should eq 'https://www.facebook.com/events/123/'
    end
    it "should recognize Twitter urls" do
      UrlCleaner.clean(
        'http://twitter.com/#!/wayground'
      ).should eq 'https://twitter.com/wayground'
    end
    it "should pass through other urls" do
      UrlCleaner.clean(
        'http://user@wayground.ca:80/path/?q=1'
      ).should eq 'http://user@wayground.ca:80/path/?q=1'
    end
    it "should pass through black strings" do
      UrlCleaner.clean('').should eq ''
    end
    it "should pass through nils" do
      UrlCleaner.clean(nil).should eq nil
    end
  end

  describe ".clean_facebook" do
    it "should change http to https" do
      UrlCleaner.clean_facebook(
        {protocol: 'http', delimiter: '://', domain: 'facebook.com', path: '/'}
      ).should eq 'https://facebook.com/'
    end
    it "should tighten up event urls" do
      UrlCleaner.clean_facebook({
        protocol: 'http', delimiter: '://', domain: 'facebook.com',
        path: '/events/123/declines/', params: '?ignore=this'
      }).should eq 'https://facebook.com/events/123/'
    end
    it "should pass through weird urls" do
      UrlCleaner.clean_facebook({
        protocol: 'webcal', delimiter: '://', domain: 'facebook.com',
        path: '/something/weird/', params: '?with=params'
      }).should eq 'webcal://facebook.com/something/weird/?with=params'
    end
  end

  describe ".clean_twitter" do
    it "should change http to https" do
      UrlCleaner.clean_twitter(
        {protocol: 'http', delimiter: '://', domain: 'twitter.com', path: '/'}
      ).should eq 'https://twitter.com/'
    end
    it "should remove the hashbang" do
      UrlCleaner.clean_twitter(
        {protocol: 'https', delimiter: '://', domain: 'twitter.com', path: '/#!/wayground'}
      ).should eq 'https://twitter.com/wayground'
    end
  end

end
