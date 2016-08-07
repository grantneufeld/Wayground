require 'event/day_events'
require 'event/event_selector'
require 'merger'

# Access events.
class EventsController < ApplicationController
  before_action :set_user
  before_action :set_event, except: %i(index new create)
  before_action :requires_login, only: %i(new create)
  before_action :requires_update_authority, only: %i(edit update merge perform_merge)
  before_action :requires_delete_authority, only: %i(delete destroy merge perform_merge)
  before_action :requires_approve_authority, only: %i(approve set_approved)
  before_action :set_section
  before_action :set_new_event, only: %i(new create)
  before_action :set_editor, only: %i(create update destroy approve merge perform_merge)

  def index
    selector = Wayground::Event::EventSelector.new(
      range: params[:range] || params[:r], tag: params[:tag], user: @user
    )
    @events = selector.events
    @range = selector.range
    @tag = selector.tag
    page_metadata(title: selector.title)
  end

  def show
    page_metadata(
      title: "#{@event.start_at.to_s(:simple_date)}: #{@event.title}", description: @event.description
    )
    if !@event.is_approved?
      page_metadata.nocache = true
      message = 'This event listing has not been approved by a moderator yet.'
    elsif @event.is_cancelled
      message = 'This event has been cancelled.'
    elsif @event.is_tentative
      message = 'This event is tentative.'
    end
    flash.now.alert = message if message
  end

  def new; end

  def create
    @event.user = @user
    if @event.save
      notice =
        if @user.present? && @user.authority_for_area('Calendar', :is_owner)
          'The event has been saved.'
        else
          'The event has been submitted.'
        end
      redirect_to(@event, notice: notice)
    else
      render action: 'new'
    end
  end

  def edit
    page_metadata(title: "Edit Event: #{@event.title}")
  end

  def update
    page_metadata(title: "Edit Event: #{@event.title}")
    if @event.update(event_params)
      notice = 'The event has been saved.'
      redirect_to(@event, notice: notice)
    else
      render action: 'edit'
    end
  end

  def update_tags
    @event.tag_list = params[:tag_list]
    @event.editor = @user
    @event.edit_comment = 'Updated tag list.'
    # updating tags should not affect sourced_items’ locally modified status
    @event.is_sourcing = true
    if @event.save
      redirect_to(@event, notice: 'The event tags have been saved.')
    else
      redirect_to(@event, alert: 'Unable to save the changes to the tags!')
    end
  end

  def delete
    page_metadata(title: "Delete Event: #{@event.title}")
  end

  def destroy
    @event.destroy
    redirect_to(events_url)
  end

  def approve
    if @event.is_approved?
      redirect_to(@event, notice: 'The event has already been approved.')
    else
      page_metadata(title: "Approve Event: #{@event.title}")
    end
  end

  def set_approved
    if @event.approve_by(@user)
      redirect_to(@event, notice: 'The event is now approved.')
    else
      redirect_to(@event, alert: 'Failed to approve the event!')
    end
  end

  def merge
    page_metadata(title: "Merge Event: #{@event.title}")
    @day_events = Wayground::Event::DayEvents.new(
      events: Event.falls_on_date(@event.start_at).where('id != ?', @event.id)
    )
  end

  def perform_merge
    page_metadata(title: "Merge Event: #{@event.title}")
    @merge_with = Event.find(params[:merge_with])
    @merge_with.editor = @user
    merger = Merger::EventMerger.new(@event)
    @conflicts = merger.merge_into!(@merge_with)
  end

  protected

  # The actions for this controller, other than viewing, require login and usually authorization.
  def requires_login
    raise Wayground::LoginRequired unless @user
  end

  def requires_authority(action)
    event_allowed = @event && @event.authority_for_user_to?(@user, action)
    unless event_allowed || (@user && @user.authority_for_area(Event.authority_area, action))
      raise Wayground::AccessDenied
    end
  end

  def requires_update_authority
    requires_authority(:can_update)
  end

  def requires_delete_authority
    requires_authority(:can_delete)
  end

  def requires_approve_authority
    requires_authority(:can_approve)
  end

  def set_section
    @site_section = :events
  end

  def set_user
    @user = current_user
  end

  # Most of the actions for this controller receive the id of an Event as a parameter.
  def set_event
    @event = Event.find(params[:id])
  end

  def set_new_event
    page_metadata(title: 'New Event')
    @event = Event.new(event_params)
  end

  def set_editor
    @event.editor = @user
  end

  def event_params
    params.fetch(:event, {}).permit(
      :start_at, :end_at, :timezone, :is_allday,
      :is_draft, :is_wheelchair_accessible, :is_adults_only, :is_tentative, :is_cancelled, :is_featured,
      :title, :description, :content,
      :organizer, :organizer_url,
      :location, :address, :city, :province, :country, :location_url,
      :external_links_attributes, :edit_comment, :tag_list
    )
  end
end
