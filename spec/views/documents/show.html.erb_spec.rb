require 'spec_helper'

describe "documents/show.html.erb" do
  before(:each) do
    @document = assign(:document, stub_model(Document,
      :user => stub_model(User, :name => 'The User'),
      :path => nil,
      :filename => "filename.txt",
      :size => 9,
      :content_type => "text/plain",
      :description => "The document description.",
      :data => "test data"
    ))
  end

  it "renders attributes in <p>" do
    render
    rendered.should match(/The User/)
    rendered.should match(/filename\.txt/)
    rendered.should match(/9/)
    rendered.should match(/text\/plain/)
    rendered.should match(/The document description\./)
    # the document data is not shown
  end
end
