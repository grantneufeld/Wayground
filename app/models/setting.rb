# System-wide settings.
class Setting < ActiveRecord::Base
  acts_as_authority_controlled :authority_area => 'Admin', :item_authority_flag_field => :always_private

  validates_presence_of :key

  default_scope { order('key') }

  # Key-indexed accessor for the values of settings.
  def self.[](key)
    setting = self.where(key: key).first
    setting ? setting.value : nil
  end

  # Key-indexed assignment for the values of settings.
  def self.[]=(key, value)
    setting = self.where(key: key).first
    # create the setting if it doesn’t already exist
    setting ||= self.new(key: key)
    setting.value = value.to_s
    setting.save!
  end

  # Key-indexed removal of settings.
  def self.destroy(key)
    setting = self.where(key: key).first
    setting.destroy if setting
  end

  # Set the values of settings, but don’t overwrite existing values if present.
  def self.set_defaults(key_value_pairs)
    key_value_pairs.each do |key, value|
      # if the setting has not been set yet, use the value provided
      self[key] ||= value.to_s
    end
  end
end
