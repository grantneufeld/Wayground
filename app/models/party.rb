# encoding: utf-8
require 'active_record'
require 'authority_controlled'
require 'make_db_array_field'
require 'colour_validator'
require 'filename_validator'
require 'http_url_validator'

# Represents a political party at a level of government.
class Party < ActiveRecord::Base
  acts_as_authority_controlled authority_area: 'Democracy', item_authority_flag_field: :always_viewable
  make_db_array_field :aliases
  attr_accessible :filename, :name, :aliases, :abbrev, :is_registered, :colour, :url, :description,
    :established_on, :registered_on, :ended_on

  belongs_to :level
  has_many :candidates

  validates :level_id, presence: true
  validates :filename, presence: true, filename: true, uniqueness: { scope: :level_id }
  validates :name, presence: true, uniqueness: { scope: :level_id }
  validates :abbrev, presence: true, uniqueness: { scope: :level_id }
  validates :colour, colour: true, allow_blank: true
  validates :url, http_url: true, allow_blank: true
  validate :validate_dates

  scope :by_name, -> { order(:name) }

  def validate_dates
    if registered_before_established?
      errors.add(:registered_on, 'must be on or after the date established on')
    end
    if established_or_registered_after_ended?
      errors.add(:ended_on, 'must be on or after the established and registered dates')
    end
  end
  def registered_before_established?
    registered_on? && established_on? && registered_on < established_on
  end
  def established_or_registered_after_ended?
    ended_on? && ((established_on? && ended_on < established_on) || (registered_on? && ended_on < registered_on))
  end

  def to_param
    filename
  end

end
