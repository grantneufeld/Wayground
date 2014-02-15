require 'active_record'
require 'image'
require 'http_url_validator'

# A specific instance (“variant”) of an image.
class ImageVariant < ActiveRecord::Base
  attr_accessible :height, :width, :format, :style, :url

  belongs_to :image

  # can’t require the image to be set before initial save when using nested attribute forms
  validates :image_id, presence: true, on: :update
  validates :height, numericality: {only_integer: true, greater_than: 0}, allow_nil: true
  validates :width, numericality: {only_integer: true, greater_than: 0}, allow_nil: true
  validates :format, presence: true
  validates :style, presence: true # original scaled preview? square?
  validates :url, presence: true, http_url: true

  # this originals scope is a bit of a hack that relies on 'original' being alphabetically before 'scaled'
  # it could break when other styles are introduced
  scope :originals, -> { order(:style) }
  # this makes the big assumption that the width is more important than the height
  scope :largest, -> { order('image_variants.width DESC, image_variants.height DESC') }
end
