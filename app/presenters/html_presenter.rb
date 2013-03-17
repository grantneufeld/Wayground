# encoding: utf-8

class HtmlPresenter

  # Generate an html tag with a newline appended.
  def html_tag_with_newline(tag_name, attrs_list={}, &block)
    html_tag(tag_name, attrs_list, &block) + newline
  end

  # Generate an html tag.
  # attrs_list hash will be converted to element attributes.
  # The optional block will be enclosed by the tag.
  # Otherwise, a unary tag will be returned.
  # Note that the result of the content block must be an html_safe string.
  # Example usage:
  # html_tag(:p, id: 'example') { 'An example.'.html_safe } # => '<p id="example">An example.</p>'
  def html_tag(tag_name, attrs_list={}, &block)
    attrs = []
    attrs_list.each do |key, value|
      # merge the strings in an array with space separator
      # e.g., {class: ['a', 'b']} becomes class="a b"
      if value.is_a? Array
        value = value.join(' ')
      end
      attrs << "#{key}=\"#{value}\""
    end
    content = yield block if block
    tag_name_with_attrs = ([tag_name] + attrs).join(' ')
    if !content || content.empty?
      "<#{tag_name_with_attrs} />".html_safe
    else
      "<#{tag_name_with_attrs}>#{content}</#{tag_name}>".html_safe
    end
  end

  # based on ERB::Util#html_escape in rails/activesupport/lib/active_support/core_ext/string/output_safety.rb
  HTML_ESCAPE = { '&' => '&amp;', '>' => '&gt;', '<' => '&lt;', '"' => '&quot;', "'" => '&#x27;' }
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

end