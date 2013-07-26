# encoding: utf-8
require 'active_record'
require 'authority_controlled'

# Represents an individual person.
# May have multiple occurrences of being a candidate or elected representative.
class Person < ActiveRecord::Base
  acts_as_authority_controlled authority_area: 'Democracy', item_authority_flag_field: :always_viewable
  attr_accessible :filename, :fullname, :aliases, :bio

  belongs_to :user
  belongs_to :submitter, class_name: "User"
  has_many :candidacies, class_name: "Candidate"
  has_many :contacts, as: :item
  has_many :office_holders

  validates :user_id, uniqueness: true, allow_nil: true
  validates :filename, presence: true, uniqueness: true, format: { with: /\A[a-z0-9_\-]+\z/ }
  validates :fullname, presence: true

  scope :from_param, ->(param) do
    where(filename: param)
  end

  def to_param
    filename
  end

end
