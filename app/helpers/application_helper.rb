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
end
