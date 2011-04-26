# encoding: utf-8
require 'spec_helper'

describe "layouts/application.html.erb" do
  before do
    controller.singleton_class.class_eval do
      protected
      def current_user
        nil
      end
      helper_method :current_user
    end
  end

  # Parameters

  # @page_title: Used in the <title> meta tag. If blank, defaults to the site title.
  describe "@page_title" do
    it "should be used for the title element if present" do
      @page_title = 'Test Title'
      render
      rendered.should match(/<title>#{@page_title} — Wayground<\/title>/)
    end
    it "should default to the site title if blank" do
      @page_title = nil
      render
      rendered.should match(/<title>Wayground<\/title>/)
    end
  end

  # @page_uses_javascript: A boolean that determines whether to load the default javascript files.
  describe "@page_uses_javascript" do
    it "should include the script link(s) in the head if true" do
      @page_uses_javascript = true
      render
      rendered.should match(/<script[^>]/)
    end
    it "should not include script links in the head if not set" do
      @page_uses_javascript = nil
      render
      rendered.should_not match(/<script[^>]/)
    end
  end

  # @rich_text_editor: A boolean that determines whether to load the support files for displaying a rich text editor (CKEditor).
  describe "@rich_text_editor" do
    it "should include the ckeditor script if true" do
      @rich_text_editor = true
      render
      rendered.should match(/<script[^>]src="\/ckeditor\/ckeditor\.js/)
    end
    it "should not include the ckeditor script if not set" do
      @rich_text_editor = nil
      render
      rendered.should_not match(/<script[^>]src="\/ckeditor\/ckeditor\.js/)
    end
  end

  # @browser_nocache: A boolean that instructs browsers and search engines not to cache the content of this page.
  describe "@browser_nocache" do
    it "should include the robots-noindex meta tag if true" do
      @browser_nocache = true
      render
      rendered.should match(/<meta name="robots" content="noindex"/)
    end
    it "should not include the robots-noindex meta tag if not set" do
      @browser_nocache = nil
      render
      rendered.should_not match(/<meta name="robots" content="noindex"/)
    end
  end

  # @page_description: Plain text string to be used as the value for the <meta name="description"> tag.
  describe "@page_description" do
    it "should set the description meta tag if true" do
      @page_description = "Test Description"
      render
      rendered.should match(/<meta name="description" content="Test Description"/)
    end
    it "should not include the description meta tag if not set" do
      @page_description = nil
      render
      rendered.should_not match(/<meta[^>]name="description"/)
    end
  end

  # @site_section: lower-case string label for the active section of the website.
  describe "@site_section" do
    it "should set the class to current for the specified section in the navmenu if true" do
      @site_section = 'Pages'
      render
      rendered.should match(/<li class="current"><a href="\/pages">Pages<\/a><\/li>/)
    end
    it "should not set a current section in the navmenu if not set" do
      @site_section = nil
      render
      rendered.should_not match(/class="current"/)
    end
  end

  # @site_breadcrumbs: An array of hashes {:text => ?, :url => ?} describing the hierarchical navigation parentage of the current item.
  describe "@site_breadcrumbs" do
    it "should set the breadcrumbs if true" do
      @site_breadcrumbs = [{:text => "Test", :url => '/test'}, {:text => "Test2", :url => '/test2'}]
      render
      rendered.should match(/<ul id="breadcrumb">[ \t\r\n]*<li><a href="\/test">Test<\/a><\/li>[ \t\r\n]*<li><a href="\/test2">Test2<\/a><\/li>[ \t\r\n]*<\/ul>/)
    end
    it "should not have breadcrumbs if not set" do
      @site_breadcrumbs = nil
      render
      rendered.should_not match(/<ul id="breadcrumb">/)
    end
  end


  # Blocks

  it "should process content_for :head" do
    # FIXME: need to figure out how to set content_for values when testing views
    #content_for(:head) { 'Test Head' }
    #render
    #rendered.should match(/Test Head[ \t\r\n]*<\/head>/)
  end

  # @site_section: lower-case string label for the active section of the website.
  describe "content_for(:actions)" do
    it "should show the actions block" do
      # FIXME: handle content_for :actions testing
      #content_for(:actions) { "Test Actions" }
      #render
      #rendered.should match(/<p class="actions">[ \t\r\n]*Test Actions[ \t\r\n]*<\/p>/)
    end
    it "should not show the actions block if not empty" do
      render
      rendered.should_not match(/<p class="actions">/)
    end
  end

  it "should process content_for :footer" do
    # FIXME: handle content_for :footer testing
  end


  # User-specific

  describe "with signed-in user" do
    before do
      controller.stub!(:current_user).and_return(mock_model(User, :name => "Test Tester"))
    end
    
    describe "via password" do
      before do
        render
      end
      it "should flag the usermenu as signed-in" do
        rendered.should match(/<ul id="usermenu" class="signed-in">/)
      end
      it "should show the name of the signed-in user" do
        rendered.should match(/<li[^>]*>Signed in as Test Tester/)
      end
      it "should link to the user’s account" do
        rendered.should match(/<a href="\/account">My Account<\/a>/)
      end
      it "should have a Sign Out link" do
        rendered.should match(/<a href="\/signout">Sign Out<\/a>/)
      end
    end
    
    describe "via Twitter" do
      it "should show Twitter as the source" do
        session[:source] = 'twitter'
        render
        rendered.should match(/<img( src="\/icon\/site\/twitter\.png(\?[^"]*)?"| alt="\(via Twitter\)"| title="via Twitter"| height="[^"]+"| width="[^"]+"){5} *\/>/)
      end
    end
  end

  describe "signed-out user" do
    before { render }
    it "should flag the usermenu as signed-out" do
      rendered.should match(/<ul id="usermenu" class="signed-out">/)
    end
    it "should have a registration link" do
      rendered.should match(/<a href="\/signup">Register[^<]*<\/a>/)
    end
    it "should have a sign-in link" do
      rendered.should match(/<a href="\/signin">Sign In<\/a>/)
    end
  end

end
