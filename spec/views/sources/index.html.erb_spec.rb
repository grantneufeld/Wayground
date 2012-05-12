require 'spec_helper'

describe "sources/index.html.erb" do
  before(:each) do
    assign(:sources, [
      stub_model(Source,
        :processor => 'The Processor',
        :url => 'The URL',
        :method => 'The Method',
        :post_args => 'The Post Args',
        :title => 'The Title',
        :description => 'The Description',
        :options => 'The Options'
      ),
      stub_model(Source,
        :processor => 'The Processor',
        :url => 'The URL',
        :method => 'The Method',
        :post_args => 'The Post Args',
        :title => 'The Title',
        :description => 'The Description',
        :options => 'The Options'
      )
    ])
  end

  it "renders a list of sources" do
    render
    assert_select "tr>td", :text => "The Title", :count => 2
    assert_select "tr>td", :text => "The Processor", :count => 2
    assert_select "tr>td", :text => "The URL", :count => 2
    assert_select "tr>td", :text => "The Description", :count => 2
  end
end
