require 'spec_helper'

describe "pages/index.html.erb" do
  before(:each) do
    assign(:pages, [
      stub_model(Page,
        :parent => nil,
        :path => stub_model(Path, :sitepath => '/myfilename'),
        :filename => "myfilename",
        :title => "My Title",
        :description => "My description.",
        :content => "<p>My content.</p>"
      ),
      stub_model(Page,
        :parent => nil,
        :path => stub_model(Path, :sitepath => '/myfilename'),
        :filename => "Filename",
        :title => "Title",
        :description => "A description.",
        :content => "<p>Some content.</p>"
      )
    ])
  end

  it "renders a list of pages" do
    view.stub(:current_user) { nil }
    render
    assert_select "tr>td", :text => "/myfilename".to_s
    assert_select "tr>td", :text => "My Title".to_s
    assert_select "tr>td", :text => "My description.".to_s
    #assert_select "tr>td>p", :text => "My content.".to_s
    assert_select "tr>td", :text => "/Filename".to_s
    assert_select "tr>td", :text => "Title".to_s
    assert_select "tr>td", :text => "A description.".to_s
    #assert_select "tr>td>p", :text => "Some content.".to_s
  end
end