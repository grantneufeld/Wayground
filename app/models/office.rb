# encoding: utf-8
require 'active_record'
require 'authority_controlled'
require 'http_url_validator'

# Represents an office at a level of government (such as a councillor on a city council).
class Office < ActiveRecord::Base
  acts_as_authority_controlled authority_area: 'Democracy', item_authority_flag_field: :always_viewable
  attr_accessible :filename, :name, :title, :established_on, :ended_on, :description, :url

  belongs_to :level
  belongs_to :previous, class_name: 'Office'
  has_many :ballots

  validates :level_id, presence: true
  validates :filename, presence: true, uniqueness: { scope: :level_id }, format: { with: /\A[a-z0-9_\-]+\z/ }
  validates :name, presence: true
  validates :url, http_url: true, allow_blank: true
  validate :validate_dates

  def validate_dates
    if ended_on? && established_on? && ended_on < established_on
      errors.add(:ended_on, 'must be on or after the established date')
    end
  end

  scope :from_param, ->(param) do
    where(filename: param)
  end

  def to_param
    filename
  end

end
