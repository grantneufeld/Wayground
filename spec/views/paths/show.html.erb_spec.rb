require 'rails_helper'

describe 'paths/show.html.erb', type: :view do
  before(:each) do
    @path = assign(:path, stub_model(Path,
      :item => nil,
      :sitepath => "MyText",
      :redirect => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/MyText/)
  end
end
