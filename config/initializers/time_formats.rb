tzoff_secs = Time.now.gmt_offset
if tzoff_secs < 0
	tzoff_negative = true
	tzoff_secs *= -1
else
	tzoff_negative = false
end
tzoff_minutes = tzoff_secs / 60
tzoff_hours = tzoff_minutes / 60
tzoff_minutes = tzoff_minutes % 60

Time::DATE_FORMATS[:time_date] = "%l:%M:%S %p on %A, %B %d, %Y"
Time::DATE_FORMATS[:plain_date] = "%A, %B %e, %Y"
Time::DATE_FORMATS[:icalendar] = "%Y%m%dT%H%M%S"
Time::DATE_FORMATS[:microformat] = "%Y-%m-%dT%H:%M:%S#{tzoff_negative ? '-' : '+'}#{sprintf("%02i:%02i", tzoff_hours, tzoff_minutes)}"
Time::DATE_FORMATS[:microformat_date] = "%Y-%m-%d"
Time::DATE_FORMATS[:microformat_time] = "%H:%M:%S#{tzoff_negative ? '-' : '+'}#{sprintf("%02i:%02i", tzoff_hours, tzoff_minutes)}"
Time::DATE_FORMATS[:compact_datetime] = "%b %d, %Y, %l:%M:%S%p"
