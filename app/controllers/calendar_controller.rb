# encoding: utf-8
require 'date'
require 'time'
require 'event'
require 'event/year'

# Present calendar views of events.
class CalendarController < ApplicationController
  before_filter :set_user
  before_filter :require_year
  before_filter :require_month, except: [:year]
  before_filter :require_day, only: [:day]
  before_filter :set_section

  def year
    year = @date.year
    @page_title = year.to_s
    @total_event_count = Event.approved.falls_between_dates(Date.new(year, 1, 1), Date.new(year, 12, 31)).count
    @event_counts = Wayground::Event::Year.new(year: year).monthly_event_counts
    render( {locals: {foo: 'bar'}} )
  end

  def month
    @page_title = @date.strftime('%B %Y')
    month_start = Date.new(@date.year, @date.month, 1)
    month_end = (month_start + 1.month) - 1.day
    @events = Event.approved.falls_between_dates(month_start, month_end)
  end

  def day
    @page_title = @date.strftime('%B %-e, %Y')
    @events = Event.approved.falls_on_date(Date.new(@date.year, @date.month, @date.day))
  end

  protected

  def set_user
    @user = current_user
  end

  # return missing (404) if the year does not fall between the year 1000 and 100 years from now
  def require_year
    year = params['year'].to_i
    if year < 1000 || year > (Time.now.year + 100)
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
    @site_section = 'Events'
  end

end
