# encoding: utf-8

class EventsController < ApplicationController
  before_filter :set_section

  # GET /events
  # GET /events.xml
  def index
    #@events = paginate(Event.all)
    @events = Event.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    @event = Event.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # POST /events
  # POST /events.xml
  def create
    @event = Event.new(params[:event])
    user = current_user
    @event.user = user

    respond_to do |format|
      if @event.save
        if user.present? && user.has_authority_for_area('Calendar', :is_owner)
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
    @event = Event.find(params[:id])
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        # TODO: if current_user is admin, give a different notice
        notice = 'The event has been submitted.'
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
    @event = Event.find(params[:id])
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_url) }
      format.xml  { head :ok }
    end
  end

  protected

  def set_section
    @site_section = 'Events'
  end

end
