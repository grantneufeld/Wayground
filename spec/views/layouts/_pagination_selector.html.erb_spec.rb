require 'spec_helper'

describe 'layouts/_pagination_selector.html.erb', type: :view do
  before(:each) do
    assign(:max, 10)
    assign(:page, 3)
    assign(:offset, 20)
    assign(:default_max, 20)
    assign(:source_total, 42)
    assign(:selected_total, 10)
  end

  it "renders a sequence of page links" do
    render
    rendered.should match /First/
    rendered.should match /5/
    rendered.should match /Last/
  end
end
