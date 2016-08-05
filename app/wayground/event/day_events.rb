require 'time'

module Wayground
  module Event

    # A list of events for a specific day.
    # Includes the events that start on the day and multi-day events that started before the day.
    # Can determine which of those events carry over from the day to subsequent days.
    # :events must be events that start on :day.
    # :multiday must be events that started before :day and end on or after :day.
    class DayEvents
      attr_reader :events, :multiday

      def initialize(params)
        @day = params[:day]
        @events = params[:events] || []
        @multiday = params[:multiday] || []
      end

      def count
        @count ||= events.count + multiday.count
      end

      # Combines the events and multiday into one array, sorted by start_at time.
      def all
        (events + multiday).sort_by! do |event|
          time = event.start_at
          Time.new(2000, 1, 1, time.hour, time.min, time.sec)
        end
      end

      # The events (including multiday) from the day that carry over after the day.
      def carryover
        @carryover ||= determine_carryover_events + determine_carryover_multiday
      end

      private

      def determine_carryover_events
        events.select {|event| event.multi_day? }
      end

      def determine_carryover_multiday
        multiday.select {|event| event.end_at.to_date > @day }
      end

    end

  end
end

