# Manage “static” Pages.
class PagesController < ApplicationController
  before_action :set_page, except: [:index, :new, :create]
  before_action :requires_create_authority, only: [:new, :create]
  before_action :requires_update_authority, only: [:edit, :update]
  before_action :requires_delete_authority, only: [:delete, :destroy]
  before_action :set_section
  before_action :set_new_page, only: [:new, :create]
  before_action :set_editor, only: [:create, :update, :destroy]

  # GET /pages
  # GET /pages.xml
  def index
    page_metadata(title: 'Page Index')
    @pages = paginate(Page)
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
    requires_authority(:can_view)
    page_metadata(title: "Page “#{@page.title}”", description: @page.description)
    @site_breadcrumbs = @page.breadcrumbs if @page.parent.present?
  end

  # GET /pages/new
  # GET /pages/new.xml
  def new
  end

  # POST /pages
  # POST /pages.xml
  def create
    if @page.save
      redirect_to(@page, notice: 'Page was successfully created.')
    else
      render action: "new"
    end
  end

  # GET /pages/1/edit
  def edit
    page_metadata(title: "Edit Page “#{@page.title}”")
  end

  # PUT /pages/1
  # PUT /pages/1.xml
  def update
    if @page.update(params[:page])
      redirect_to(@page, notice: 'Page was successfully updated.')
    else
      page_metadata(title: "Edit Page “#{@page.title}”")
      render action: "edit"
    end
  end

  # GET /pages/1/delete
  def delete
    raise Wayground::AccessDenied unless current_user.has_authority_for_area('Content', :can_delete)
    page_metadata(title: "Delete Page “#{@page.title}”")
  end

  # DELETE /pages/1
  # DELETE /pages/1.xml
  def destroy
    @page.destroy
    redirect_to(pages_url)
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
    @site_section = :pages
  end

  # Most of the actions for this controller receive the id of a Page as a parameter.
  def set_page
    @page = Page.find(params[:id])
  end

  def set_new_page
    page_metadata(title: 'New Page')
    @page = Page.new(params[:page])
    parent_id = params[:parent]
    if parent_id.present?
      @page.parent = Page.find(parent_id)
      @site_breadcrumbs = @page.breadcrumbs
    end
  end

  def set_editor
    @page.editor = current_user
  end
end
