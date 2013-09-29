# encoding: utf-8
require 'active_record'
require 'authority_controlled'
require 'http_url_validator'

# Represents an election at a level of government.
class Election < ActiveRecord::Base
  acts_as_authority_controlled authority_area: 'Democracy', item_authority_flag_field: :always_viewable
  attr_accessible :filename, :name, :start_on, :end_on, :url, :description

  belongs_to :level
  has_many :ballots

  validates :level_id, presence: true
  validates :filename, presence: true, uniqueness: { scope: :level_id }, format: { with: /\A[a-z0-9_\-]+\z/ }
  validates :name, presence: true, uniqueness: { scope: :level_id }
  validates :url, http_url: true, allow_blank: true
  validates :end_on, presence: true
  validate :validate_dates

  def validate_dates
    if end_on? && start_on? && end_on < start_on
      errors.add(:end_on, 'must be on or after the start date')
    end
  end

  scope :from_param, ->(param) do
    where(filename: param)
  end
  scope :order_by_date, -> { order(:end_on) }
  scope :upcoming, -> { where(['elections.end_on >= ?', Date.today]) }

  # get the current (next) election, or the last if there’s no next
  def self.current
    current = self.upcoming.order_by_date.first
    unless current
      current = self.order_by_date.last
    end
    current
  end

  # get the current (next) election, for a given level, or the last if there’s no next
  def self.current_for_level(level)
    current = self.where(level_id: level.id).upcoming.order_by_date.first
    unless current
      current = self.where(level_id: level.id).order_by_date.last
    end
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
