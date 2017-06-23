require 'active_model/validator'

# Validate that a given value is a valid http/https url format.
# Used in ActiveModel/ActiveRecord field validations.
class HttpUrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    valid_url = value&.match?(%r{\Ahttps?://[A-Za-z0-9:\.\-]+(/[\w\+\:%~_\@\?=&\.\#/\-]*)?\z})
    unless valid_url
      message = options[:message] || 'must be a valid weblink (including ‘http://’)'
      record.errors[attribute] << message
    end
  end
end
