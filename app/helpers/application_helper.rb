module ApplicationHelper
  # Generate the errors report to show with a form.
  # item: the item to get the errors from
  # heading: the optional error message, shown as a heading above the list of errors
  def show_errors(item, heading=nil)
    render :partial => 'layouts/errors', :locals => {:item => item, :heading => heading}
  end

  # Generate the pagination header, telling the user where they are in the pagination.
  # item_plural: The pluralized name of the type of item (e.g., “documents”).
  def show_pagination_header(item_plural = nil)
    render :partial => 'layouts/pagination_header', :locals => {:item_plural => item_plural}
  end

  # Generate the pagination selector (links to numbered pages), if there is more than one page.
  def show_pagination_selector
    render :partial => 'layouts/pagination_selector'
  end

  # Generate an image tag for an icon based on a type of file (content_type).
  # content_type: the file mimetype
  # size: size, in pixels, of the icon
  def icon_for_content_type(content_type, size = 16)
    # TODO: implement icon_for_content_type helper
    return nil
  end

  # Convert a string to simple html based on line-breaks.
  def simple_text_to_html(text)
    CGI.escapeHTML(text.strip). # remove leading & trailing whitespace, then escape html unsafe chars
      gsub(/([^\r\n])(\r\n?|\n)([^\r\n])/, '\1<br />\3'). # convert single line-breaks to br elements
      gsub(/([^\r\n])(\r\n?|\n)([^\r\n])/, '\1<br />\3'). # repeat because of my sloppy regexp
      gsub(/[\r\n][\r\n]+/, "\n"). # mush together all linebreak types into single linebreaks
      gsub(/^(.+)$/, '<p>\1</p>' ). # convert remaining lines to paragraphs
      html_safe # mark as safe html
  end

  # Convert a string to html, but only using line breaks (no block elements like paragraphs)
  def simple_text_to_html_breaks(text)
    CGI.escapeHTML(text.strip).
      gsub(/(\r\n?(\r\n?)+|\n\n+)/, '<br /><br />'). # convert sequences of more than one line break to 2 br elements
      gsub(/[\r\n]+/, '<br />'). # convert remaining line breaks to single br elements
      html_safe
  end

end
