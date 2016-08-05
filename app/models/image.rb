require 'active_record'
require 'http_url_validator'

# Meta data and collection container for a set of Image Variants.
class Image < ApplicationRecord
  acts_as_authority_controlled authority_area: 'Content', item_authority_flag_field: :always_viewable

  has_many :image_variants, dependent: :delete_all
  accepts_nested_attributes_for :image_variants, allow_destroy: true

  validates :attribution_url, http_url: true, allow_blank: true
  validates :license_url, http_url: true, allow_blank: true
  validates_associated :image_variants

  # prefer originals over other formats; then prefer larger over smaller dimensions
  def best_variant
    image_variants.originals.largest.first
  end
end
