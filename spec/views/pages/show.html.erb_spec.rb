require 'spec_helper'

describe 'pages/show.html.erb', type: :view do
  before(:each) do
    @page = assign(:page, stub_model(Page,
      :parent => nil,
      :path => stub_model(Path, :sitepath => '/myfilename'),
      :filename => "myfilename",
      :title => "My Title",
      :description => "My description.",
      :content => "<p>My content.</p>"
    ))
  end

  it "renders attributes in <p>" do
    allow(view).to receive(:current_user) { nil }
    render
    rendered.should match(/myfilename/)
    rendered.should match(/My Title/)
    rendered.should match(/My description/)
    rendered.should match(/My content\./)
  end
end
