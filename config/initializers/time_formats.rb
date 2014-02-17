tzoff_secs = Time.current.gmt_offset
if tzoff_secs < 0
  tzoff_negative = true
  tzoff_secs *= -1
else
  tzoff_negative = false
end
tzoff_minutes = tzoff_secs / 60
tzoff_hours = tzoff_minutes / 60
tzoff_minutes = tzoff_minutes % 60

Time::DATE_FORMATS[:db] = "%Y-%m-%d %H:%M:%S"
Time::DATE_FORMATS[:time_date] = "%-l:%M %p on %A, %B %-e, %Y" # 3:45 PM on Friday, March 1, 2013
Time::DATE_FORMATS[:simple_date] = "%B %-e, %Y" # April 1, 2005
Time::DATE_FORMATS[:form_field_date] = "%B %-e, %Y" # June 2, 2011
Time::DATE_FORMATS[:form_field_datetime] = "%B %-e, %Y at %-l:%M %p" # May 5, 2018 at 4:56 PM
Time::DATE_FORMATS[:plain_date] = "%A, %B %-e, %Y" # Friday, March 1, 2013
Time::DATE_FORMATS[:plain_time] = "%-l:%M%P" # 3:45pm
Time::DATE_FORMATS[:plain_datetime] = "%A, %B %-e, %Y at %-l:%M%P" # Friday, March 1, 2013 at 3:45pm
Time::DATE_FORMATS[:http_header] = "%a, %d %b %Y %H:%M:%S %Z"
Time::DATE_FORMATS[:icalendar_date] = "%Y%m%d"
Time::DATE_FORMATS[:icalendar] = "%Y%m%dT%H%M%S"
Time::DATE_FORMATS[:icalendar_utc] = "%Y%m%dT%H%M%SZ"
Time::DATE_FORMATS[:microformat] = "%Y-%m-%dT%H:%M:%S%:z" # 2012-05-02T13:45:00-06:00
Time::DATE_FORMATS[:microformat_date] = "%Y-%m-%d"
Time::DATE_FORMATS[:microformat_time] = "%H:%M:%S%:z" # 13:45:00-06:00
Time::DATE_FORMATS[:compact_date] = "%b %-e, %Y" # Oct 2, 2003
Time::DATE_FORMATS[:compact_datetime] = "%b %-e, %Y, %-l:%M:%S%p" # Oct 2, 2003, 5:43:00PM

class ActiveSupport::TimeWithZone < Object
  # Return a string representation of the date & time in iCalendar format,
  # with the timezone specified. This includes the leading ‘:’ or ‘;’.
  # Should immediately follow an iCalendar field name (such as “DTSTART” — don’t include colon or other separateor after).
  def icalendar_with_zone
    if utc?
      ":#{to_s(:icalendar_utc)}"
    else
      ";TZID=#{ActiveSupport::TimeZone::MAPPING[time_zone.name]}:#{to_s(:icalendar)}"
    end
  end
end
