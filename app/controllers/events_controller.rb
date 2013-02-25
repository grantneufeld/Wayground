# encoding: utf-8

class EventsController < ApplicationController
  before_filter :set_user
  before_filter :set_event, :except => [:index, :new, :create]
  before_filter :requires_login, :only => [:new, :create]
  before_filter :requires_update_authority, :only => [:edit, :update, :merge, :perform_merge]
  before_filter :requires_delete_authority, :only => [:delete, :destroy, :merge, :perform_merge]
  before_filter :requires_approve_authority, :only => [:approve, :set_approved]
  before_filter :set_section
  before_filter :set_new_event, :only => [:new, :create]
  before_filter :set_editor, :only => [:create, :update, :destroy, :approve, :merge, :perform_merge]

  def index
    range = params[:r]
    @page_title = case range
    when 'all'
      'Events'
    when 'past'
      'Events: Past'
    else
      'Events: Upcoming'
    end
    # TODO: paginate Events#index
    if @user && @user.has_authority_for_area(Event.authority_area, :can_approve)
      # moderators see both approved and unapproved events
      @events = case range
      when 'all'
        Event.all
      when 'past'
        Event.past
      else
        Event.upcoming
      end
    else
      @events = case range
      when 'all'
        Event.approved
      when 'past'
        Event.past.approved
      else
        Event.upcoming.approved
      end
    end
  end

  def show
    @page_title = "#{@event.start_at.to_s(:simple_date)}: #{@event.title}"
    if @event.is_cancelled
      flash.now.alert = 'This event has been cancelled.'
    end
    unless @event.is_approved?
      @browser_nocache = true
      flash.now.alert = 'This event listing has not been approved by a moderator yet.'
    end
  end

  def new
  end

  def create
    @event.user = @user

    if @event.save
      if @user.present? && @user.has_authority_for_area('Calendar', :is_owner)
        notice = 'The event has been saved.'
      else
        notice = 'The event has been submitted.'
      end
      redirect_to(@event, notice: notice)
    else
      render action: "new"
    end
  end

  def edit
    @page_title = "Edit Event: #{@event.title}"
  end

  def update
    @page_title = "Edit Event: #{@event.title}"
    if @event.update_attributes(params[:event])
      notice = 'The event has been saved.'
      redirect_to(@event, notice: notice)
    else
      render action: "edit"
    end
  end

  def delete
    @page_title = "Delete Event: #{@event.title}"
  end

  def destroy
    @event.destroy
    redirect_to(events_url)
  end

  def approve
    if @event.is_approved?
      redirect_to(@event, :notice => 'The event has already been approved.')
    else
      @page_title = "Approve Event: #{@event.title}"
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
    @page_title = "Merge Event: #{@event.title}"
  end

  def perform_merge
    @page_title = "Merge Event: #{@event.title}"
    @merge_with = Event.find(params[:merge_with])
    @merge_with.editor = @user
    merger = Merger::EventMerger.new(@event)
    @conflicts = merger.merge_into!(@merge_with)
  end

  protected

  # The actions for this controller, other than viewing, require login and usually authorization.
  def requires_login
    unless @user
      raise Wayground::LoginRequired
    end
  end
  def requires_authority(action)
    unless (
      (@event && @event.has_authority_for_user_to?(@user, action)) ||
      (@user && @user.has_authority_for_area(Event.authority_area, action))
    )
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
    @page_title = 'New Event'
    @event = Event.new(params[:event])
  end

  def set_editor
    @event.editor = @user
  end
end
