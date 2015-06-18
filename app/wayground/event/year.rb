require 'date'
require 'event'

module Wayground
  module Event

    # Information about Events for a given year.
    class Year
      attr_reader :year

      def initialize(params)
        @year = params[:year]
      end

      # Returns a hash, indexed on the month numbers, with the count of events occuring in the month.
      def monthly_event_counts
        event_counts = {}
        (1..12).each do |month|
          month_start = ::Date.new(year, month, 1)
          month_end = month_start.next_month - 1.day
          event_counts[month] = ::Event.approved.falls_between_dates(month_start, month_end).count
        end
        event_counts
      end

    end

  end
end
