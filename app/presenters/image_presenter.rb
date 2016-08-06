require_relative 'html_presenter'

# Meta elements to go in the head element.
class ImagePresenter < HtmlPresenter
  attr_reader :view, :image, :image_variant, :height, :width

  def initialize(view: nil, image: nil, image_variant: nil, height: nil, width: nil) # params = {})
    @view = view
    @image = image
    @image_variant = image_variant
    @height = height
    @width = width
  end

  def present
    variant = image_variant
    html_tag(
      :img,
      src: variant.url,
      height: height || variant.height, width: width || variant.width,
      alt: alt_text, title: title
    )
  end

  def image_variant
    @image_variant ||= image.best_variant
  end

  def alt_text
    image ? image.alt_text : nil
  end

  def title
    image ? image.title : nil
  end
end
