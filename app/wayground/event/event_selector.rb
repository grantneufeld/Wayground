require 'event'

module Wayground
  module Event

    # Selecting events based on various constraints.
    class EventSelector
      attr_reader :range, :tag, :user

      # TODO: support pagination of events

      def initialize(parameters={})
        self.range = parameters[:r] || parameters[:range]
        self.tag = parameters[:tag]
        self.user = parameters[:user]
      end

      def range=(text)
        @range = text
        @range = 'upcoming' unless %w(all past upcoming).include?(@range)
      end

      def tag=(text)
        @tag = text
        @tag = nil if @tag.blank?
      end

      def user=(user)
        if user.is_a? User
          @user = user
        else
          @user = nil
        end
        @user
      end

      def events
        case range
        when 'all'
          selector = ::Event.all
        when 'past'
          selector = ::Event.past
        else
          selector = ::Event.upcoming
        end
        unless user && user.authority_for_area(::Event.authority_area, :can_approve)
          selector = selector.approved
        end
        selector = selector.tagged(tag) if tag
        selector
      end

      def title
        case range
        when 'all'
          title_text = 'Events'
        when 'past'
          title_text = 'Events: Past'
        else
          title_text = 'Events: Upcoming'
        end
        title_text += " (tagged “#{tag}”)" if tag
        title_text
      end

    end

  end
end
