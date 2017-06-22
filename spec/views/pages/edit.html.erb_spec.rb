require 'rails_helper'

describe 'pages/edit.html.erb', type: :view do
  before(:each) do
    @page = assign(
      :page,
      stub_model(
        Page,
        parent: nil, filename: 'myfilename', title: 'My Title',
        description: 'My description.', content: '<p>My content.</p>'
      )
    )
  end

  it 'renders the edit page form' do
    render

    assert_select 'form', action: pages_path(@page), method: 'post' do
      assert_select 'input#page_filename', name: 'page[filename]'
      assert_select 'input#page_title', name: 'page[title]'
      assert_select 'textarea#page_description', name: 'page[description]'
      assert_select 'textarea#page_content', name: 'page[content]'
    end
  end

  it 'sets the head tags to include the necessary rich text scripts' do
    render
    expect(view.content_for(:head)).to match(%r{<script (?:|[^>]+ )src="/ckeditor/ckeditor.js"})
  end
end
