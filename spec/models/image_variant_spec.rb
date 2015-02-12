require 'spec_helper'
require 'image_variant'
require 'image'

describe ImageVariant, type: :model do

  before(:all) do
    ImageVariant.delete_all
    Image.delete_all
  end

  describe "attribute mass assignment security" do
    it "should allow height" do
      height = '123'
      expect( ImageVariant.new(height: height).height ).to eq height.to_i
    end
    it "should allow width" do
      width = '456'
      expect( ImageVariant.new(width: width).width ).to eq width.to_i
    end
    it "should allow format" do
      format = 'example'
      expect( ImageVariant.new(format: format).format ).to eq format
    end
    it "should allow style" do
      style = 'resize'
      expect( ImageVariant.new(style: style).style ).to eq style
    end
    it "should allow url" do
      url = 'example url'
      expect( ImageVariant.new(url: url).url ).to eq url
    end
  end

  describe "validations" do
    let(:image) { $image = Image.new }
    let(:min_params) { $min_params = {format: 'jpeg', style: 'original', url: 'http://required.tld/'} }
    it "should validate with just the required values" do
      variant = ImageVariant.new(min_params)
      variant.image = image
      expect( variant.valid? ).to be_truthy
    end
    describe "of image" do
      it "should not validate when image absent on update" do
        variant = FactoryGirl.create(:image_variant)
        variant.image = nil
        expect( variant.valid? ).to be_falsey
      end
    end
    describe "of height" do
      it "should not validate with a non-intenger number" do
        variant = ImageVariant.new(min_params.merge(height: '3.14'))
        variant.image = image
        expect( variant.valid? ).to be_falsey
      end
      it "should not validate with a negative height" do
        variant = ImageVariant.new(min_params.merge(height: '-1'))
        variant.image = image
        expect( variant.valid? ).to be_falsey
      end
      it "should not validate with a height of zero" do
        variant = ImageVariant.new(min_params.merge(height: '0'))
        variant.image = image
        expect( variant.valid? ).to be_falsey
      end
      it "should validate with a height of 1" do
        variant = ImageVariant.new(min_params.merge(height: '1'))
        variant.image = image
        expect( variant.valid? ).to be_truthy
      end
    end
    describe "of width" do
      it "should not validate with a non-intenger number" do
        variant = ImageVariant.new(min_params.merge(width: '1.23'))
        variant.image = image
        expect( variant.valid? ).to be_falsey
      end
      it "should not validate with a negative width" do
        variant = ImageVariant.new(min_params.merge(width: '-1'))
        variant.image = image
        expect( variant.valid? ).to be_falsey
      end
      it "should not validate with a width of zero" do
        variant = ImageVariant.new(min_params.merge(width: '0'))
        variant.image = image
        expect( variant.valid? ).to be_falsey
      end
      it "should validate with a width of 1" do
        variant = ImageVariant.new(min_params.merge(width: '1'))
        variant.image = image
        expect( variant.valid? ).to be_truthy
      end
    end
    describe "of format" do
      it "should not validate when format absent" do
        min_params.delete(:format)
        variant = ImageVariant.new(min_params)
        variant.image = image
        expect( variant.valid? ).to be_falsey
      end
    end
    describe "of style" do
      it "should not validate when style absent" do
        min_params.delete(:style)
        variant = ImageVariant.new(min_params)
        variant.image = image
        expect( variant.valid? ).to be_falsey
      end
    end
    describe "of url" do
      it "should not validate when url absent" do
        min_params.delete(:url)
        variant = ImageVariant.new(min_params)
        variant.image = image
        expect( variant.valid? ).to be_falsey
      end
      it "should not validate when url is invalid" do
        variant = ImageVariant.new(min_params.merge(url: 'invalid'))
        variant.image = image
        expect( variant.valid? ).to be_falsey
      end
    end
  end

  describe "scopes" do
    describe ".originals" do
      before(:all) do
        @image = Image.new
        @scaled = @image.image_variants.new(url: 'http://scaled.tld/', style: 'scaled', format: 'png')
        @image.save!
      end
      context "with no ‘original’ variants" do
        before(:all) do
          # make sure there are no original variants
          @image.image_variants.where(style: 'original').destroy_all
        end
        it "should return the scaled variant" do
          expect( @image.image_variants.originals ).to eq [@scaled]
        end
      end
      context "with one ‘original’ variant" do
        before(:all) do
          @image.image_variants.where(style: 'original').destroy_all
          @variant = @image.image_variants.create!(url: 'http://o.tld/', style: 'original', format: 'png')
        end
        it "should return the one variant and the scaled" do
          expect( @image.image_variants.originals.to_a ).to eq [@variant, @scaled]
        end
      end
      context "with multiple ‘original’ variants" do
        before(:all) do
          @variants = []
          @image.image_variants.where(style: 'original').order(:id).each do |variant|
            @variants << variant
          end
          while @variants.count < 2 do
            @variants << @image.image_variants.create!(url: 'http://o.tld/', style: 'original', format: 'png')
          end
          @variants << @scaled
        end
        it "should return all the variants" do
          expect( @image.image_variants.originals.order(:id).to_a ).to eq @variants
        end
      end
    end

    describe ".largest" do
      it "should order the results from largest to smallest" do
        ImageVariant.delete_all
        image = Image.first || FactoryGirl.create(:image)
        v1 = image.image_variants.new(url: 'http://a.tld', style: 'scaled', format: 'png',
          height: 10, width: 20
        )
        v2 = image.image_variants.new(url: 'http://b.tld', style: 'scaled', format: 'png',
          height: 100, width: 200
        )
        v3 = image.image_variants.new(url: 'http://c.tld', style: 'scaled', format: 'png',
          height: 20, width: 40
        )
        v4 = image.image_variants.new(url: 'http://d.tld', style: 'scaled', format: 'png',
          height: 50, width: 100
        )
        image.save!
        expect( ImageVariant.largest.to_a ).to eq [v2, v4, v3, v1]
      end
    end
  end

end
