# encoding: utf-8
require 'active_model/validator'

# Validate that a given value is a valid http/https url format.
# Used in ActiveModel/ActiveRecord field validations.
class HttpUrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\Ahttps?:\/\/[A-Za-z0-9:\.\-]+(\/[\w%~_\?=&\.\#\/\-]*)?\z/
      record.errors[attribute] << (options[:message] || 'must be a valid weblink (including ‘http://’)')
    end
  end
end
