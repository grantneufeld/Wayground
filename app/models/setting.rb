# System-wide settings.
class Setting < ApplicationRecord
  acts_as_authority_controlled authority_area: 'Admin', item_authority_flag_field: :always_private

  validates :key, presence: true

  default_scope { order('key') }

  # Key-indexed accessor for the values of settings.
  def self.[](key)
    setting = find_by(key: key)
    setting ? setting.value : nil
  end

  # Key-indexed assignment for the values of settings.
  def self.[]=(key, value)
    setting = find_by(key: key)
    # create the setting if it doesn’t already exist
    setting ||= new(key: key)
    setting.value = value.to_s
    setting.save!
  end

  # Key-indexed removal of settings.
  def self.destroy(key)
    setting = find_by(key: key)
    setting&.destroy
  end

  # Set the values of settings, but don’t overwrite existing values if present.
  def self.assign_missing_with_defaults(key_value_pairs)
    key_value_pairs.each do |key, value|
      # if the setting has not been set yet, use the value provided
      self[key] ||= value.to_s
    end
  end
end
