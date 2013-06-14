# encoding: utf-8
require 'active_record'
require 'authority_controlled'
require 'filename_validator'

# Represents the candidacy of a Person on a Ballot.
class Candidate < ActiveRecord::Base
  acts_as_authority_controlled authority_area: 'Democracy', item_authority_flag_field: :always_viewable
  attr_accessible :filename, :name,
    :is_rumoured, :is_confirmed, :is_incumbent, :is_leader, :is_acclaimed, :is_elected,
    :announced_on, :quit_on, :vote_count

  belongs_to :ballot
  belongs_to :person
  belongs_to :party
  belongs_to :submitter, class_name: "User"
  has_many :contacts, as: :item

  validates :ballot_id, presence: true
  validates :person_id, presence: true, uniqueness: { scope: :ballot_id }
  validates :filename, presence: true, filename: true, uniqueness: { scope: :ballot_id }
  validates :name, presence: true, format: { with: /^[^\r\n\t<>&]+$/ }, uniqueness: { scope: :ballot_id }
  validate :validate_dates

  def validate_dates
    if quit_on? && announced_on? && quit_on < announced_on
      errors.add(:quit_on, 'must be on or after the date candidacy was announced on')
    end
  end

  scope :by_name, -> { order(:name) }
  scope :by_vote_count, -> { order('vote_count DESC, name') }

  def to_param
    filename
  end

end
