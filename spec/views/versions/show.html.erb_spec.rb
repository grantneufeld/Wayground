require 'spec_helper'

describe "versions/show.html.erb" do
  before(:each) do
    @version = assign(:version, stub_model(Version,
      :item => stub_model(Page, :title => 'Page Title'),
      :user => stub_model(User, :name => 'User Name'),
      :edited_at => '2000-01-02 03:04:05',
      :edit_comment => "Comment",
      :filename => "Filename",
      :title => "Title",
      :url => "MyText",
      :description => "MyText",
      :content => "MyText",
      :content_type => "Content Type"
    ))
  end

  it "renders attributes in <p>" do
    render
    rendered.should contain('Page Title')
    rendered.should contain('User Name')
    rendered.should contain('2000-01-02 03:04:05')
    rendered.should contain("Comment")
    rendered.should contain("Filename")
    rendered.should contain("Title")
    rendered.should contain("MyText")
    rendered.should contain("MyText")
    rendered.should contain("MyText")
    rendered.should contain("Content Type")
  end
end
