require 'spec_helper'

describe "documents/edit.html.erb" do
  before(:each) do
    @document = assign(:document, stub_model(Document,
      :user => nil,
      :path => nil,
      :filename => "a.txt",
      :size => 1,
      :content_type => "text/plain",
      :description => "A document."
    ))
  end

  it "renders the edit document form" do
    render

    assert_select "form", :action => documents_path(@document), :method => "post" do
      #assert_select "input#document_file", :name => "document[file]"
      assert_select "input#document_custom_filename", :name => "document[custom_filename]"
      assert_select "input#document_description", :name => "document[description]"
    end
  end
end
