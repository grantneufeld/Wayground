# encoding: utf-8
require 'active_record'
require 'authority_controlled'
require 'http_url_validator'

# Represents an election at a level of government.
class Ballot < ActiveRecord::Base
  acts_as_authority_controlled authority_area: 'Democracy', item_authority_flag_field: :always_viewable
  attr_accessible :position, :section, :term_start_on, :term_end_on, :is_byelection, :url, :description

  belongs_to :election
  belongs_to :office
  has_many :candidates
  has_many :external_links, as: :item

  validates :election_id, presence: true
  # only one ballot for a given office in a given election
  validates :office_id, presence: true, uniqueness: { scope: :election_id }
  validates :url, http_url: true, allow_blank: true
  validate :validate_dates
  validate :validate_office_level

  default_scope { order(:position) }

  def validate_dates
    if term_end_on? && term_start_on? && term_end_on < term_start_on
      errors.add(:term_end_on, 'must be on or after the term start date')
    end
  end

  def validate_office_level
    if office && election
      unless office.level == election.level
        errors.add(:office, "must be for the same level of government as the election")
      end
    end
  end

  def to_param
    if office
      office.filename
    else
      nil
    end
  end

  def running_for
    title = office.title
    area = office.name
    if title == area
      title
    else
      "#{title} for #{area}"
    end
  end

  def descriptor
    office.name
  end

  def items_for_path
    election.items_for_path << self
  end

end
