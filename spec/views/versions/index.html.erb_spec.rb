require 'rails_helper'

describe 'versions/index.html.erb', type: :view do
  before(:each) do
    assign(:item, stub_model(Page, id: 123, title: 'Page Title'))
    assign(
      :versions,
      [
        stub_model(
          Version,
          user: stub_model(User, name: 'My User'),
          edited_at: '2000-01-02 03:04:05',
          edit_comment: 'Comment'
        ),
        stub_model(
          Version,
          user: stub_model(User, name: 'My User'),
          edited_at: '2000-01-02 03:04:05',
          edit_comment: 'Comment'
        )
      ]
    )
    assign(:max, 4)
    assign(:page, 4)
    assign(:offset, 12)
    assign(:default_max, 25)
    assign(:source_total, 14)
    assign(:selected_total, 2)
  end

  it 'renders a list of versions' do
    render
    expect(rendered).to match(/My User/)
    expect(rendered).to match(/2000-01-02 03:04:05/)
    expect(rendered).to match(/Comment/)
  end
end
