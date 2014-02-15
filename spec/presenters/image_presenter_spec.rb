require 'spec_helper'
require 'image_presenter'

describe ImagePresenter do

  def view_stub
    view = double('View')
    #view.stub_chain(:request, :path).and_return(path)
    view
  end

  before(:all) do
    @image = Image.new(
      title: 'Present Title', alt_text: 'present alt', description: 'Present description.',
      attribution: 'Present Attribution', attribution_url: 'http://present.attrib/',
      license_url: 'http://present.license/'
    )
    @original = @image.image_variants.new(
      height: 1234, width: 2345, format: 'png', style: 'original', url: 'http://present.tld/original.png'
    )
    @scaled = @image.image_variants.new(
      height: 123, width: 234, format: 'jpeg', style: 'scaled', url: 'http://present.tld/scaled.jpg'
    )
    @image.save!
  end

  describe "initialization" do
    it "should take a view parameter" do
      presenter = ImagePresenter.new(view: :view)
      expect( presenter.view ).to eq :view
    end
    it "should take an image parameter" do
      presenter = ImagePresenter.new(image: @image)
      expect( presenter.image ).to eq @image
    end
    it "should take an image_variant parameter" do
      variant = ImageVariant.new
      presenter = ImagePresenter.new(image_variant: variant, image: @image)
      expect( presenter.image_variant ).to eq variant
    end
    it "should take a height parameter" do
      presenter = ImagePresenter.new(height: 12345)
      expect( presenter.height ).to eq 12345
    end
    it "should take a width parameter" do
      presenter = ImagePresenter.new(width: 23456)
      expect( presenter.width ).to eq 23456
    end
  end

  describe "#present" do
    context "with an image variant param" do
      it "should use the image variant values" do
        presenter = ImagePresenter.new(view: view_stub, image: @image, image_variant: @scaled)
        expect( presenter.present ).to eq(
          "<img src=\"http://present.tld/scaled.jpg\" height=\"123\" width=\"234\" " +
          "alt=\"present alt\" title=\"Present Title\" />"
        )
      end
    end
    context "with height and width params" do
      it "should override the height and width" do
        presenter = ImagePresenter.new(view: view_stub, image: @image, height: 345, width: 456)
        expect( presenter.present ).to eq(
          "<img src=\"http://present.tld/original.png\" height=\"345\" width=\"456\" " +
          "alt=\"present alt\" title=\"Present Title\" />"
        )
      end
    end
  end

  describe "#image_variant" do
    it "should call through to the image’s get_best_variant method if not already set" do
      @image.should_receive(:get_best_variant).and_return(:variant)
      presenter = ImagePresenter.new(view: view_stub, image: @image)
      expect( presenter.image_variant ).to eq :variant
    end
    it "should just return the given variant when set" do
      @image.should_not_receive(:get_best_variant)
      variant = ImageVariant.new
      presenter = ImagePresenter.new(view: view_stub, image: @image, image_variant: variant)
      expect( presenter.image_variant ).to eq variant
    end
  end

  describe "#alt_text" do
    it "should return nil when not given an image" do
      presenter = ImagePresenter.new(view: view_stub)
      expect( presenter.alt_text ).to be_nil
    end
    it "should return the alt text from the given image" do
      presenter = ImagePresenter.new(view: view_stub, image: @image)
      expect( presenter.alt_text ).to eq 'present alt'
    end
  end

  describe "#title" do
    it "should return nil when not given an image" do
      presenter = ImagePresenter.new(view: view_stub)
      expect( presenter.title ).to be_nil
    end
    it "should return the title from the given image" do
      presenter = ImagePresenter.new(view: view_stub, image: @image)
      expect( presenter.title ).to eq 'Present Title'
    end
  end

end
