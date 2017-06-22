require 'rails_helper'

describe 'paths/index.html.erb', type: :view do
  before(:each) do
    assign(
      :paths,
      [
        stub_model(
          Path,
          item: nil,
          sitepath: '/site/path',
          redirect: '/redirect/1'
        ),
        stub_model(
          Path,
          item: nil,
          sitepath: '/site/path2',
          redirect: '/redirect/2'
        )
      ]
    )
    assign(:max, 5)
    assign(:page, 3)
    assign(:offset, 10)
    assign(:default_max, 20)
    assign(:source_total, 12)
    assign(:selected_total, 2)
  end

  it 'renders a list of paths' do
    render
    assert_select 'tr>td', text: '/site/path', count: 1
    assert_select 'tr>td', text: '/redirect/1', count: 1
    assert_select 'tr>td', text: '/site/path2', count: 1
    assert_select 'tr>td', text: '/redirect/2', count: 1
  end
end
