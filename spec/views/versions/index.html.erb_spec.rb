require 'spec_helper'

describe "versions/index.html.erb" do
  before(:each) do
    assign(:item, stub_model(Page, :id => 123, :title => 'Page Title'))
    assign(:versions, [
      stub_model(Version,
        #:item => stub_model(Page, :title => 'Page Title'),
        :user => stub_model(User, :name => 'My User'),
        :edited_at => '2000-01-02 03:04:05',
        :edit_comment => "Comment"
        #:filename => "Filename",
        #:title => "My Title",
        #:url => "http://my.url/",
        #:description => "My Description",
        #:content => "MyText",
        #:content_type => "Content Type"
      ),
      stub_model(Version,
        #:item => stub_model(Page, :title => 'Page Title'),
        :user => stub_model(User, :name => 'My User'),
        :edited_at => '2000-01-02 03:04:05',
        :edit_comment => "Comment"
        #:filename => "Filename",
        #:title => "My Title",
        #:url => "http://my.url/",
        #:description => "My Description",
        #:content => "MyText",
        #:content_type => "Content Type"
      )
    ])
  end

  it "renders a list of versions" do
    render
    rendered.should match(/My User/)
    rendered.should match(/2000-01-02 03:04:05/)
    rendered.should match(/Comment/)
  end
end
