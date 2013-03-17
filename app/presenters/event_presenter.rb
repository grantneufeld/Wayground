# encoding: utf-8
require 'html_presenter'
require 'date'
require 'time_presenter'

# Present an event with microformat markup.
class EventPresenter < HtmlPresenter
  attr_reader :view, :event, :user

  # Initialize with params: :view, :event, :user
  def initialize(params={})
    @view = params[:view]
    @event = params[:event]
    @user = params[:user]
  end

  def present_in_list
    html_tag_with_newline(:div, class: 'vevent') { present_heading + present_details }
  end

  def present_heading
    html_tag_with_newline('h4') { present_status + present_schedule + present_title }
  end

  def present_status
    if event.is_cancelled
      html_tag_with_newline(:span, class: 'status', title: 'CANCELLED') { 'Cancelled:' }
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

  def present_time
    result = TimePresenter.new(event.start_at).microformat_start
    if event.end_at?
      result << append_time_end_at
    end
    result + ':'.html_safe + newline
  end

  def append_time_end_at
    event_end = event.end_at
    if event.is_multi_day
      ' to '.html_safe + TimePresenter.new(event_end).microformat_end(:plain_datetime)
    else
      '—'.html_safe + TimePresenter.new(event_end).microformat_end
    end
  end

  def present_time_allday
    # TODO: change the microformat date encoding to reflect untimed day
    result = TimePresenter.new(event.start_at).microformat_hidden_start
    if event.is_multi_day
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
    chunks = [present_location, present_description, present_organizer, present_action_menu]
    chunks.reject! {|chunk| chunk.empty? }
    chunks.join(newline + html_tag(:br)).html_safe
  end

  def present_location
    result = present_location_chunks
    if result.present?
      html_tag('span', class: 'location') { result }
    else
      html_blank
    end
  end

  def present_location_chunks
    chunks = [present_location_org, present_location_address]
    chunks.reject! {|chunk| chunk.empty? }
    chunks.join(','.html_safe + newline).html_safe
  end

  def present_location_org
    if event.location?
      html_tag('span', class: 'fn org') { html_escape(event.location) }
    else
      html_blank
    end
  end

  def present_location_address
    if event.address?
      html_tag('span', class: 'adr') do
        html_tag('span', class: 'street-address') do
          html_escape(event.address)
        end
      end
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
      html_tag(:br) + 'Presented by '.html_safe + append_organizer_and_url + '.'.html_safe
    else
      html_blank
    end
  end

  def append_organizer_and_url
    event_organizer = html_escape(event.organizer)
    event_organizer_url = html_escape(event.organizer_url)
    if event_organizer_url.present?
      html_tag('a', href: event_organizer_url, class: 'organizer') do
        event_organizer
      end
    else
      html_tag('span', class: 'organizer') { event_organizer }
    end
  end

  def present_action_menu
    actions = [present_edit_action, present_approve_action, present_delete_action]
    actions.reject! {|action| action == '' }
    unless actions.empty?
      actions.join(view.separator + newline).html_safe
    else
      html_blank
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
    if !(event.is_approved?) && user && event.has_authority_for_user_to?(user, :can_approve)
      append_approve_action_link
    else
      html_blank
    end
  end

  def append_approve_action_link
    view.link_to('Approve', view.approve_event_path(event),
      data: {confirm: "Are you sure you want to approve the event “#{event.title}”?"},
      method: :post, class: 'action'
    )
  end

  def present_delete_action
    if user && event.has_authority_for_user_to?(user, :can_delete)
      view.link_to('Delete', [:delete, event],
        data: {confirm: 'Are you sure?'}, method: :delete, class: 'action'
      ).html_safe
    else
      html_blank
    end
  end

end
