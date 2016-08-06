require 'date' # for datetime parsing
require 'tzinfo' # for figuring out timezone offsets

module Wayground
  module Import

    # hold the values associated with an iCalendar date/time
    class IcalendarDate
      def initialize(ical_datetime)
        parsed_parts = parse_ical_datetime_string(ical_datetime)
        @datetime = parsed_parts.delete(:datetime)
        timezone_id = parsed_parts.delete('TZID')
        @timezone = determine_timezone(timezone_id) if timezone_id
        @extras = parsed_parts
      end

      # Convert the iCalendar datetime string to a DateTime.
      def to_datetime
        # Thankfully, DateTime’s built-in string processor understands the format
        # used by iCalendar for writing date strings. (although not the timezone part)
        datetime = DateTime.parse(@datetime)
        # defaults to UTC. Apply a timezone if one is specified in TZID.
        adjust_for_timezone(datetime)
      end

      protected

      def parse_ical_datetime_string(ical_datetime)
        time_parts = ical_datetime.match(/(?<params>.+):(?<datetime>.+)/)
        if time_parts
          parse_time_parts(time_parts)
        else
          { datetime: ical_datetime }
        end
      end

      # split out the time value and other parts of the time, such as the 'TZID'
      def parse_time_parts(time_parts)
        parsed_parts = { datetime: time_parts[:datetime] }
        param_strs = time_parts[:params].split(';')
        param_strs.each do |param_str|
          param_parts = param_str.match(/^(?<key>[^=]+)=(?<value>.+)$/)
          parsed_parts[param_parts[:key]] = param_parts[:value]
        end
        parsed_parts
      end

      def adjust_for_timezone(date)
        if @timezone
          # convert to the specified timezone
          DateTime.new(
            date.year, date.month, date.day, date.hour, date.minute, date.second,
            utc_offset_rational(date)
          )
        else
          date
        end
      end

      # Get the timezone offset as a Rational number (UTC difference over day).
      def utc_offset_rational(date)
        Rational(
          @timezone.period_for_utc(date).utc_total_offset, # difference from UTC in seconds
          86_400 # the number of seconds in a day (24*60*60)
        )
      end

      def determine_timezone(timezone_id = nil)
        @timezone ||= TZInfo::Timezone.get(timezone_id)
      rescue TZInfo::InvalidTimezoneIdentifier
        nil
      end
    end

  end
end
