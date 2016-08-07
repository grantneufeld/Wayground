# Tracks items generated from processing Sources.
# Items can be most models in the system, but must respond to the `name` method.
class SourcedItem < ApplicationRecord
  belongs_to :source
  belongs_to :item, polymorphic: true
  belongs_to :datastore

  before_validation :set_date, on: :create

  validates :source, :last_sourced_at, presence: true
  validate :validate_item_or_ignored
  validate :validate_dates

  # Set the last_sourced_at datetime if not set by the processor.
  def set_date
    self.last_sourced_at ||=
      if source.present?
        source.last_updated_at || Time.zone.now
      else
        Time.zone.now
      end
  end

  # the SourcedItem must be either ignored, or have an item
  def validate_item_or_ignored
    if !is_ignored && item.nil?
      errors.add(:item, 'an item must be set unless this sourced item is ignored')
    elsif is_ignored && item
      errors.add(:item, 'the item must not be set if this sourced item is ignored')
    end
  end

  # last_sourced_at should not be set in the future.
  def validate_dates
    have_source_and_dates = last_sourced_at? && source.present? && source.last_updated_at?
    if have_source_and_dates && (last_sourced_at.to_datetime > source.last_updated_at.to_datetime)
      errors.add(:last_sourced_at, 'must not be after the last update of the source')
    end
  end

  # Flag the item as having been modified locally.
  # This is to try to avoid losing local changes if the source updates the item.
  def modified_locally
    self.has_local_modifications = true
  end

  def modified_locally!
    self.has_local_modifications = true
    save!
  end
end
