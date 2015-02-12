require 'spec_helper'

describe 'sources/index.html.erb', type: :view do
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
    assert_select "tr>td", :text => "The Processor: The TitleThe URL", :count => 2
  end
end
