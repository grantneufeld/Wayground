require 'spec_helper'

describe 'images/edit.html.erb', type: :view do
  let(:variant) do
    $variant = ImageVariant.new(
      height: 123, width: 234,
      format: 'gif',
      style: 'original',
      url: 'http://url.tld/stub.gif'
    )
  end
  let(:image) do
    $image = Image.new(
      title: 'Stub Title',
      alt_text: 'stub alt text',
      description: 'Stub description.',
      attribution: 'Stub Attribution',
      attribution_url: 'http://stub.attribution.tld/',
      license_url: 'http://stub.license.tld/'
    )
    $image.image_variants << variant
    $image
  end
  before(:each) do
    assign(:image, image)
  end

  it "renders edit image form" do
    image.stub(:id).and_return(123)
    render
    assert_select 'form', action: '/images/123', method: 'patch' do
      assert_select 'input#image_title', name: 'image[title]', value: 'Stub Title'
      assert_select 'input#image_alt_text', name: 'image[alt_text]', value: 'stub alt text'
      assert_select 'textarea#image_description', name: 'image[description]', value: 'Stub description.'
      assert_select 'input#image_attribution', name: 'image[attribution]', value: 'Stub Attribution'
      assert_select('input#image_attribution_url',
        name: 'image[attribution_url]', type: 'url', value: 'http://stub.attribution.tld/'
      )
      assert_select('input#image_license_url',
        name: 'image[license_url]', type: 'url', value: 'http://stub.license.tld/'
      )
      label_prefix = "image_image_variants_attributes_0_"
      name_prefix = "image[image_variants_attributes][0]"
      assert_select "input##{label_prefix}id", name: "#{name_prefix}[id]", type: 'hidden'
      assert_select(
        "input##{label_prefix}height", name: "#{name_prefix}[height]", type: 'number', value: '123'
      )
      assert_select "input##{label_prefix}width", name: "#{name_prefix}[width]", type: 'number', value: '234'
      assert_select "input##{label_prefix}format", name: "#{name_prefix}[format]", value: 'gif'
      assert_select "select##{label_prefix}style", name: "#{name_prefix}[style]" do
        assert_select "option", value: "original", selected: 'selected'
        assert_select "option", value: "scaled"
      end
      assert_select("input##{label_prefix}url",
        name: "#{name_prefix}[url]", type: 'url', value: 'http://url.tld/stub.gif'
      )
      # it should add 2 blank image variants
      (1..2).each do |idx|
        label_prefix = "image_image_variants_attributes_#{idx}_"
        name_prefix = "image[image_variants_attributes][#{idx}]"
        assert_select "input##{label_prefix}id", name: "#{name_prefix}[id]", type: 'hidden'
        assert_select "input##{label_prefix}height", name: "#{name_prefix}[height]", type: 'number'
        assert_select "input##{label_prefix}width", name: "#{name_prefix}[width]", type: 'number'
        assert_select "input##{label_prefix}format", name: "#{name_prefix}[format]"
        assert_select "select##{label_prefix}style", name: "#{name_prefix}[style]" do
          assert_select "option", value: "original"
          assert_select "option", value: "scaled"
        end
        assert_select "input##{label_prefix}url", name: "#{name_prefix}[url]", type: 'url'
      end
    end
  end

end
