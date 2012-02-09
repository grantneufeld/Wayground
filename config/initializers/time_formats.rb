# encoding: utf-8

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
Time::DATE_FORMATS[:time_date] = "%l:%M:%S %p on %A, %B %d, %Y"
Time::DATE_FORMATS[:simple_date] = "%B %e, %Y"
Time::DATE_FORMATS[:form_field] = "%B %e, %Y at %l:%M %p"
Time::DATE_FORMATS[:plain_date] = "%A, %B %e, %Y"
Time::DATE_FORMATS[:plain_time] = "%l:%M %p" # 3:45 pm
Time::DATE_FORMATS[:plain_datetime] = "%A, %B %e, %Y at %l:%M %p"
Time::DATE_FORMATS[:http_header] = "%a, %d %b %Y %H:%M:%S %Z"
Time::DATE_FORMATS[:icalendar] = "%Y%m%dT%H%M%S"
Time::DATE_FORMATS[:icalendar_utc] = "%Y%m%dT%H%M%SZ"
Time::DATE_FORMATS[:microformat] = "%Y-%m-%dT%H:%M:%S#{tzoff_negative ? '-' : '+'}#{sprintf("%02i:%02i", tzoff_hours, tzoff_minutes)}"
Time::DATE_FORMATS[:microformat_date] = "%Y-%m-%d"
Time::DATE_FORMATS[:microformat_time] = "%H:%M:%S#{tzoff_negative ? '-' : '+'}#{sprintf("%02i:%02i", tzoff_hours, tzoff_minutes)}"
Time::DATE_FORMATS[:compact_datetime] = "%b %d, %Y, %l:%M:%S%p"

class ActiveSupport::TimeWithZone < Object
  # Return a string representation of the date & time in iCalendar format,
  # with the timezone specified. This includes the leading ‘:’ or ‘;’.
  # Should immediately follow an iCalendar field name (such as “DTSTART”).
  def icalendar_with_zone
    if utc?
      ":#{to_s(:icalendar_utc)}"
    else
      "TZID=#{ActiveSupport::TimeZone::MAPPING[time_zone.name]}:#{to_s(:icalendar)}"
    end
  end
end
