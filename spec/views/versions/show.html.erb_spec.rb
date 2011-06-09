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
    rendered.should match(/Page Title/)
    rendered.should match(/User Name/)
    rendered.should match(/2000-01-02 03:04:05/)
    rendered.should match(/Comment/)
    rendered.should match(/Filename/)
    rendered.should match(/Title/)
    rendered.should match(/MyText/)
    rendered.should match(/MyText/)
    rendered.should match(/MyText/)
    rendered.should match(/Content Type/)
  end
end
