require 'active_record'
require 'authority_controlled'
require 'http_url_validator'

# Represents a level of government (such as a municipality) or electable organization (such as a co-op board).
# May have a parent level (e.g., a municipality has a province/state as a parent,
# a province/state has a country as a parent).
class Level < ApplicationRecord
  acts_as_authority_controlled authority_area: 'Democracy', item_authority_flag_field: :always_viewable

  belongs_to :parent, class_name: 'Level'
  has_many :elections
  has_many :offices
  has_many :parties
  has_many :children, class_name: 'Level', foreign_key: 'parent_id'

  validates :filename, presence: true, uniqueness: true, format: { with: /\A[a-z0-9_\-]+\z/ }
  validates :name, presence: true
  validates :url, http_url: true, allow_blank: true

  scope :from_param, ->(param) { where(filename: param) }

  # Returns an array of parents for this level, starting with the top parent.
  def parent_chain
    if parent
      parent.parent_chain << parent
    else
      []
    end
  end

  def to_param
    filename
  end

  def descriptor
    name
  end

  def items_for_path
    [self]
  end
end
