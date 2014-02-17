# Tracks items generated from processing Sources.
# Items can be most models in the system, but must respond to the `name` method.
class SourcedItem < ActiveRecord::Base
  attr_accessible :source_identifier, :last_sourced_at, :has_local_modifications

  belongs_to :source
  belongs_to :item, :polymorphic => true
  belongs_to :datastore

  before_validation :set_date, :on => :create

  validates_presence_of :source, :item, :last_sourced_at
  validate :validate_dates

  # Set the last_sourced_at datetime if not set by the processor.
  def set_date
    self.last_sourced_at ||= Time.now
  end

  # last_sourced_at should not be set in the future.
  def validate_dates
    if (
      last_sourced_at? && source.present? && source.last_updated_at? &&
      (last_sourced_at.to_datetime > source.last_updated_at.to_datetime)
    )
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
    self.save!
  end

end
