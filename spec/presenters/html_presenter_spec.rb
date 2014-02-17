require 'spec_helper'
require 'html_presenter'

describe HtmlPresenter do
  let(:presenter) { $presenter = HtmlPresenter.new }

  describe "#html_tag_with_newline" do
    it "should work with attributes" do
      expect( presenter.html_tag_with_newline(:test, a: 'eh', b: %w(bee be)) ).to eq(
        "<test a=\"eh\" b=\"bee be\" />\n"
      )
    end
    it "should work with no block" do
      expect( presenter.html_tag_with_newline(:test) ).to eq "<test />\n"
    end
    it "should work with a block" do
      expect( presenter.html_tag_with_newline(:test) { 'X'.html_safe } ).to eq "<test>X</test>\n"
    end
    it "should end with a newline" do
      expect( presenter.html_tag_with_newline(:end) ).to match /\n\z/
    end
    it "should be html safe" do
      expect( presenter.html_tag_with_newline(:test).html_safe? ).to be_true
    end
  end

  describe "#html_tag" do
    context "with no block" do
      it "should work with no attributes" do
        expect( presenter.html_tag('test') ).to eq '<test />'
      end
      it "should handle attributes" do
        expect( presenter.html_tag('with-attrs', foo: 'bar', x: 'y') ).to eq '<with-attrs foo="bar" x="y" />'
      end
      it "should ignore blank attributes" do
        expect( presenter.html_tag('blank-attrs', ignore: nil, blank: '') ).to eq '<blank-attrs />'
      end
      it "should handle array attributes" do
        expect( presenter.html_tag('array', array: [1,2,3]) ).to eq '<array array="1 2 3" />'
      end
      it "should ignore blank array attributes" do
        expect( presenter.html_tag('empty-array', array: [nil,'']) ).to eq '<empty-array />'
      end
    end
    context "with a content block" do
      it "should work with no attributes" do
        expect( presenter.html_tag('no-attr') { 'no attributes' } ).to eq '<no-attr>no attributes</no-attr>'
      end
      it "should handle attributes" do
        expect( presenter.html_tag('attr', x: 'y') { 'let x = y' } ).to eq '<attr x="y">let x = y</attr>'
      end
      it "should handle nested calls" do
        expect(
          presenter.html_tag('nest') do
            presenter.html_tag('sub') do
              presenter.html_tag('note') + 'Note: ' + presenter.html_tag('deep') { 'this goes deep!'}
            end
          end
        ).to eq '<nest><sub><note />Note: <deep>this goes deep!</deep></sub></nest>'
      end
    end
  end

  describe "#anchor_or_span_tag" do
    context "with an url" do
      it "should return an anchor tag" do
        result = presenter.anchor_or_span_tag('http://abc.tld/') { 'test' }
        expect( result ).to eq '<a href="http://abc.tld/">test</a>'
      end
    end
    context "with an url and attrs" do
      it "should return an anchor tag with the attrs" do
        result = presenter.anchor_or_span_tag('http://abc.tld/', foo: 'bar') { 'test' }
        expect( result ).to eq '<a foo="bar" href="http://abc.tld/">test</a>'
      end
    end
    context "with attrs but without an url" do
      it "should return a span tag with the attrs" do
        result = presenter.anchor_or_span_tag(nil, foo: 'bar') { 'test' }
        expect( result ).to eq '<span foo="bar">test</span>'
      end
    end
    context "without an url or attrs" do
      it "should return a span tag with the attrs" do
        result = presenter.anchor_or_span_tag(nil) { 'test' }
        expect( result ).to eq '<span>test</span>'
      end
    end
  end

  describe "#html_escape" do
    context "with an html safe string" do
      let(:string) { $string = "<test foo=\"bar\" />\r\nThis &amp; that's “what”.</test>".html_safe }
      it "should just return the string, unaltered" do
        expect( presenter.html_escape(string) ).to eq string
      end
      it "should be html safe" do
        expect( presenter.html_escape(string).html_safe? ).to be_true
      end
    end
    context "with a string with a bunch of html characters" do
      let(:string) { $string = "&<>\"'" }
      it "should html encode the characters" do
        expect( presenter.html_escape(string) ).to eq "&amp;&lt;&gt;&quot;&#x27;"
      end
      it "should be html safe" do
        expect( presenter.html_escape(string).html_safe? ).to be_true
      end
    end
  end

  describe "#html_blank" do
    it "should retun an empty string" do
      expect( presenter.html_blank ).to eq ''
    end
    it "should be html safe" do
      expect( presenter.html_blank.html_safe? ).to be_true
    end
  end

  describe "#newline" do
    it "should retun a carriage return and linefeed" do
      expect( presenter.newline ).to eq "\n"
    end
    it "should be html safe" do
      expect( presenter.newline.html_safe? ).to be_true
    end
  end

  describe '#url_for_print' do
    context 'with an http url' do
      it 'should strip the “http://” part' do
        expect( presenter.url_for_print('http://test.url/etc') ).to eq 'test.url/etc'
      end
    end
    context 'with an https url' do
      it 'should strip the “http://” part' do
        expect( presenter.url_for_print('https://ssl.test.url/secure') ).to eq 'ssl.test.url/secure'
      end
    end
    context 'with a trailing slash' do
      it 'should strip the trailing slash' do
        expect( presenter.url_for_print('http://slash.url/') ).to eq 'slash.url'
      end
      it 'should strip the trailing slash after multiple path parts' do
        expect( presenter.url_for_print('http://multi.url/some/stuff/') ).to eq 'multi.url/some/stuff'
      end
    end
  end

end
