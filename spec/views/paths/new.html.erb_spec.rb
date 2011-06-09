require 'spec_helper'

describe "paths/new.html.erb" do
  before(:each) do
    assign(:path, stub_model(Path,
      :item => nil,
      :sitepath => "MyText",
      :redirect => "MyText"
    ).as_new_record)
  end

  it "renders new path form" do
    render

    assert_select "form", :action => paths_path, :method => "post" do
      assert_select "textarea#path_sitepath", :name => "path[sitepath]"
      assert_select "textarea#path_redirect", :name => "path[redirect]"
    end
  end
end
