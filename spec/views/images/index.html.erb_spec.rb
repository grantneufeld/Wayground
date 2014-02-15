require 'spec_helper'
require 'image'
require 'image_variant'

describe "images/index.html.erb" do
  before(:all) do
    @image = Image.new(
      title: 'Stub Title',
      alt_text: 'stub alt text',
      description: 'Stub description.',
      attribution: 'Stub Attribution',
      attribution_url: 'http://stub.attribution.tld/',
      license_url: 'http://stub.license.tld/'
    )
    @image.image_variants.new(
      height: 123, width: 234,
      format: 'gif',
      style: 'original',
      url: 'http://url.tld/stub.gif'
    )
    @image.save!
  end
  before(:each) do
    assign(:images, [@image, @image])
  end

  it "should present a gallery of the images" do
    @image.stub(:id).and_return(123)
    render
    assert_select 'div', class: 'gallery' do
      assert_select 'p', class: 'image', count: 2 do
        assert_select 'a', href: '/images/123', title: 'Stub Title' do
          assert_select('img',
            src: 'http://url.tld/stub.gif', height: '123', width: '234',
            alt: 'stub alt text', title: 'Stub Title'
            )
        end
      end
      assert_select 'span', class: 'tail'
    end
  end

end
