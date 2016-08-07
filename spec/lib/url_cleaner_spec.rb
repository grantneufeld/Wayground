require 'rails_helper'
require 'url_cleaner'

describe UrlCleaner do

  describe ".clean" do
    it "should recognize Facebook urls" do
      cleaned_url = UrlCleaner.clean('http://www.facebook.com/events/123/declines/?test=1')
      expect(cleaned_url).to eq 'https://www.facebook.com/events/123/'
    end
    it "should recognize Twitter urls" do
      cleaned_url = UrlCleaner.clean('http://twitter.com/#!/wayground')
      expect(cleaned_url).to eq 'https://twitter.com/wayground'
    end
    it "should pass through other urls" do
      cleaned_url = UrlCleaner.clean('http://user@wayground.ca:80/path/?q=1')
      expect(cleaned_url).to eq 'http://user@wayground.ca:80/path/?q=1'
    end
    it "should pass through blank strings" do
      expect(UrlCleaner.clean('')).to eq ''
    end
    it "should pass through nils" do
      expect(UrlCleaner.clean(nil)).to eq nil
    end
  end

  describe ".clean_facebook" do
    it "should change http to https" do
      cleaned_url = UrlCleaner.clean_facebook(
        protocol: 'http', delimiter: '://', domain: 'facebook.com', path: '/'
      )
      expect(cleaned_url).to eq 'https://facebook.com/'
    end
    it "should tighten up event urls" do
      cleaned_url = UrlCleaner.clean_facebook(
        protocol: 'http', delimiter: '://', domain: 'facebook.com',
        path: '/events/123/declines/', params: '?ignore=this'
      )
      expect(cleaned_url).to eq 'https://facebook.com/events/123/'
    end
    it "should pass through weird urls" do
      cleaned_url = UrlCleaner.clean_facebook(
        protocol: 'webcal', delimiter: '://', domain: 'facebook.com',
        path: '/something/weird/', params: '?with=params'
      )
      expect(cleaned_url).to eq 'webcal://facebook.com/something/weird/?with=params'
    end
  end

  describe ".clean_twitter" do
    it "should change http to https" do
      cleaned_url = UrlCleaner.clean_twitter(
        protocol: 'http', delimiter: '://', domain: 'twitter.com', path: '/'
      )
      expect(cleaned_url).to eq 'https://twitter.com/'
    end
    it "should remove the hashbang" do
      cleaned_url = UrlCleaner.clean_twitter(
        protocol: 'https', delimiter: '://', domain: 'twitter.com', path: '/#!/wayground'
      )
      expect(cleaned_url).to eq 'https://twitter.com/wayground'
    end
  end

end
