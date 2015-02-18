require 'rails_helper'

describe 'images/show.html.erb', type: :view do

  let(:variant) do
    $variant = ImageVariant.new(
      height: 123, width: 234,
      format: 'gif',
      style: 'original',
      url: 'http://url.tld/stub.gif'
    )
  end
  let(:image_attrs) do
    $image_attrs = {
      title: 'Stub Title',
      alt_text: 'stub alt text',
      description: 'Stub description.',
      attribution: 'Stub Attribution',
      attribution_url: 'http://stub.attribution.tld/',
      license_url: 'http://stub.license.tld/'
    }
  end
  let(:image) do
    $image = Image.new(image_attrs)
    $image.image_variants << variant
    $image
  end
  before(:each) do
    assign(:image, image)
  end

  context "with no title" do
    let(:image_attrs) { $image_attrs = {} }
    it "renders the id in place of the title" do
      allow(image).to receive(:id).and_return(123)
      render
      expect( rendered ).to match /<h1(?:| [^>]*)>.*123.*<\/h1>/
    end
  end
  context "with a title" do
    it "renders the title" do
      render
      expect( rendered ).to match /<h1(?:| [^>]*)>.*Stub Title.*<\/h1>/
    end
  end
  context "with a description" do
    let(:image_attrs) { $image_attrs = {description: 'Stub description.'} }
    it "renders the description" do
      render
      expect( rendered ).to match /<[^>]+>[\r\n]*Stub description.[\r\n]*<\/[^>]+>/
    end
  end
  #context "with attribution" do
  #  it "renders the attribution"
  #  context "with an attribution url" do
  #    it "renders the attribution as a link"
  #  end
  #end
  #context "without attribution, but with an attribution url" do
  #  it "renders the attribution url"
  #end
  #context "with a license url" do
  #  it "renders the license url"
  #end
  #context "with no variants" do
  #  it "does not render a gallery"
  #end
  #context "with one variant" do
  #  it "renders the variant in a gallery"
  #end
  #context "with multiple variants" do
  #  it "renders the variants in a gallery"
  #end

end
