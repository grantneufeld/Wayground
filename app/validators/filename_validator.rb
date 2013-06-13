# encoding: utf-8
require 'active_model/validator'

# Validate that a given value is valid as a Wayground-style filename.
# Used in ActiveModel/ActiveRecord field validations.
class FilenameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value && value.match(/\A[a-z0-9_\-]+\z/)
      record.errors[attribute] << (options[:message] || 'is not a valid filename')
    end
  end
end
