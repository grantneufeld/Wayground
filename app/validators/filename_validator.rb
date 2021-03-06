require 'active_model/validator'

# Validate that a given value is valid as a Wayground-style filename (with no extension).
# Used in ActiveModel/ActiveRecord field validations.
class FilenameValidator < ActiveModel::EachValidator
  FILENAME_REQUIREMENTS_MESSAGE = 'must only be lower-case letters, numbers, dashes and underscores'.freeze

  def validate_each(record, attribute, value)
    valid_filename = value && value.match(/\A[a-z0-9_\-]+\z/)
    record.errors[attribute] << (options[:message] || FILENAME_REQUIREMENTS_MESSAGE) unless valid_filename
  end
end
