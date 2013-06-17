# encoding: utf-8
require 'pg_array_parser'

# Mapping a Postgres array column to an Array.
class DbArray
  include PgArrayParser

  def initialize(params=nil)
    self.array = []
    if params
      if params[:user]
        self.array = array_from_user_value(params[:user])
      elsif params[:db]
        self.array = parse_pg_array(params[:db])
      end
    end
  end

  attr_reader :array
  def array=(value)
    @array = array_from_user_value(value)
  end

  # Delegate unhandled methods to the array.
  # E.g., `[]` and `<<`.
  def method_missing(method, *args, &block)
    array.send(method, *args, &block)
  end

  # The array formatted for saving the database
  def to_db
    if @array.empty?
      ''
    else
      strings = @array.map { |element| string_for_pg_array(element) }
      # join with commas and wrap in angle-brackets
      "{#{strings.join(',')}}"
    end
  end

  def to_s
    array.join(', ')
  end

  def ==(value)
    if value.is_a? DbArray
      self.array == value.array
    else
      self.array == array_from_user_value(value)
    end
  end

  # protected

  def array_from_user_value(value)
    if value.is_a? String
      value.split(/ *, *|[\r\n]+/)
    elsif value.blank?
      []
    else
      value
    end
  end

  def string_for_pg_array(string)
    # strip quotes and backslashes, and wrap in quotes
    "\"#{string.gsub(/["\\]+/, '')}\""
  end

end
