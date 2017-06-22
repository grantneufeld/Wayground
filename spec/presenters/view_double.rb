# A stand-in for views when testing presenters.
# TODO: find the better way to mock/double view methods
# (I seem to recall seeing one once online, but have been unable to re-find it)
class ViewDouble
  def approve_event_path(_event)
    '/events/123/approve'
  end

  def calendar_day_path_for_date(date)
    "/calendar/#{date.year}/#{format('%02d', date.month)}/#{format('%02d', date.day)}"
  end

  def edit_event_path(_event)
    '/events/123/edit'
  end

  def event_path(_event)
    '/test'
  end

  def link_to(*args)
    link = args[1]
    if link.is_a? Array
      action = link[0].is_a?(Symbol) ? link.shift : nil
      links = link.map { |obj| "/#{obj.class.name.pluralize.underscore}/#{obj.to_param}" }
      link = links.join
      link += "/#{action}" if action
    elsif link.is_a? ActiveRecord::Base
      link = "/#{link.class.name.pluralize.underscore}/#{link.to_param}"
    end
    attributes = ''
    args[2]&.each do |k, v|
      attributes << " #{k}=\"#{html_escape(v)}\""
    end
    "<a href=\"#{link}\"#{attributes}>#{args[0]}</a>".html_safe
  end

  def separator
    ':separator:'.html_safe
  end

  def simple_text_to_html_breaks(text)
    html_escape(text.strip).gsub(/[\r\n]+/, ':').html_safe
  end

  def safe_join(array, separator = ''.html_safe)
    result = ''.html_safe
    needs_separator = false
    array.each do |item|
      result << separator if needs_separator
      needs_separator = true
      result << item
    end
    result
  end

  private

  # copied from ERB::Util#html_escape in
  # rails/activesupport/lib/active_support/core_ext/string/output_safety.rb
  HTML_ESCAPE = { '&' => '&amp;', '>' => '&gt;', '<' => '&lt;', '"' => '&quot;', "'" => '&#x27;' }.freeze
  def html_escape(s)
    s = s.to_s
    if s.html_safe?
      s
    else
      s.gsub(/[&"'><]/, HTML_ESCAPE).html_safe
    end
  end
end
