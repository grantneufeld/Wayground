require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the ApplicationHelper. For example:
#  describe ApplicationHelper do
#    describe "string concat" do
#      it "concats two strings with spaces" do
#        helper.concat_strings("this","that").should == "this that"
#      end
#    end
#  end
describe ApplicationHelper do
  describe "#show_errors" do
    it "displays errors (ActiveRecord-style) from an object" do
      item = User.new({:email => 'invalid'})
      item.valid?
      helper.show_errors(item).should match /[0-9]+ errors? prevented this User from being saved:/i
    end
  end

  ## Generate the pagination header, telling the user where they are in the pagination.
  ## item_plural: The pluralized name of the type of item (e.g., “documents”).
  #def show_pagination_header(item_plural = nil)
  #  render :partial => 'layouts/pagination_header', :locals => {:item_plural => item_plural}
  #end
  context "#show_pagination_header" do
    it "renders the pagination header partial" do
      @source_total = 42
      @selected_total = 10
      helper.show_pagination_header('tests').should match /Showing 10 of 42 tests\./
    end
  end

  ## Generate the pagination selector (links to numbered pages), if there is more than one page.
  #def show_pagination_selector
  #  render :partial => 'layouts/pagination_selector'
  #end
  context "#show_pagination_selector" do
    it "renders the pagination selector partial" do
      @max = 10
      @page = 3
      @offset = 20
      @default_max = 20
      @source_total = 42
      @selected_total = 10
      helper.show_pagination_selector.should match /<p class="pagination">Pages:\s*<a [^>]+>First<\/a>\s*<a [^>]+>1<\/a>\s*<a [^>]+>2<\/a>\s*<a [^>]+>3<\/a>\s*<a [^>]+>4<\/a>\s*<a [^>]+>5<\/a>\s*<a [^>]+>Last<\/a>\s*<\/p>/
    end
  end

  describe "#simple_text_to_html" do
    it "should wrap a simple string with no line breaks in a paragraph element" do
      str = "This is just a simple string."
      helper.simple_text_to_html(str).should eq "<p>#{str}</p>"
    end
    it "should convert html characters of an html string with no line breaks" do
      str = "<p>Html tags & stuff to encode.</p>"
      helper.simple_text_to_html(str).should eq "<p>&lt;p&gt;Html tags &amp; stuff to encode.&lt;/p&gt;</p>"
    end
    it "should strip leading and trailing whitespace" do
      str = "\r\n  Wrapped in whitespace.\r \r"
      helper.simple_text_to_html(str).should eq '<p>Wrapped in whitespace.</p>'
    end
    it "should convert single-line linebreaks to a single br element" do
      str = "\rThis\rhas\r\nsingle\nlines.\n"
      helper.simple_text_to_html(str).should eq "<p>This<br />has<br />single<br />lines.</p>"
    end
    it "should convert lines separated by multiple linebreaks to paragraph elements" do
      str = "This\r\r\r\rhas\r\n\r\nmultiple\n\n\nlines."
      helper.simple_text_to_html(str).should eq(
        "<p>This</p>\n<p>has</p>\n<p>multiple</p>\n<p>lines.</p>"
      )
    end
    it "should handle complicated strings" do
      str = "\r\n  <p>A complicated,\r\nstring.</p>\r\n\r\n& so on...  \r\n\r\n \r\n"
      helper.simple_text_to_html(str).should eq(
        "<p>&lt;p&gt;A complicated,<br />string.&lt;/p&gt;</p>\n<p>&amp; so on...</p>"
      )
    end
    it "should produce an html_safe string" do
      str = "Make this html_safe."
      helper.simple_text_to_html(str).html_safe?.should be_true
    end
  end

  describe "#simple_text_to_html_breaks" do
    it "should do nothing to a simple string with no line breaks" do
      str = "This is just a simple string."
      helper.simple_text_to_html_breaks(str).should eq str
    end
    it "should convert html characters of an html string with no line breaks" do
      str = "<p>Html tags & stuff to encode.</p>"
      helper.simple_text_to_html_breaks(str).should eq "&lt;p&gt;Html tags &amp; stuff to encode.&lt;/p&gt;"
    end
    it "should strip leading and trailing whitespace" do
      str = "\r\n  Wrapped in whitespace.\r \r"
      helper.simple_text_to_html_breaks(str).should eq 'Wrapped in whitespace.'
    end
    it "should convert multi-line linebreaks to a pair of br elements" do
      str = "\r\rThis\r\r\r\rhas\r\n\r\nmultiple\n\n\nlines.\r\n\r\n\r\n"
      helper.simple_text_to_html_breaks(str).should eq(
        "This<br /><br />has<br /><br />multiple<br /><br />lines."
      )
    end
    it "should convert single-line linebreaks to a single br element" do
      str = "\rThis\rhas\r\nsingle\nlines.\n"
      helper.simple_text_to_html_breaks(str).should eq "This<br />has<br />single<br />lines."
    end
    it "should produce an html_safe string" do
      str = "Make this html_safe."
      helper.simple_text_to_html_breaks(str).html_safe?.should be_true
    end
  end

end
