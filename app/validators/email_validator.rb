# encoding: utf-8
require 'active_model/validator'

# Validate that a given value looks like a valid email address.
# Used in ActiveModel/ActiveRecord field validations.
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value && value.match(/\A\w[\w_\.\+\-]*@(?:\w[\w\-]*\.)+[a-z]{2,}\z/i)
      record.errors[attribute] << (options[:message] || 'is not a valid email address')
    end
  end
end
