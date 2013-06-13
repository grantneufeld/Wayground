# encoding: utf-8
require 'active_model/validator'

# Validate that a given value is a 3 or 6 digit hexadecimal colour (with hash symbol),
# or a lower-case CSS colour name.
# Used in ActiveModel/ActiveRecord field validations.
class ColourValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value && value.match(/\A\#[0-9a-f][0-9a-f][0-9a-f]([0-9a-f][0-9a-f][0-9a-f])?\z/i) || %w(aqua black blue cyan fuchsia gray green lime magenta maroon navy olive purple red silver teal white yellow).include?(value)
      record.errors[attribute] << (options[:message] || 'is not a recognized colour name or hex code')
    end
  end
end
