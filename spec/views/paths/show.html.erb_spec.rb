require 'spec_helper'

describe "paths/show.html.erb" do
  before(:each) do
    @path = assign(:path, stub_model(Path,
      :item => nil,
      :sitepath => "MyText",
      :redirect => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    rendered.should match(//)
    rendered.should match(/MyText/)
    rendered.should match(/MyText/)
  end
end
