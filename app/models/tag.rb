# encoding: utf-8
require 'active_record'
require 'authority_controlled'

# Associate a tag with any item.
# Tags consist of lower-case, non-accented (ASCII) alpha-numeric characters.
# An optional title can present the tag with accents, punctuation, mixed-case, etc.
class Tag < ActiveRecord::Base
  acts_as_authority_controlled authority_area: 'Content', item_authority_flag_field: :always_viewable
  attr_accessible :tag, :title, :is_meta

  belongs_to :item, polymorphic: true
  belongs_to :user

  default_scope order(:tag)

  validates :item_type, :item_id, presence: true
  validates :tag, presence: true, uniqueness: { scope: [:item_type, :item_id] },
    format: { with: /\A[a-z0-9]+\z/ }
  validate :title_must_match_tag

  def title_must_match_tag
    if title.present? && (taggify_text(title) != tag)
      errors.add(:title, 'must match the Tag')
    end
  end

  def title=(value)
    @title = value.strip
    write_attribute(:title, @title)
    unless @title.blank?
      self.tag = taggify_text(@title)
    end
  end

  def taggify_text(text)
    text.parameterize.gsub(/[^a-z0-9]+/i, '')
  end

end
