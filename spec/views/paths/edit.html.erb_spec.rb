require 'spec_helper'

describe "paths/edit.html.erb" do
  before(:each) do
    @path = assign(:path, stub_model(Path,
      :item => nil,
      :sitepath => "MyText",
      :redirect => "MyText"
    ))
  end

  it "renders the edit path form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => paths_path(@path), :method => "post" do
      assert_select "textarea#path_sitepath", :name => "path[sitepath]"
      assert_select "textarea#path_redirect", :name => "path[redirect]"
    end
  end
end
