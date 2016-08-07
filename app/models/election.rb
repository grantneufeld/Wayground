require 'active_record'
require 'authority_controlled'
require 'http_url_validator'

# Represents an election at a level of government.
class Election < ApplicationRecord
  acts_as_authority_controlled authority_area: 'Democracy', item_authority_flag_field: :always_viewable

  belongs_to :level
  has_many :ballots

  validates :level_id, presence: true
  validates(
    :filename,
    presence: true, uniqueness: { scope: :level_id },
    format: {
      with: /\A[a-z0-9_\-]+\z/, message: 'must be only lowercase letters, numbers, dashes, and underscores'
    }
  )
  validates :name, presence: true, uniqueness: { scope: :level_id }
  validates :url, http_url: true, allow_blank: true
  validates :end_on, presence: true
  validate :validate_dates

  def validate_dates
    errors.add(:end_on, 'must be on or after the start date') if end_on? && start_on? && end_on < start_on
  end

  scope :from_param, ->(param) { where(filename: param) }
  scope :order_by_date, -> { order(:end_on) }
  scope :upcoming, -> { where(['elections.end_on >= ?', Time.zone.today.to_date]) }

  # get the current (next) election, or the last if there’s no next
  def self.current
    current = upcoming.order_by_date.first
    current = order_by_date.last unless current
    current
  end

  # get the current (next) election, for a given level, or the last if there’s no next
  def self.current_for_level(level)
    current = where(level_id: level.id).upcoming.order_by_date.first
    current = where(level_id: level.id).order_by_date.last unless current
    current
  end

  def to_param
    filename
  end

  def descriptor
    name
  end

  def items_for_path
    level.items_for_path << self
  end
end
