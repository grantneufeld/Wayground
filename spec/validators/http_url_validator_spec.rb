# encoding: utf-8
require 'spec_helper'
require 'http_url_validator'

class SpecClassWithHttpUrl
  include ActiveModel::Validations
  attr_accessor :url
  validates :url, http_url: true
  def initialize(params={})
    self.url = params[:url]
  end
end

describe HttpUrlValidator do
  let(:url) { $url = 'http://url.tld/' }
  let(:item) { $item = SpecClassWithHttpUrl.new(url: url) }

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
  context 'with an url with a bunch of weird, but allowed, characters' do
    let(:url) { $url = 'https://url.tld/AZaz09+:.-/%26~_@?=&#' }
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
