module RoutesHelper
  def calendar_day_path_for_date(date)
    calendar_day_path(year: date.year, month: format('%02d', date.month), day: format('%02d', date.day))
  end
end
