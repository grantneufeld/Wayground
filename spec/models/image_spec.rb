require 'rails_helper'
require 'image'

describe Image, type: :model do

  describe "validations" do
    it "should validate with all blank values" do
      expect( Image.new().valid? ).to be_truthy
    end
    it "should validate with a valid attribution url" do
      expect( Image.new(attribution_url: 'http://test.tld/').valid? ).to be_truthy
    end
    it "should not validate with an invalid attribution url" do
      expect( Image.new(attribution_url: 'not an url').valid? ).to be_falsey
    end
    it "should validate with a valid license url" do
      expect( Image.new(license_url: 'http://license.tld/').valid? ).to be_truthy
    end
    it "should not validate with an invalid license url" do
      expect( Image.new(license_url: 'not an url').valid? ).to be_falsey
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
        @image.image_variants.delete_all
        expect( @image.get_best_variant ).to eq nil
      end
    end
    context "with one variant" do
      it "should return the variant" do
        @image.image_variants.delete_all
        variant = @image.image_variants.create!(style: 'scaled', url: 'http://a.tld', format: 'png')
        expect( @image.get_best_variant ).to eq variant
      end
    end
    context "with no original variants" do
      it "should return the largest scaled variant" do
        @image.image_variants.delete_all
        variant1 = @image.image_variants.new(style: 'scaled', url: 'http://a.tld', format: 'png',
          height: 10, width: 10
        )
        variant2 = @image.image_variants.new(style: 'scaled', url: 'http://a.tld', format: 'png',
          height: 100, width: 100
        )
        @image.save!
        expect( @image.get_best_variant ).to eq variant2
      end
    end
    context "with one original variant" do
      it "should return the original" do
        @image.image_variants.delete_all
        variant = @image.image_variants.new(style: 'scaled', url: 'http://a.tld', format: 'png',
          height: 100, width: 100
        )
        original = @image.image_variants.new(style: 'original', url: 'http://a.tld', format: 'png',
          height: 10, width: 10
        )
        @image.save!
        expect( @image.get_best_variant ).to eq original
      end
    end
    context "with multiple original variants" do
      it "should return the largest" do
        @image.image_variants.delete_all
        original1 = @image.image_variants.new(style: 'original', url: 'http://a.tld', format: 'png',
          height: 10, width: 10
        )
        original2 = @image.image_variants.new(style: 'original', url: 'http://a.tld', format: 'png',
          height: 100, width: 100
        )
        @image.save!
        expect( @image.get_best_variant ).to eq original2
      end
    end
  end

end
