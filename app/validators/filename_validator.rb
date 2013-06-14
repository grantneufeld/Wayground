# encoding: utf-8
require 'active_model/validator'

# Validate that a given value is valid as a Wayground-style filename (with no extension).
# Used in ActiveModel/ActiveRecord field validations.
class FilenameValidator < ActiveModel::EachValidator
  FILENAME_REQUIREMENTS_MESSAGE = 'must only be lower-case letters, numbers, dashes and underscores'

  def validate_each(record, attribute, value)
    unless value && value.match(/\A[a-z0-9_\-]+\z/)
      record.errors[attribute] << (options[:message] || FILENAME_REQUIREMENTS_MESSAGE)
    end
  end
end
