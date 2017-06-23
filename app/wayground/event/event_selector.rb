require 'event'

module Wayground
  module Event

    # Selecting events based on various constraints.
    class EventSelector
      attr_reader :range, :tag, :user

      # TODO: support pagination of events

      def initialize(range: nil, tag: nil, user: nil)
        self.range = range
        self.tag = tag
        self.user = user
      end

      def range=(text)
        @range = text
        @range = 'upcoming' unless %w[all past upcoming].include?(@range)
      end

      def tag=(text)
        @tag = text
        @tag = nil if @tag.blank?
      end

      def user=(user)
        @user = user.is_a?(User) ? user : nil
      end

      def events
        selector =
          case range
          when 'all'
            ::Event.all
          when 'past'
            ::Event.past
          else
            ::Event.upcoming
          end
        unless user && user.authority_for_area(::Event.authority_area, :can_approve)
          selector = selector.approved
        end
        selector = selector.tagged(tag) if tag
        selector
      end

      def title
        title_text =
          case range
          when 'all'
            'Events'
          when 'past'
            'Events: Past'
          else
            'Events: Upcoming'
          end
        title_text += " (tagged “#{tag}”)" if tag
        title_text
      end
    end

  end
end
