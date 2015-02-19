require 'rails_helper'

describe 'versions/show.html.erb', type: :view do
  before(:each) do
    @version = assign(:version, stub_model(Version,
      item: stub_model(Page, title: 'Page Title'),
      user: stub_model(User, name: 'User Name'),
      edited_at: '2000-01-02 03:04:05',
      edit_comment: "Comment",
      filename: "Filename",
      title: "Title",
      values: {'abc' => 'def'}
    ))
  end

  it "renders attributes in <p>" do
    render
    expect( rendered ).to match(/Page Title/)
    expect( rendered ).to match(/User Name/)
    expect( rendered ).to match(/2000-01-02 03:04:05/)
    expect( rendered ).to match(/Comment/)
    expect( rendered ).to match(/Filename/)
    expect( rendered ).to match(/Title/)
  end
end
