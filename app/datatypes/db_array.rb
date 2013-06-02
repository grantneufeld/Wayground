# encoding: utf-8
require 'pg_array_parser'

# Mapping a Postgres array column to an Array.
class DbArray
  include PgArrayParser

  def initialize(in_array=[])
    self.array = in_array
  end

  # Delegate unhandled methods to the array.
  # E.g., `[]` and `<<`.
  def method_missing(method, *args, &block)
    @array.send(method, *args, &block)
  end

  def array=(value)
    @array = array_from_value(value)
  end

  def array_from_value(value)
    if value.is_a? String
      parse_pg_array(value)
    elsif value.blank?
      []
    else
      value
    end
  end

  attr_reader :array

  # The array formatted for saving the database
  def to_s
    if @array.empty?
      ''
    else
      strings = @array.map { |element| string_for_pg_array(element) }
      # join with commas and wrap in angle-brackets
      "{#{strings.join(',')}}"
    end
  end

  def ==(value)
    if value.is_a? DbArray
      self.array == value.array
    else
      self.array == array_from_value(value)
    end
  end

  # protected

  def string_for_pg_array(string)
    # strip quotes and backslashes, and wrap in quotes
    "\"#{string.gsub(/["\\]+/, '')}\""
  end

end
