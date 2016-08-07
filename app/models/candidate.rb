require 'active_record'
require 'authority_controlled'

# Represents the candidacy of a Person on a Ballot.
class Candidate < ApplicationRecord
  acts_as_authority_controlled authority_area: 'Democracy', item_authority_flag_field: :always_viewable

  belongs_to :ballot
  belongs_to :person
  belongs_to :party
  belongs_to :submitter, class_name: "User"
  has_many :contacts, as: :item
  has_many :external_links, as: :item

  validates :ballot_id, presence: true
  validates :person_id, uniqueness: { scope: :ballot_id }
  validates :name,      uniqueness: { scope: :ballot_id }
  validates :filename,  uniqueness: { scope: :ballot_id }

  scope :by_name, -> { order(:name) }
  scope :by_vote_count, -> { order('vote_count DESC, name') }
  scope :from_param, ->(param) do
    where(filename: param)
  end
  scope :running, -> { where('quit_on IS NULL OR quit_on > NOW()') }
  scope :not_running, -> { where('quit_on IS NOT NULL AND quit_on <= NOW()') }

  default_scope { by_name }

  def to_param
    filename
  end

  def descriptor
    name
  end

  def items_for_path
    ballot.items_for_path << self
  end

end
