# encoding: utf-8
require 'active_record'
require 'authority_controlled'
require 'http_url_validator'

# Represents a level of government (such as a municipality) or electable organization (such as a co-op board).
# May have a parent level (e.g., a municipality has a province/state as a parent, a province/state has a country as a parent).
class Level < ActiveRecord::Base
  acts_as_authority_controlled authority_area: 'Democracy', item_authority_flag_field: :always_viewable
  attr_accessible :filename, :name, :url

  belongs_to :parent, class_name: 'Level'
  has_many :elections
  has_many :offices

  validates :filename, presence: true, uniqueness: true, format: { with: /\A[a-z0-9_\-]+\z/ }
  validates :name, presence: true
  validates :url, http_url: true, allow_blank: true

  scope :from_param, ->(param) do
    where(filename: param)
  end

  def to_param
    filename
  end

end
