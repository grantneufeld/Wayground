module Wayground
  module Event

    # Collection of events that are grouped into arrays by date.
    class EventsByDate
      attr_accessor :events_by_date

      delegate :[], to: :events_by_date

      def initialize(events = [])
        @events_by_date = group_events_by_date(events)
      end

      private

      def group_events_by_date(events)
        events_list = {}
        events.each do |event|
          date = event.start_at.to_date
          events_list[date] ||= []
          events_list[date] << event
        end
        events_list
      end
    end

  end
end
