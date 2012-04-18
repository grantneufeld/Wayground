# encoding: utf-8

# This controller must always be a sub-controller (e.g., /events/:event_id/external_links).
class ExternalLinksController < ApplicationController
  before_filter :set_user
  before_filter :set_item
  before_filter :set_external_link, :except => [:index, :new, :create]
  before_filter :requires_login, :only => [:new, :create]
  before_filter :requires_update_authority, :only => [:edit, :update]
  before_filter :requires_delete_authority, :only => [:delete, :destroy]
  before_filter :set_new_external_link, :only => [:new, :create]

  def index
    @page_title = "#{@item.title}: External Links"
    #@external_links = paginate(@item.external_links)
    @external_links = @item.external_links
    @user = current_user
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @external_links }
    end
  end

  def show
    @page_title = "#{@item.title}: #{@external_link.title}"
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @external_link }
    end
  end

  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @external_link }
    end
  end

  def create
    respond_to do |format|
      if @external_link.save
        format.html { redirect_to([@item, @external_link], :notice => 'The external link has been saved.') }
        format.xml  { render :xml => @external_link, :status => :created, :location => @external_link }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @external_link.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @page_title = "Edit External Link: #{@external_link.title}"
  end

  def update
    @page_title = "Edit External Link: #{@external_link.title}"
    respond_to do |format|
      if @external_link.update_attributes(params[:external_link])
        format.html { redirect_to([@item, @external_link], :notice => 'The external link has been saved.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @external_link.errors, :status => :unprocessable_entity }
      end
    end
  end

  def delete
    @page_title = "Delete External Link: #{@external_link.title}"
  end

  def destroy
    @external_link.destroy
    respond_to do |format|
      format.html { redirect_to(@item) }
      format.xml  { head :ok }
    end
  end

  protected

  def set_user
    @user = current_user
  end

  # The actions for this controller, other than viewing, require login and usually authorization.
  def requires_login
    unless @user
      raise Wayground::LoginRequired
    end
  end
  def requires_authority(action)
    unless (
      (@external_link && @external_link.has_authority_for_user_to?(@user, action)) ||
      (@user && @user.has_authority_for_area(@external_link.authority_area, action))
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

  # all actions for this controller should have an item that the external link(s) are attached to.
  def set_item
    if params[:event_id].present?
      @item = Event.find(params[:event_id])
    end
  end

  # Most of the actions for this controller receive the id of an ExternalLink as a parameter.
  def set_external_link
    @external_link = @item.external_links.find(params[:id])
  end

  def set_new_external_link
    @page_title = 'New External Link'
    @external_link = @item.external_links.new(params[:external_link])
  end

end
