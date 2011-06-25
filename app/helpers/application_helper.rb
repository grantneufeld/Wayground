module ApplicationHelper
  # Generate the errors report to show with a form.
  # item: the item to get the errors from
  # heading: the optional error message, shown as a heading above the list of errors
	def show_errors(item, heading=nil)
		render :partial => 'layouts/errors', :locals => {:item => item, :heading => heading}
	end

  # Generate an image tag for an icon based on a type of file (content_type).
  # content_type: the file mimetype
  # size: size, in pixels, of the icon
  def icon_for_content_type(content_type, size = 16)
    # TODO: implement icon_for_content_type helper
    return nil
  end
end
