require 'spec_helper'
require 'image'
require 'image_variant'

describe 'images/new.html.erb', type: :view do
  let(:image) { $image = Image.new }
  before(:each) do
    assign(:image, image)
  end

  it "renders new image form" do
    render
    assert_select 'form', action: images_path, method: 'patch' do
      assert_select 'input#image_title', name: 'image[title]'
      assert_select 'input#image_alt_text', name: 'image[alt_text]'
      assert_select 'textarea#image_description', name: 'image[description]'
      assert_select 'input#image_attribution', name: 'image[attribution]'
      assert_select 'input#image_attribution_url', name: 'image[attribution_url]', type: 'url'
      assert_select 'input#image_license_url', name: 'image[license_url]', type: 'url'
      # it should add 2 blank image variants
      (0..1).each do |idx|
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
