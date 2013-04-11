# encoding: utf-8
require 'spec_helper'
require 'http_url_validator'
require 'event'
require 'external_link' # a class that uses the validator

describe HttpUrlValidator do
  let(:url) { $url = 'http://url.tld/' }
  let(:event) { $event = Event.new }
  let(:item) { $item = event.external_links.new(url: url, title: 'A') }

  context "with an http url" do
    it "should be valid" do
      expect( item.valid? ).to be_true
    end
  end
  context "with an http url" do
    let(:url) { $url = 'https://url.tld/' }
    it "should be valid" do
      expect( item.valid? ).to be_true
    end
  end
  context "with an url with just a domain and no path" do
    let(:url) { $url = 'https://url.tld/' }
    it "should be valid" do
      expect( item.valid? ).to be_true
    end
  end
  context "with an url with a port, path, params and hash" do
    let(:url) { $url = 'https://url.tld:1234/a/path-with/file.ext?x=y&foo=bar#hash' }
    it "should be valid" do
      expect( item.valid? ).to be_true
    end
  end
  context "with an invalid url" do
    let(:url) { $url = 'invalid://url.tld/' }
    it "should return false" do
      expect( item.valid? ).to be_false
    end
    it "should report an error" do
      item.valid?
      expect( item.errors[:url].present? ).to be_true
    end
  end

end
