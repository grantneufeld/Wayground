# encoding: utf-8

# System-wide settings.
class Setting < ActiveRecord::Base
  acts_as_authority_controlled :authority_area => 'Admin', :item_authority_flag_field => :always_private
  validates_presence_of :key

  # Key-indexed accessor for the values of settings.
  def self.[](k)
    setting = self.find_by_key(k)
    setting.nil? ? nil : setting.value
  end

  # Key-indexed assignment for the values of settings
  def self.[]=(k, v)
    setting = self.find_by_key(k)
    if setting.nil?
      setting = self.new(:key => k)
    end
    setting.value = v.to_s
    setting.save!
  end

  # Key-indexed removal of settings.
  def self.destroy(k)
    setting = self.find_by_key(k)
    setting.destroy unless setting.nil?
  end

  # Set the values of settings, but don’t overwrite existing values if present.
  # @hash[Hash] - a hash whose key-value pairs are to be converted to settings
  def self.set_defaults(hash)
    hash.each do |k,v|
      # do not set to default value if the setting already exists
      unless self[k]
        # the setting has not been set yet, so use the default value provided
        self[k] = v.to_s
      end
    end
  end
end
