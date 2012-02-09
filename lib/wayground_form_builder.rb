# encoding: utf-8

# Extensions to the standard form builder.
# Make available by calling `form_for(my_object, :builder => WaygroundFormBuilder)`.
class WaygroundFormBuilder < ActionView::Helpers::FormBuilder
  # A date & time text field that presents the datetime in plain text.
  # TODO: Integrate (optional) pop-up calendar selector.
  def datetime_field(method, options={})
    date = @object.send(method)
    unless date.blank? || date.is_a?(String)
      options[:value] ||= date.getlocal.to_s(:form_field)
    end
    text_field(method, objectify_options(options))
  end
end
