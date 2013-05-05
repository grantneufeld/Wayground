# encoding: utf-8
require 'stringio'
require 'date' # for datetime parsing
require 'tzinfo' # for figuring out timezone offsets

module Wayground
  module Import

    # Read a stream of iCalendar format data.
    # Results come as an array of hashes.
    # Hash keys match the iCalendar labels (including being in ALL-CAPS) as strings.
    # Except for VEVENT and VTIMEZONE (which map to arrays of hashes),
    # each label maps to a further hash which has (along with any other
    # keys & values) a `:value` key that maps to the value for that label.
    # E.g.:
    #  BEGIN:VCALENDAR
    #  BEGIN:VEVENT
    #  UID:123@uid
    #  DTSTART:20010203T040506Z
    #  END:VEVENT
    #  X-CALNAME;PARAM=extra:Example Calendar
    #  END:VCALENDAR
    # becomes:
    #  [{
    #    'VEVENT' => [{'UID' => {:value => '123@uid'}, 'DTSTART' => {:value => <#DateTime>}}],
    #    'X-CALNAME' => {:value => 'Example Calendar', 'PARAM' => 'extra'}
    #  }]
    # This is a bit ugly, and would benefit from replacing the hashes with
    # some sort of class models. But, I’m being lazy about that since this
    # quick'n'dirty setup works for the limited use I’m putting it to.
    class IcalendarReader
      attr_accessor :io

      # Note that, for all the parse_<chunk_name> methods,
      # they are called right after their BEGIN line has been read,
      # so they never see their BEGIN line.

      # Read the ical_data as iCalendar-format data and parse it into calendar structures.
      def parse(ical_data)
        unless ical_data.is_a? String
          # ical_data must be readable (e.g., File, IO)
          ical_data = ical_data.read
        end
        # convert linebreaks to unix format (LF, '\n')
        ical_data.gsub!(/\r\n?/, "\n")
        # Turn the lines that were broken into multiple-lines back into single lines.
        # Remove any instance of a line-break followed by a space.
        ical_data.gsub!("\n ", '')
        # Now make the flattened ical_data into an IO object so we can parse it line by line.
        self.io = StringIO.new(ical_data)
        calendars = []
        while (line = io.gets)
          case line
          when /^BEGIN:VCALENDAR$/
            calendars << parse_vcalendar
          #else # ignore line; don't do anything until reaching a VCALENDAR part
          end
        end
        calendars
      end

      # VCALENDAR

      # Read the io as a calendar in iCalendar-format until reaching END:VCALENDAR.
      # Returns a hash of calendar data
      def parse_vcalendar
        calendar = {}
        events = []
        timezones = {}
        while (line = io.gets) && !(line =~ /^END:VCALENDAR$/)
          case line
          when /^BEGIN:VEVENT$/
            events << parse_vevent
          when /^BEGIN:VTIMEZONE$/
            timezone = parse_vtimezone
            timezones[timezone['TZID'][:value]] = timezone
          when /^BEGIN:(.+)$/
            # ignore an unsupported sub-element (such as VTODO)
            parse_unrecognized_element($1)
          when /^([^:;]+);([^:]+):(.+)$/
            # record any other mutlivalue calendar attributes
            calendar[$1] = parse_multivalue_line_chunks($2, $3)
          when /^([^:]+):(.+)$/
            # just record any other calendar attributes directly
            calendar[$1] = {value: clean_string($2)}
          #else # ignore any lines that are not formatted correctly.
          end
        end
        calendar['VEVENT'] = events if events.size > 0
        calendar['VTIMEZONE'] = timezones if timezones != {}
        calendar
      end

      # VEVENT

      # Parse a VEVENT block from an icalendar.
      def parse_vevent
        event = {}
        # read through until end of file or the END:VEVENT line.
        while (line = io.gets) && !(line =~ /^END:VEVENT$/)
          case line
          when /^BEGIN:(.+)$/
            # ignore an unsupported sub-element (such as VALARM)
            parse_unrecognized_element($1)
          when /^(DT(?:|START|END|STAMP)|LAST-MODIFIED|CREATED)[:;](.+)$/
            # special case for date-times
            event[$1] = {value: parse_date_value($2)}
          when /^SEQUENCE:([0-9]+)$/
            # special case for sequence numbers
            event['SEQUENCE'] = {value: ($1.to_i)}
          when /^([^:;]+);([^:]+):(.+)$/
            # record any other multivalue event attributes
            event[$1] = parse_multivalue_line_chunks($2, $3)
          when /^([^:]+):(.+)$/
            # just record any other event attributes directly
            event[$1] = {value: clean_string($2)}
          end
        end
        event
      end

      # VTIMEZONE

      # Parse a VTIMEZONE block from an icalendar.
      def parse_vtimezone
        timezone = {}
        # read through until end of file or the END:VTIMEZONE line.
        while (line = io.gets) && !(line =~ /^END:VTIMEZONE$/)
          case line
          when /^BEGIN:(.+)$/
            # handle a sub-element - typically STANDARD or DAYLIGHT
            timezone[$1] = parse_vtimezone_element($1)
          when /^([^:]+):(.+)$/
            # just record any other timezone attributes directly
            timezone[$1] = {value: clean_string($2)}
          end
        end
        timezone
      end

      # Parse a sub-element within a VTIMEZONE.
      # Typically a STANDARD or DAYLIGHT element defining when a timezone
      # is in standard time, or daylight savings time.
      def parse_vtimezone_element(name)
        element = {}
        # read through until end of file or the END:`ELEMENT_NAME` line.
        # assume there are no sub-elements
        while (line = io.gets) && !(line =~ /^END:#{name}$/)
          # just record any timezone element attributes directly
          if (match = line.match(/^([^:]+):(.+)$/))
            element[match[1]] = {value: clean_string(match[2])}
          end
        end
        element
      end

      # IGNORED / UNRECOGNIZED

      # Handle an unrecognized sub-element by ignoring it.
      def parse_unrecognized_element(name)
        while (line = io.gets) && !(line =~ /^END:#{name}$/)
          # don't do anything with the element's data
        end
      end

      # MISC HELPERS

      # Convert slash-escaped characters to the actual characters.
      def clean_string(str)
        str.gsub("\\n", "\n").gsub("\\t", "\t").gsub(/\\(.)/, '\1')
      end

      # Convert the iCalendar datetime string to a DateTime.
      def parse_date_value(ical_datetime, params = {})
        # check if the date is multipart (e.g., "TZID=Some/Timezone:20010203T040506")
        time_parts = ical_datetime.match /(?<params>.+):(?<time>.+)/
        if time_parts
          # Split out the time value and the other parameters
          ical_datetime = time_parts[:time]
          param_strs = time_parts[:params].split(';')
          param_strs.each do |param_str|
            param_parts = param_str.match(/^(?<key>[^=]+)=(?<value>.+)$/)
            params[param_parts[:key]] = param_parts[:value]
          end
        end
        # Thankfully, DateTime’s built-in string processor understands the format
        # used by iCalendar for writing date strings. (although not the timezone part)
        date = DateTime.parse ical_datetime
        # date defaults to UTC. Apply a timezone if one is specified in TZID.
        if params['TZID']
          tz = TZInfo::Timezone.get(params['TZID'])
          if tz
            # Get the timezone offset as a Rational number (UTC difference over day).
            utc_offset_rational = Rational(
              #tz.current_period.offset.utc_total_offset, # difference from UTC in seconds
              tz.period_for_utc(date).utc_total_offset, # difference from UTC in seconds
              86400 # the number of seconds in a day (24*60*60)
            )
            # convert to the specified timezone
            date = DateTime.new(
              date.year, date.month, date.day, date.hour, date.minute, date.second,
              utc_offset_rational
            )
          end
        end
        date
      end

      # This is for handling iCalendar lines that come in the form of:
      # “FIELD;KEY=keyedvalue;ANOTHER-KEY=anothervalue:value”
      # first: The “KEY=keyedvalue” part.
      # second: The “value” part.
      def parse_multivalue_line_chunks(first, second)
        result = {:value => clean_string(second)}
        pairs = first.split(';')
        pairs.each do |pair|
          match = pair.match /^(?<key>[^=]+)=(?<value>.*)/
          result[match[:key]] = match[:value]
        end
        result
      end

    end

  end
end
