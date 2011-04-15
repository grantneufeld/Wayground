# encoding: utf-8

class PagesController < ApplicationController
  before_filter :requires_authority, :except => [:index]
  before_filter :set_page, :except => [:index, :new, :create]
  before_filter :set_breadcrumbs, :except => [:index]

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
    @page_title = "Page “#{@page.title}”"
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /pages/new
  # GET /pages/new.xml
  def new
    @page_title = 'New Page'
    @page = Page.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # POST /pages
  # POST /pages.xml
  def create
    @page_title = 'New Page'
    @page = Page.new(params[:page])

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
    @page_title = "Edit Page “#{@page.title}”"
    respond_to do |format|
      if @page.update_attributes(params[:page])
        format.html { redirect_to(@page, :notice => 'Page was successfully updated.') }
        format.xml  { head :ok }
      else
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

  # The actions for this controller all require that the user is authorized to view Authority records.
  def requires_authority
    unless current_user && current_user.has_authority_for_area(Page.authority_area)
      raise Wayground::AccessDenied
    end
  end

  # Most of the actions for this controller receive the id of an Authority as a parameter.
  def set_page
    @page = Page.find(params[:id])
  end

  # Breadcrumbs for actions on this controller start with the index page.
  def set_breadcrumbs
    @site_breadcrumbs = [{:text => 'Pages', :url => pages_path}]
  end
end
