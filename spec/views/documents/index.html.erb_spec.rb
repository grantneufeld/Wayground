require 'spec_helper'

describe 'documents/index.html.erb', type: :view do
  before(:each) do
    assign(:documents, [
      stub_model(Document,
        :user => nil,
        :path => nil,
        :filename => "Filename",
        :size => 1,
        :content_type => "Content Type",
        :description => "Description"
      ),
      stub_model(Document,
        :user => nil,
        :path => nil,
        :filename => "Filename",
        :size => 1,
        :content_type => "Content Type",
        :description => "Description"
      )
    ])
    assign(:max, 2)
    assign(:page, 2)
    assign(:offset, 2)
    assign(:default_max, 20)
    assign(:source_total, 7)
    assign(:selected_total, 2)
  end

  it "renders a list of documents" do
    render
    # pagination
    rendered.should match(/Showing 2 of 7 documents\./)
    expect(rendered).to match(
      /Pages:\s*
      <a[^>]*>First<\/a>\s*
      <a[^>]*>1<\/a>\s*<a[^>]*>2<\/a>\s*<a[^>]*>3<\/a>\s*<a[^>]*>4<\/a>\s*
      <a[^>]*>Last<\/a>/x
    )
    # content
    #<p class="document_item">Filename (1 bytes)
    #<br />Description
    #<a href="...">Show</a>
    #<a href="...">Edit</a>
    #<a href="...">Destroy</a>
    #</p>
  end
end
