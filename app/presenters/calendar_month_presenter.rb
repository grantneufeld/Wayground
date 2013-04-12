# encoding: utf-8
require 'html_presenter'
require 'date'
require 'time_presenter'
require 'event/day_events'
require 'event/events_by_date'

# Present a calendar of events in an html grid of weeks for a month.
# The result (a bunch of table rows) must be wrapped in a `table` (and, presumably, a `tbody`) element.
class CalendarMonthPresenter < HtmlPresenter
  attr_accessor :view, :month, :year, :events_by_date

  # Initialize with params: :view, :month, :year, :events
  def initialize(params={})
    self.view = params[:view]
    self.month = params[:month]
    self.year = params[:year]
    self.events_by_date = Wayground::Event::EventsByDate.new(params[:events])
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
    view.safe_join(weeks.map {|week| present_week(week) })
  end

  def present_week(week)
    html_tag_with_newline(:tr) do
      view.safe_join(week.map {|day| present_day(day) })
    end
  end

  def present_day(day)
    attrs = {}
    if day.month != month
      attrs[:class] = 'outside_month'
    end
    html_tag_with_newline(:td, attrs) { present_day_elements(day) }
  end

  def present_day_elements(day)
    present_day_num(day) + present_day_content(day)
  end

  def present_day_num(day)
    day_events = events_by_date[day]
    day_num_class = 'day'
    day_num_class << ' empty' unless (day_events && day_events.count > 0) || @carryover.count > 0
    view.link_to(
      day.day, view.calendar_day_path_for_date(day),
      class: day_num_class, title: day.to_time.to_s(:simple_date)
    )
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
    if events_count > 0
      html_tag(:p) { "#{events_count} event#{events_count == 1 ? '' : 's'}" }
    else
      html_blank
    end
  end

  def present_day_events(day_events)
    if day_events.count > 0
      html_tag(:div, class: 'date_content') { present_day_events_list(day_events.all) }
    else
      html_blank
    end
  end

  def present_day_events_list(events_list)
    html_tag(:ul) do
      view.safe_join(events_list.map {|event| present_event_in_list(event) })
    end
  end

  def present_event_in_list(event)
    link_title = event.title
    unless event.is_allday
      time = TimePresenter.new(event.start_at)
      link_title = "#{time.brief}: #{link_title}"
    end
    event_link = view.link_to(link_title, view.event_path(event), title: link_title)
    html_tag_with_newline(:li) { event_link }
  end

end
