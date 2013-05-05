# encoding: utf-8
require 'stringio'
require 'import/icalendar_date'

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
    #    'VEVENT' => [{'UID' => {value: '123@uid'}, 'DTSTART' => {value: <#DateTime>}}],
    #    'X-CALNAME' => {value: 'Example Calendar', 'PARAM' => 'extra'}
    #  }]
    # This is a bit ugly, and would benefit from replacing the hashes with
    # some sort of class models. But, I’m being lazy about that since this
    # quick'n'dirty setup works for the limited use I’m putting it to.
    class IcalendarReader
      attr_reader :io, :line_buffer

      # accepts a hash with either:
      # :io => an IO object for the iCalendar data
      # :data => a String containing the iCalendar data
      def initialize(params={})
        @io = params[:io] || StringIO.new(params[:data])
        @line_buffer = nil
      end

      # Note that, for all the parse_<chunk_name> methods,
      # they are called right after their BEGIN line has been read,
      # so they never see their BEGIN line.

      # Read the from the io as iCalendar-format data and parse it into calendar structures.
      def parse
        calendars = []
        line = get_next_line
        while line
          case line
          when /^BEGIN:VCALENDAR$/
            calendars << parse_vcalendar
          #else # ignore line; don't do anything until reaching a VCALENDAR part
          end
          line = get_next_line
        end
        calendars
      end

      # VCALENDAR

      # Read the io as a calendar in iCalendar-format until reaching END:VCALENDAR.
      # Returns a hash of calendar data
      def parse_vcalendar
        calendar = {}
        line = get_next_line
        while line && !(line =~ /^END:VCALENDAR$/)
          line_within_vcalendar(line, calendar)
          line = get_next_line
        end
        calendar
      end

      def line_within_vcalendar(line, calendar)
        case line
        when /^BEGIN:VEVENT$/
          calendar['VEVENT'] ||= []
          calendar['VEVENT'] << parse_vevent
        when /^BEGIN:VTIMEZONE$/
          calendar['VTIMEZONE'] ||= {}
          timezone = parse_vtimezone
          timezone_id = timezone['TZID'][:value]
          calendar['VTIMEZONE'][timezone_id] = timezone
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

      # VEVENT

      # Parse a VEVENT block from an icalendar.
      def parse_vevent
        event = {}
        # read through until end of file or the END:VEVENT line.
        line = get_next_line
        while line && !(line =~ /^END:VEVENT$/)
          line_within_vevent(line, event)
          line = get_next_line
        end
        event
      end

      def line_within_vevent(line, event)
        case line
        when /^BEGIN:(.+)$/
          # ignore an unsupported sub-element (such as VALARM)
          parse_unrecognized_element($1)
        when /^(DT(?:|START|END|STAMP)|LAST-MODIFIED|CREATED)[:;](.+)$/
          # special case for date-times
          event[$1] = {value: IcalendarDate.new($2).to_datetime}
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

      # VTIMEZONE

      # Parse a VTIMEZONE block from an icalendar.
      def parse_vtimezone
        timezone = {}
        # read through until end of file or the END:VTIMEZONE line.
        line = get_next_line
        while line && !(line =~ /^END:VTIMEZONE$/)
          line_within_vtimezone(line, timezone)
          line = get_next_line
        end
        timezone
      end

      def line_within_vtimezone(line, timezone)
        case line
        when /^BEGIN:(.+)$/
          # handle a sub-element - typically STANDARD or DAYLIGHT
          timezone[$1] = parse_vtimezone_element($1)
        when /^([^:]+):(.+)$/
          # just record any other timezone attributes directly
          timezone[$1] = {value: clean_string($2)}
        end
      end

      # Parse a sub-element within a VTIMEZONE.
      # Typically a STANDARD or DAYLIGHT element defining when a timezone
      # is in standard time, or daylight savings time.
      def parse_vtimezone_element(name)
        element = {}
        # read through until end of file or the END:`ELEMENT_NAME` line.
        # assume there are no sub-elements
        while (line = get_next_line) && !(line =~ /^END:#{name}$/)
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
        while (line = get_next_line) && !(line =~ /^END:#{name}$/)
          # don't do anything with the element's data
        end
      end

      # IO access

      # Read a line of iCalendar data.
      # Merges lines that have been split into multiple lines back to a single line.
      # Strips line breaks.
      def get_next_line
        line = @line_buffer || io.gets
        @line_buffer = nil
        # strip trailing line-breaks
        if line
          line.sub!(/[\r\n]+\z/, '')
        end
        if line.present?
          line = merge_split_lines(line)
        end
        line
      end

      protected

      def merge_split_lines(line)
        @line_buffer = io.gets
        while @line_buffer && @line_buffer.match(/\A /)
          # the next line is a continuation line, so unwrap it
          line += @line_buffer.sub(/[\r\n]+/, '').sub(/\A /, '')
          @line_buffer = io.gets
        end
        line
      end

      public

      # MISC HELPERS
      # TODO: move IcalendarReader helpers to separate class

      # Convert slash-escaped characters to the actual characters.
      def clean_string(str)
        # TODO: there should be a standard “unescape” method for strings we can use here instead
        str.gsub("\\n", "\n").gsub("\\t", "\t").gsub(/\\(.)/, '\1')
      end

      # This is for handling iCalendar lines that come in the form of:
      # “FIELD;KEY=keyedvalue;ANOTHER-KEY=anothervalue:value”
      # first: The “KEY=keyedvalue” part.
      # second: The “value” part.
      def parse_multivalue_line_chunks(first, second)
        result = {value: clean_string(second)}
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
