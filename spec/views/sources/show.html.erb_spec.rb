require 'spec_helper'

describe 'sources/show.html.erb' do
  before(:each) do
    @source = assign(:source, stub_model(Source,
      :processor => 'The Processor',
      :url => 'The URL',
      :method => 'The Method',
      :post_args => 'The Post Args',
      :title => 'The Title',
      :description => 'The Description',
      :options => 'The Options'
    ))
  end

  it 'renders the expected text' do
    render
    rendered.should match(/The Processor/)
    rendered.should match(/The URL/)
    rendered.should match(/The Method/)
    rendered.should match(/The Post Args/)
    rendered.should match(/The Title/)
    rendered.should match(/The Description/)
    rendered.should match(/The Options/)
  end
end
