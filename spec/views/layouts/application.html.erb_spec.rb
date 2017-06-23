require 'rails_helper'
require 'page_metadata'

describe 'layouts/application.html.erb', type: :view do
  before do
    controller.singleton_class.class_eval do
      protected

      def current_user
        nil
      end

      def page_metadata
        @page_metadata ||= Wayground::PageMetadata.new
      end

      def page_submenu_items
        []
      end
      helper_method :current_user
      helper_method :page_metadata
      helper_method :page_submenu_items
    end
  end

  # Parameters

  # title: Used in the <title> meta tag. If blank, defaults to the site title.
  describe 'page_metadata.title' do
    it 'should be used for the title element if present' do
      @page_metadata = Wayground::PageMetadata.new(title: 'Test Title')
      allow(view).to receive(:page_metadata).and_return(@page_metadata)
      render
      expect(rendered).to match(%r{<title>Test Title \[#{Wayground::Application::NAME}\]</title>})
    end
    it 'should default to the site title if blank' do
      @page_metadata = Wayground::PageMetadata.new(title: nil)
      allow(view).to receive(:page_metadata).and_return(@page_metadata)
      render
      expect(rendered).to match(%r{<title>#{Wayground::Application::NAME}</title>})
    end
  end

  # nocache: A boolean that instructs browsers and search engines not to cache the content of this page.
  describe 'page_metadata.nocache' do
    it 'should include the robots-noindex meta tag if true' do
      @page_metadata = Wayground::PageMetadata.new(nocache: true)
      allow(view).to receive(:page_metadata).and_return(@page_metadata)
      render
      expect(rendered).to match(/<meta name="robots" content="noindex"/)
    end
    it 'should not include the robots-noindex meta tag if false' do
      @page_metadata = Wayground::PageMetadata.new(nocache: false)
      allow(view).to receive(:page_metadata).and_return(@page_metadata)
      render
      expect(rendered).not_to match(/<meta name="robots" content="noindex"/)
    end
  end

  # description: Plain text string to be used as the value for the <meta name="description"> tag.
  describe 'page_metadata.description' do
    it 'should set the description meta tag if true' do
      @page_metadata = Wayground::PageMetadata.new(description: 'Test Description')
      allow(view).to receive(:page_metadata).and_return(@page_metadata)
      render
      expect(rendered).to match(/<meta name="description" content="Test Description"/)
    end
    it 'should not include the description meta tag if not set' do
      @page_metadata = Wayground::PageMetadata.new(description: nil)
      allow(view).to receive(:page_metadata).and_return(@page_metadata)
      render
      expect(rendered).to_not match(/<meta[^>]+name="description"/)
    end
  end

  # @site_section: lower-case string label for the active section of the website.
  describe '@site_section' do
    it 'should set the class to current for the specified section in the navmenu if true' do
      assign(:site_section, :calendar)
      render
      expect(rendered).to match(%r{<li class="current"><a[^>]* href="/calendar"[^>]*>Calendar</a></li>})
    end
    it 'should not set a current section in the navmenu if not set' do
      @site_section = nil
      render
      expect(rendered).not_to match(/class="current"/)
    end
  end

  # @site_breadcrumbs: An array of hashes { text: ?, url: ? }
  #   describing the hierarchical navigation parentage of the current item.
  describe '@site_breadcrumbs' do
    it 'should set the breadcrumbs if true' do
      @site_breadcrumbs = [{ text: 'Test', url: '/test' }, { text: 'Test2', url: '/test2' }]
      render
      expect(rendered).to match(
        %r{<ul\ id="breadcrumb">[\ \t\r\n]*
        <li><a\ href="/test">Test</a></li>[\ \t\r\n]*
        <li><a\ href="/test2">Test2</a></li>[\ \t\r\n]*
        </ul>}x
      )
    end
    it 'should not have breadcrumbs if not set' do
      @site_breadcrumbs = nil
      render
      expect(rendered).not_to match(/<ul id="breadcrumb">/)
    end
  end

  # Blocks

  # :head - Goes at the end of the head. Useful for custom meta tags, javascript links, etc.
  it 'content_for(:head) should go at the end of the head element' do
    view.content_for(:head) { 'Test Head' }
    render
    expect(rendered).to match(%r{Test Head[ \t\r\n]*</head>})
  end

  # :actions - links (of class="action") to go in the action bar for the page (at the top of the footer).
  describe 'content_for(:actions)' do
    it 'should show the actions block' do
      view.content_for(:actions) { 'Test Actions' }
      render
      expect(rendered).to match(%r{<p class="actions">[ \t\r\n]*Test Actions[ \t\r\n]*</p>})
    end
    it 'should not show the actions block if not empty' do
      render
      expect(rendered).not_to match(/<p class="actions">/)
    end
  end

  # :footer - Goes in the footer, right after the actions (if any).
  it 'content_for(:footer) should go at the top of the footer' do
    view.content_for(:footer) { 'Test Footer' }
    render
    expect(rendered).to match(/<footer( [^>]*)?>[ \t\r\n]*Test Footer/)
  end

  # User-specific

  describe 'with signed-in user' do
    before do
      allow(controller).to receive(:current_user).and_return(mock_model(User, name: 'Test Tester'))
    end

    describe 'via password' do
      before do
        render
      end
      it 'should flag the usermenu as signed-in' do
        expect(rendered).to match(/<div id="usermenu"[^>]* class="(?:[^"]* )?signed-in/)
      end
      it 'should show the name of the signed-in user' do
        expect(rendered).to match(/<div id="usermenu"[^>]* title="[^"]*Test Tester/)
      end
      it 'should link to the user’s account' do
        expect(rendered).to match('<a href="/account">Your Account</a>')
      end
      it 'should have a Sign Out link' do
        expect(rendered).to match('<a href="/signout">Sign Out</a>')
      end
    end

    describe 'via Twitter' do
      it 'should show Twitter as the source' do
        session[:source] = 'twitter'
        render
        expect(rendered).to match(
          /<div id="usermenu"[^>]* class="(?:[^"]+ )?twitter/
        )
      end
    end
  end

  describe 'signed-out user' do
    before { render }
    it 'should flag the usermenu as signed-out' do
      expect(rendered).to match('<div id="usermenu" class="hidden"')
    end
    # it 'should have a registration link' do
    #   expect(rendered).to match(%r{<a href="/signup">Register[^<]*</a>})
    # end
    # it 'should have a sign-in link' do
    #   expect(rendered).to match(%r{<a href="/signin">Sign In</a>})
    # end
  end
end
