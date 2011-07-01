# encoding: utf-8

class PagesController < ApplicationController
  before_filter :set_page, :except => [:index, :new, :create]
  before_filter :requires_create_authority, :only => [:new, :create]
  before_filter :requires_update_authority, :only => [:edit, :update]
  before_filter :requires_delete_authority, :only => [:delete, :destroy]
  before_filter :set_section
  before_filter :set_new_page, :only => [:new, :create]
  before_filter :set_editor, :only => [:create, :update, :destroy]

  # GET /pages
  # GET /pages.xml
  def index
    @page_title = 'Page Index'
    @pages = Page.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pages }
    end
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
    requires_authority(:can_view)
    @page_title = "Page “#{@page.title}”"
    @site_breadcrumbs = @page.breadcrumbs if @page.parent.present?
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /pages/new
  # GET /pages/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # POST /pages
  # POST /pages.xml
  def create
    respond_to do |format|
      if @page.save
        format.html { redirect_to(@page, :notice => 'Page was successfully created.') }
        format.xml  { render :xml => @page, :status => :created, :location => @page }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /pages/1/edit
  def edit
    @page_title = "Edit Page “#{@page.title}”"
  end

  # PUT /pages/1
  # PUT /pages/1.xml
  def update
    respond_to do |format|
      if @page.update_attributes(params[:page])
        format.html { redirect_to(@page, :notice => 'Page was successfully updated.') }
        format.xml  { head :ok }
      else
        @page_title = "Edit Page “#{@page.title}”"
        format.html { render :action => "edit" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /pages/1/delete
  def delete
    raise Wayground::AccessDenied unless current_user.has_authority_for_area('Content', :can_delete)
    @page_title = "Delete Page “#{@page.title}”"
  end

  # DELETE /pages/1
  # DELETE /pages/1.xml
  def destroy
    @page.destroy

    respond_to do |format|
      format.html { redirect_to(pages_url) }
      format.xml  { head :ok }
    end
  end

  protected

  # The actions for this controller, other than viewing, require authorization.
  def requires_authority(action)
    unless (
      (@page && @page.has_authority_for_user_to?(current_user, action)) ||
      (current_user && current_user.has_authority_for_area(Page.authority_area, action))
    )
      raise Wayground::AccessDenied
    end
  end
  def requires_create_authority
    requires_authority(:can_create)
  end
  def requires_update_authority
    requires_authority(:can_update)
  end
  def requires_delete_authority
    requires_authority(:can_delete)
  end

  def set_section
    @site_section = 'Pages'
  end

  # Most of the actions for this controller receive the id of an Authority as a parameter.
  def set_page
    @page = Page.find(params[:id])
  end

  def set_new_page
    @page_title = 'New Page'
    @page = Page.new(params[:page])
    if params[:parent].present?
      @page.parent = Page.find(params[:parent])
      @site_breadcrumbs = @page.breadcrumbs
    end
  end

  def set_editor
    @page.editor = current_user
  end
end
