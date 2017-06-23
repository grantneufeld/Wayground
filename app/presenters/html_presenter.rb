# Common methods for presenting textual content in html format.
# Generally used as a parent class for other presenters.
class HtmlPresenter
  # Generate an html tag with a newline appended.
  def html_tag_with_newline(tag_name, attrs_list = {}, &block)
    html_tag(tag_name, attrs_list, &block) + newline
  end

  # Generate an html tag.
  # attrs_list hash will be converted to element attributes.
  # The optional block will be enclosed by the tag.
  # Otherwise, a unary tag will be returned.
  # Note that the result of the content block must be an html_safe string.
  # Example usage:
  # html_tag(:p, id: 'example') { 'An example.'.html_safe } # => '<p id="example">An example.</p>'
  def html_tag(tag_name, attrs_list = {}, &block)
    attrs = []
    attrs_list.each do |key, value|
      # merge the strings in an array with space separator
      # e.g., { class: ['a', 'b'] } becomes class = "a b"
      value = value.join(' ') if value.is_a? Array
      attrs << "#{key}=\"#{value}\"" if value.present?
    end
    content = yield block if block
    render_tag(tag_name, attrs, content)
  end

  def render_tag(tag_name, attrs, content)
    tag_name_with_attrs = ([tag_name] + attrs).join(' ')
    if content.blank?
      "<#{tag_name_with_attrs} />".html_safe
    else
      "<#{tag_name_with_attrs}>#{content}</#{tag_name}>".html_safe
    end
  end

  # present as an anchor if the url is present, otherwise as a span
  def anchor_or_span_tag(url, attrs = {}, &block)
    if url.blank?
      html_tag('span', attrs, &block)
    else
      html_tag('a', attrs.merge(href: url), &block)
    end
  end

  # based on ERB::Util#html_escape in rails/activesupport/lib/active_support/core_ext/string/output_safety.rb
  HTML_ESCAPE = { '&' => '&amp;', '>' => '&gt;', '<' => '&lt;', '"' => '&quot;', "'" => '&#x27;' }.freeze
  def html_escape(text)
    text = text.to_s
    if text.html_safe?
      text
    else
      text.gsub(/[&"'><]/, HTML_ESCAPE).html_safe
    end
  end

  # An html_safe empty string.
  def html_blank
    ''.html_safe
  end

  # An html_safe EOL character sequence.
  def newline
    "\n".html_safe
  end

  # Strip away details from an url to simplify it for human reading.
  def url_for_print(url)
    # strip leading `http://` (or `https://`), and trailing `/`
    url.gsub(%r{^https?://}, '').gsub(%r{[/\.]+$}, '')
  end
end
