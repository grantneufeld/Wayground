require 'html_presenter'

class TimePresenter < HtmlPresenter
  attr_accessor :time

  def initialize(time)
    self.time = time
  end

  def brief
    if time.min == 0
      brief_just_the_hour
    else
      time.strftime('%l:%M%P').strip.html_safe
    end
  end

  def brief_just_the_hour
    if time.hour == 0
      'midnight'.html_safe
    elsif time.hour == 12
      'noon'.html_safe
    else
      time.strftime('%l%P').strip.html_safe
    end
  end

  # Display the time in a microformat time element.
  def microformat_start(time_format=:plain_time)
    microformat(html_class: 'dtstart') do
      time.to_s(time_format).strip.html_safe
    end
  end
  def microformat_end(time_format=:plain_time)
    microformat(html_class: 'dtend') do
      time.to_s(time_format).strip.html_safe
    end
  end

  # Get a microformat time element (without showing the time).
  def microformat_hidden_start
    microformat(html_class: 'dtstart')
  end
  def microformat_hidden_end
    microformat(html_class: 'dtend')
  end

  def microformat(params={}, &block)
    html_class = params[:html_class] || 'dtstart'
    html_tag('time', {class: html_class, datetime: time.to_s(:microformat)}, &block)
  end


end
