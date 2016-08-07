require 'active_record'
require 'authority_controlled'

# Represents an individual person.
# May have multiple occurrences of being a candidate or elected representative.
class Person < ApplicationRecord
  acts_as_authority_controlled authority_area: 'Democracy', item_authority_flag_field: :always_viewable

  belongs_to :user
  belongs_to :submitter, class_name: 'User'
  has_many :candidacies, class_name: 'Candidate'
  has_many :contacts, as: :item
  has_many :office_holders

  validates :user_id, uniqueness: true, allow_nil: true
  validates :filename, presence: true, uniqueness: true, format: { with: /\A[a-z0-9_\-]+\z/ }
  validates :fullname, presence: true

  scope :from_param, ->(param) { where(filename: param) }

  def to_param
    filename
  end

  def aliases_string
    aliases.join(', ') if aliases
  end

  def aliases_string=(value)
    self.aliases = value.split(/ *, */)
  end

  def descriptor
    fullname
  end

  def items_for_path
    [self]
  end
end
