require_relative 'html_presenter'
require_relative 'event_presenter'
require 'date'
require_relative '../models/event'
require_relative 'time_presenter'
require_relative '../wayground/event/day_events'
require_relative '../wayground/event/events_by_date'

# Present a calendar of events in an html grid of weeks for a month.
# The result (a bunch of table rows) must be wrapped in a `table` (and, presumably, a `tbody`) element.
class CalendarMonthPresenter < HtmlPresenter
  attr_accessor :view, :month, :year, :events_by_date, :user

  def initialize(view:, year:, month:, events: [], user: nil)
    self.view = view
    self.year = year
    self.month = month
    self.user = user
    self.events_by_date = Wayground::Event::EventsByDate.new(events)
    @carryover = []
  end

  def weeks
    month_start = Date.new(year, month, 1)
    month_end = (month_start + 1.month) - 1.day
    first_day = month_start.beginning_of_week(:sunday)
    last_day = month_end.end_of_week(:sunday)
    (first_day..last_day).to_a.in_groups_of(7)
  end

  def present_weeks
    view.safe_join(weeks.map { |week| present_week(week) })
  end

  def present_week(week)
    html_tag_with_newline(:tr) do
      view.safe_join(week.map { |day| present_day(day) })
    end
  end

  def present_day(day)
    attrs = {}
    attrs[:class] = 'outside_month' if day.month != month
    html_tag_with_newline(:td, attrs) { present_day_elements(day) }
  end

  def present_day_elements(day)
    present_day_num(day) + present_day_content(day)
  end

  def present_day_num(day)
    # FIXME: find a zone-friendly way to do `day.to_time` in present_day_num(day)
    if day_outside_range?(day)
      # the day is outside the range of events; don't link it
      html_tag(:span, class: day_number_class(day), title: day.to_time.to_s(:simple_date)) { day.day.to_s }
    else
      view.link_to(
        day.day, view.calendar_day_path_for_date(day),
        class: day_number_class(day), title: day.to_time.to_s(:simple_date)
      )
    end
  end

  # is the given day outside the range of Events in the system?
  # TODO: cache Event values
  def day_outside_range?(day)
    Event.count.zero? || (day < Event.earliest_date) || (day > Event.last_date)
  end

  def day_number_class(day)
    day_events = events_by_date[day]
    day_num_class = 'day'
    day_num_class << ' empty' unless (day_events && day_events.count.positive?) || @carryover.count.positive?
    day_num_class
  end

  def present_day_content(day)
    result = html_blank
    day_events = get_day_events(day)
    if day.month == month
      result << present_day_events_count(day_events)
      result << present_day_events(day_events)
    end
    result
  end

  def get_day_events(day)
    day_events = Wayground::Event::DayEvents.new(day: day, events: events_by_date[day], multiday: @carryover)
    @carryover = day_events.carryover
    day_events
  end

  def present_day_events_count(day_events)
    events_count = day_events.count
    if events_count.positive?
      html_tag(:p) { "#{events_count} event#{events_count == 1 ? '' : 's'}" }
    else
      html_blank
    end
  end

  def present_day_events(day_events)
    if day_events.count.positive?
      html_tag(:div, class: 'date_content') { present_day_events_list(day_events.all) }
    else
      html_blank
    end
  end

  def present_day_events_list(events_list)
    html_tag(:ul) do
      view.safe_join(events_list.map { |event| present_event_in_list(event) })
    end
  end

  def present_event_in_list(event)
    presenter = EventPresenter.new(view: view, event: event, user: user)
    attrs = presenter.event_heading_attrs
    title = event_title_with_time(event)
    event_link = view.link_to(title, view.event_path(event), title: title)
    html_tag_with_newline(:li, attrs) { event_link }
  end

  def event_title_with_time(event)
    if event.is_allday
      event.title
    else
      time = TimePresenter.new(event.start_at)
      "#{time.brief}: #{event.title}"
    end
  end
end
