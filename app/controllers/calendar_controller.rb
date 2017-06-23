require 'date'
require 'time'
require 'event'
require 'event/year'

# Present calendar views of events.
class CalendarController < ApplicationController
  before_action :set_user, except: [:index]
  before_action :require_year, only: %i[year month day]
  before_action :require_month, only: %i[month day]
  before_action :require_day, only: [:day]
  before_action :set_section, except: [:index]

  def index
    today = Time.zone.today
    redirect_to calendar_month_url(year: today.year, month: today.strftime('%m'))
  end

  def subscribe; end

  def year
    year = @date.year
    description = "#{Wayground::Application::NAME} calendar of events for #{year}."
    year_start = Date.new(year, 1, 1)
    year_end = Date.new(year, 12, 31)
    @total_event_count = Event.approved.falls_between_dates(year_start, year_end).count
    @event_counts = Wayground::Event::Year.new(year: year).monthly_event_counts
    page_metadata(title: year.to_s, description: description, nocache: @total_event_count.zero?)
    render
  end

  def month
    title_date = @date.strftime('%B %Y')
    description = "#{Wayground::Application::NAME} calendar of events for #{title_date}."
    month_start = Date.new(@date.year, @date.month, 1)
    month_end = (month_start + 1.month) - 1.day
    @events = Event.approved.falls_between_dates(month_start, month_end)
    page_metadata(title: title_date, description: description, nocache: @events.count.zero?)
  end

  def day
    title_date = @date.strftime('%B %-e, %Y')
    description = "#{Wayground::Application::NAME} calendar of events for #{title_date}."
    @events = Event.approved.falls_on_date(Date.new(@date.year, @date.month, @date.day))
    page_metadata(title: title_date, description: description, nocache: @events.count.zero?)
  end

  protected

  def set_user
    @user = current_user
  end

  # return missing (404) if the year does not fall between the year 1000 and 100 years from now
  def require_year
    year = params['year'].to_i
    if year < 1000 || year > (Time.zone.now.year + 100)
      missing
    else
      @date = Date.new(year, 1, 1)
    end
  end

  def require_month
    month = params['month'].to_i
    # routing won't get here unless month between '01'..'12',
    # so don’t need to do missing check
    @date = Date.new(@date.year, month, 1)
  end

  # return missing (404) if not a valid day of month
  def require_day
    day = params['day'].to_i
    if (day < 1) || (day > @date.end_of_month.day)
      missing
    else
      @date = Date.new(@date.year, @date.month, day)
    end
  end

  def set_section
    @site_section = :calendar
  end
end
