require 'rails_helper'

describe 'documents/show.html.erb', type: :view do
  before(:each) do
    @document = assign(
      :document,
      stub_model(
        Document,
        user: stub_model(User, name: 'The User'),
        path: nil, filename: 'filename.txt', size: 9,
        content_type: 'text/plain', description: 'The document description.'
      )
    )
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/The User/)
    expect(rendered).to match(/filename\.txt/)
    expect(rendered).to match(/9/)
    expect(rendered).to match(%r{text/plain})
    expect(rendered).to match(/The document description\./)
    # the document data is not shown
  end
end
