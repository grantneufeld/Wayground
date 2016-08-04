require 'active_record'
require 'authority_controlled'
require 'email_validator'
require 'http_url_validator'

# Contact information for an item (such as a Person or Candidate).
class Contact < ActiveRecord::Base
  acts_as_authority_controlled authority_area: 'Democracy', item_authority_flag_field: :always_viewable

  belongs_to :item, polymorphic: true

  validates :item_type, presence: true
  validates :item_id, presence: true
  validates :email, email: true, allow_blank: true
  validates :twitter, allow_blank: true,
    format: { with: /\A[a-z0-9_\-]+\z/i, message: 'invalid Twitter id' }
  validates :url, http_url: true, allow_blank: true

  scope :only_public, -> { where(is_public: true) }
  default_scope { order(:position) }

  # TODO: parse phone numbers to make more consistent format
  # TODO: auto-fill country, province and city with site defaults

  def descriptor
    name || organization || "#{item.descriptor} contact #{position}"
  end

  def items_for_path
    item.items_for_path << self
  end

end
