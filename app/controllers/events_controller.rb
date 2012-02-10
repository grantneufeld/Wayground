# encoding: utf-8

class EventsController < ApplicationController
  before_filter :set_user
  before_filter :set_event, :except => [:index, :new, :create]
  before_filter :requires_login, :only => [:new, :create]
  before_filter :requires_update_authority, :only => [:edit, :update]
  before_filter :requires_delete_authority, :only => [:delete, :destroy]
  before_filter :set_section
  before_filter :set_new_event, :only => [:new, :create]
  before_filter :set_editor, :only => [:create, :update, :destroy]

  # GET /events
  # GET /events.xml
  def index
    @page_title = 'Events'
    #@events = paginate(Event.all)
    @events = Event.all
    respond_to do |format|
      format.html # index.html.erb
      format.ics # index.ics.erb
      format.xml { render :xml => @events }
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    @page_title = "#{@event.start_at.to_s(:simple_date)}: #{@event.title}"
    if @event.is_cancelled
      flash.now.alert = 'This event has been cancelled.'
    end
    respond_to do |format|
      format.html # show.html.erb
      format.ics # show.ics.erb
      format.xml { render :xml => @event }
    end
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # POST /events
  # POST /events.xml
  def create
    @event.user = @user

    respond_to do |format|
      if @event.save
        if @user.present? && @user.has_authority_for_area('Calendar', :is_owner)
          notice = 'The event has been saved.'
        else
          notice = 'The event has been submitted.'
        end
        format.html { redirect_to(@event, :notice => notice) }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /events/1/edit
  def edit
    @page_title = "Edit Event: #{@event.title}"
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    @page_title = "Edit Event: #{@event.title}"
    respond_to do |format|
      if @event.update_attributes(params[:event])
        notice = 'The event has been saved.'
        format.html { redirect_to(@event, :notice => notice) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /events/1/delete
  def delete
    @page_title = "Delete Event: #{@event.title}"
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_url) }
      format.xml  { head :ok }
    end
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

  def set_section
    @site_section = 'Events'
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
