require 'spec_helper'

describe 'layouts/_pagination_header.html.erb', type: :view do
  before(:each) do
    assign(:source_total, 42)
    assign(:selected_total, 10)
  end

  it "renders a information about the pagination" do
    render :partial => 'pagination_header', :locals => {:item_plural => 'tests'}
    rendered.should match /Showing 10 of 42 tests\./
  end
end
