require 'active_record'
require 'authority_controlled'
require 'http_url_validator'

# Represents an office at a level of government (such as a councillor on a city council).
class Office < ApplicationRecord
  acts_as_authority_controlled authority_area: 'Democracy', item_authority_flag_field: :always_viewable

  belongs_to :level
  belongs_to :previous, class_name: 'Office'
  has_many :ballots
  has_many :office_holders
  has_many :external_links, as: :item

  validates :level_id, presence: true
  validates :filename, presence: true, uniqueness: { scope: :level_id }, format: { with: /\A[a-z0-9_\-]+\z/ }
  validates :name, presence: true
  validates :url, http_url: true, allow_blank: true
  validate :validate_dates

  def validate_dates
    end_before_established = ended_on? && established_on? && ended_on < established_on
    errors.add(:ended_on, 'must be on or after the established date') if end_before_established
  end

  scope :active_on, lambda { |active_date|
    where(
      '(established_on IS NULL OR established_on <= :active_date)' \
      ' AND (ended_on IS NULL OR ended_on >= :active_date)',
      active_date: active_date
    )
  }

  scope :from_param, ->(param) { where(filename: param) }

  def to_param
    filename
  end

  def descriptor
    name
  end
end
