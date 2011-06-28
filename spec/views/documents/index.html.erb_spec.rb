require 'spec_helper'

describe "documents/index.html.erb" do
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
  end

  it "renders a list of documents" do
    render
    #<p class="document_item">Filename (1 bytes)
    #<br />Description
    #<a href="...">Show</a>
    #<a href="...">Edit</a>
    #<a href="...">Destroy</a>
    #</p>
  end
end
