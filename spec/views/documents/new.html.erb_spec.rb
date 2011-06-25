require 'spec_helper'

describe "documents/new.html.erb" do
  before(:each) do
    assign(:document, stub_model(Document,
      :user => nil,
      :path => nil,
      :filename => "a.txt",
      :size => 1,
      :content_type => "text/plain",
      :description => "A document.",
      :data => "a"
    ).as_new_record)
  end

  it "renders new document form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => documents_path, :method => "post" do
      assert_select "input#document_file", :name => "document[file]"
      assert_select "input#document_custom_filename", :name => "document[custom_filename]"
      assert_select "input#document_description", :name => "document[description]"
    end
  end
end
