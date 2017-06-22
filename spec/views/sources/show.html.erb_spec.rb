require 'rails_helper'

describe 'sources/show.html.erb', type: :view do
  before(:each) do
    @source = assign(
      :source,
      stub_model(
        Source,
        processor: 'The Processor', url: 'The URL', method: 'The Method', post_args: 'The Post Args',
        title: 'The Title', description: 'The Description', options: 'The Options'
      )
    )
  end

  it 'renders the expected text' do
    render
    expect(rendered).to match(/The Processor/)
    expect(rendered).to match(/The URL/)
    expect(rendered).to match(/The Method/)
    expect(rendered).to match(/The Post Args/)
    expect(rendered).to match(/The Title/)
    expect(rendered).to match(/The Description/)
    expect(rendered).to match(/The Options/)
  end
end
