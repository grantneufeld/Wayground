require 'rails_helper'

describe 'documents/new.html.erb', type: :view do
  before(:each) do
    assign(:document, stub_model(Document,
      :user => nil,
      :path => nil,
      :filename => "a.txt",
      :size => 1,
      :content_type => "text/plain",
      :description => "A document."
    ).as_new_record)
  end

  it "renders new document form" do
    render

    assert_select "form", :action => documents_path, :method => "post" do
      assert_select "input#document_file", :name => "document[file]"
      assert_select "input#document_custom_filename", :name => "document[custom_filename]"
      assert_select "input#document_description", :name => "document[description]"
    end
  end
end
