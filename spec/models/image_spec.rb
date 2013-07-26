# encoding: utf-8
require 'spec_helper'
require 'image'

describe Image do

  describe "attribute mass assignment security" do
    it "should allow title" do
      title = 'Example Image Title'
      expect( Image.new(title: title).title ).to eq title
    end
    it "should allow alt_text" do
      alt_text = 'Example Alt Text'
      expect( Image.new(alt_text: alt_text).alt_text ).to eq alt_text
    end
    it "should allow description" do
      description = 'Example Description'
      expect( Image.new(description: description).description ).to eq description
    end
    it "should allow attribution" do
      attribution = 'Example Attribution'
      expect( Image.new(attribution: attribution).attribution ).to eq attribution
    end
    it "should allow attribution_url" do
      attribution_url = 'Example Attribution URL'
      expect( Image.new(attribution_url: attribution_url).attribution_url ).to eq attribution_url
    end
    it "should allow license_url" do
      license_url = 'Example License URL'
      expect( Image.new(license_url: license_url).license_url ).to eq license_url
    end
    it "should allow image_variants_attributes to be set" do
      url = 'http://set.image_variants_attributes.tld/'
      image = Image.new(:image_variants_attributes => {'0' => {url: url, style: 'original'}})
      expect( image.image_variants[0].url ).to eq url
    end
  end

  describe "validations" do
    it "should validate with all blank values" do
      expect( Image.new().valid? ).to be_true
    end
    it "should validate with a valid attribution url" do
      expect( Image.new(attribution_url: 'http://test.tld/').valid? ).to be_true
    end
    it "should not validate with an invalid attribution url" do
      expect( Image.new(attribution_url: 'not an url').valid? ).to be_false
    end
    it "should validate with a valid license url" do
      expect( Image.new(license_url: 'http://license.tld/').valid? ).to be_true
    end
    it "should not validate with an invalid license url" do
      expect( Image.new(license_url: 'not an url').valid? ).to be_false
    end
  end

  describe "#image_variants" do
    it "should accept image variants as a relation" do
      image = Image.new
      variant = ImageVariant.new(format: 'test', style: 'full', url: 'http://variant.tld/')
      image.image_variants << variant
      expect( image.image_variants.first ).to eq variant
    end
    it "should delete image variants when the image is destroyed" do
      image = FactoryGirl.create(:image)
      variant = FactoryGirl.create(:image_variant, image: image)
      expect { image.destroy }.to change{ ImageVariant.count}.by(-1)
    end
  end

  describe "#get_best_variant" do
    before(:all) do
      @image = FactoryGirl.create(:image)
    end
    context "with no variants" do
      it "should return nil" do
        @image.image_variants.destroy_all
        expect( @image.get_best_variant ).to eq nil
      end
    end
    context "with one variant" do
      it "should return the variant" do
        @image.image_variants.destroy_all
        variant = @image.image_variants.create!(style: 'scaled', url: 'http://a.tld', format: 'png')
        expect( @image.get_best_variant ).to eq variant
      end
    end
    context "with no original variants" do
      it "should return the largest scaled variant" do
        @image.image_variants.destroy_all
        variant1 = @image.image_variants.build(style: 'scaled', url: 'http://a.tld', format: 'png',
          height: 10, width: 10
        )
        variant2 = @image.image_variants.build(style: 'scaled', url: 'http://a.tld', format: 'png',
          height: 100, width: 100
        )
        @image.save!
        expect( @image.get_best_variant ).to eq variant2
      end
    end
    context "with one original variant" do
      it "should return the original" do
        @image.image_variants.destroy_all
        variant = @image.image_variants.build(style: 'scaled', url: 'http://a.tld', format: 'png',
          height: 100, width: 100
        )
        original = @image.image_variants.build(style: 'original', url: 'http://a.tld', format: 'png',
          height: 10, width: 10
        )
        @image.save!
        expect( @image.get_best_variant ).to eq original
      end
    end
    context "with multiple original variants" do
      it "should return the largest" do
        @image.image_variants.destroy_all
        original1 = @image.image_variants.build(style: 'original', url: 'http://a.tld', format: 'png',
          height: 10, width: 10
        )
        original2 = @image.image_variants.build(style: 'original', url: 'http://a.tld', format: 'png',
          height: 100, width: 100
        )
        @image.save!
        expect( @image.get_best_variant ).to eq original2
      end
    end
  end

end
