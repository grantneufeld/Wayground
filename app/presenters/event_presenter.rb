require_relative 'html_presenter'
require 'date'
require_relative 'time_presenter'

# Present an event with microformat markup.
class EventPresenter < HtmlPresenter
  attr_reader :view, :event, :user

  def initialize(view:, event:, user: nil) # params = {})
    @view = view
    @event = event
    @user = user
  end

  def present_in_list
    html_tag_with_newline(:div, class: 'vevent') { present_heading + present_details }
  end

  def present_heading
    html_tag_with_newline(:h4, event_heading_attrs) do
      present_status + present_schedule + ':'.html_safe + newline + present_title
    end
  end

  def event_heading_attrs
    classes = []
    classes << 'cancelled'.html_safe if event.is_cancelled?
    classes << 'tentative'.html_safe if event.is_tentative?
    classes.size.positive? ? { class: classes } : {}
  end

  def present_status
    if event.is_cancelled
      html_tag_with_newline(:span, class: 'status', title: 'CANCELLED') { 'Cancelled:' }
    elsif event.is_tentative
      html_tag_with_newline(:span, class: 'status', title: 'TENTATIVE') { 'Tentative:' }
    else
      html_blank
    end
  end

  def present_schedule
    if event.is_allday?
      present_time_allday
    else
      present_time
    end
  end

  def present_schedule_with_date
    if event.is_allday?
      present_time(:plain_date)
    else
      present_time(:plain_datetime)
    end
  end

  def present_time(time_format = :plain_time)
    result = TimePresenter.new(event.start_at).microformat_start(time_format)
    result << append_time_end_at if event.end_at?
    result
  end

  def append_time_end_at
    event_end = event.end_at
    if event.multi_day?
      ' to '.html_safe + TimePresenter.new(event_end).microformat_end(:plain_datetime)
    else
      '—'.html_safe + TimePresenter.new(event_end).microformat_end
    end
  end

  def present_time_allday
    # TODO: change the microformat date encoding to reflect untimed day
    result = TimePresenter.new(event.start_at).microformat_hidden_start
    if event.multi_day?
      # TODO: change the microformat date encoding to reflect untimed day
      result << TimePresenter.new(event.end_at).microformat_end(:plain_date)
    end
    result
  end

  def present_title
    html_tag('span', class: 'summary') do
      view.link_to(event.title, event)
    end
  end

  def present_details
    result = present_details_chunks
    if result.present?
      html_tag_with_newline('p') { result }
    else
      html_blank
    end
  end

  def present_details_chunks
    chunks = [
      present_minimal_location, present_description, present_organizer, present_action_menu
    ]
    chunks.reject!(&:empty?)
    view.safe_join(chunks, newline + html_tag(:br))
  end

  # minimal location details
  def present_minimal_location
    chunks = [present_location_org, present_location_address]
    separator = ','.html_safe + newline
    result = join_chunks(chunks, separator)
    if result.present?
      html_tag('span', class: 'location') { result }
    else
      html_blank
    end
  end

  # all the location details
  def present_location_block
    chunks = [present_location_org, present_location_full_address]
    separator = newline + html_tag(:br)
    result = join_chunks(chunks, separator)
    if result.present?
      html_tag_with_newline('p', class: 'location') { result }
    else
      html_blank
    end
  end

  def present_location_org
    if event.location?
      anchor_or_span_tag(event.location_url, class: 'fn org') { html_escape(event.location) }
    else
      html_blank
    end
  end

  def present_location_address
    if event.address?
      html_tag('span', class: 'adr') do
        present_location_street_address
      end
    else
      html_blank
    end
  end

  def present_location_full_address
    content = location_address_elements
    if content.blank?
      html_blank
    else
      html_tag('span', class: 'adr') { content }
    end
  end

  def location_address_elements
    if event.address?
      full_address_elements
    elsif event.city? || event.province? || event.country?
      present_location_region
    end
  end

  def full_address_elements
    view.safe_join(
      [present_location_street_address, present_location_region],
      newline + html_tag(:br)
    )
  end

  def present_location_street_address
    # use the location url if there is no location
    url = event.location? ? nil : event.location_url
    if event.address?
      anchor_or_span_tag(url, class: 'street-address') { html_escape(event.address) }
    elsif url
      # link to just the location url if there is no location and no address
      html_tag('a', href: url) { html_escape(url) }
    else
      html_blank
    end
  end

  # city, province, country
  def present_location_region
    elements = [present_location_city, present_location_province, present_location_country]
    elements.delete_if(&:blank?)
    view.safe_join(elements, ', '.html_safe)
  end

  def present_location_city
    if event.city?
      html_tag(:span, class: 'locality') { html_escape(event.city) }
    else
      html_blank
    end
  end

  def present_location_province
    if event.province?
      html_tag(:span, class: 'region') { html_escape(event.province) }
    else
      html_blank
    end
  end

  def present_location_country
    if event.country?
      html_tag(:span, class: 'country-name') { html_escape(event.country) }
    else
      html_blank
    end
  end

  def present_description
    if event.description?
      html_tag(:span, class: 'description') { view.simple_text_to_html_breaks(event.description) }
    else
      html_blank
    end
  end

  def present_organizer
    if event.organizer?
      org =
        anchor_or_span_tag(html_escape(event.organizer_url), class: 'organizer') do
          html_escape(event.organizer)
        end
      "Presented by #{org}.".html_safe
    else
      html_blank
    end
  end

  def present_action_menu
    actions = [present_edit_action, present_approve_action, present_delete_action]
    actions.reject! { |action| action == '' }
    if actions.empty?
      html_blank
    else
      view.safe_join(actions, view.separator + newline)
    end
  end

  def present_edit_action
    if user && event.has_authority_for_user_to?(user, :can_update)
      view.link_to('Edit', view.edit_event_path(event), class: 'action')
    else
      html_blank
    end
  end

  def present_approve_action
    if !event.is_approved? && user && event.has_authority_for_user_to?(user, :can_approve)
      append_approve_action_link
    else
      html_blank
    end
  end

  def append_approve_action_link
    view.link_to(
      'Approve', view.approve_event_path(event),
      data: { confirm: "Are you sure you want to approve the event “#{event.title}”?" },
      method: :post, class: 'action'
    )
  end

  def present_delete_action
    if user && event.has_authority_for_user_to?(user, :can_delete)
      # FIXME: check if this will still work correctly if we remove the `.html_safe` call at the end
      view.link_to(
        'Delete', [:delete, event],
        data: { confirm: 'Are you sure?' }, method: :delete, class: 'action'
      ).html_safe
    else
      html_blank
    end
  end

  protected

  def join_chunks(chunks, separator = ', ')
    chunks.reject!(&:empty?)
    view.safe_join(chunks, separator)
  end
end
