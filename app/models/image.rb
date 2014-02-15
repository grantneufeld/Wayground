require 'active_record'
require 'http_url_validator'

# Meta data and collection container for a set of Image Variants.
class Image < ActiveRecord::Base
  acts_as_authority_controlled authority_area: 'Content', item_authority_flag_field: :always_viewable
  attr_accessible(
    :title, :alt_text, :description, :attribution, :attribution_url, :license_url,
    :image_variants_attributes
  )

  has_many :image_variants, dependent: :delete_all
  accepts_nested_attributes_for :image_variants,
    reject_if: lambda {|variant| variant[:url].blank? || variant[:style].blank? }, allow_destroy: true

  validates :attribution_url, http_url: true, allow_blank: true
  validates :license_url, http_url: true, allow_blank: true

  # prefer originals over other formats; then prefer larger over smaller dimensions
  def get_best_variant
    image_variants.originals.largest.first
  end

end
