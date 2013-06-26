# encoding: utf-8

class PathsController < ApplicationController
  before_action :set_path, except: [:sitepath, :index, :new, :create]
  before_action :requires_view_authority, only: [:show]
  before_action :requires_create_authority, only: [:new, :create]
  before_action :requires_update_authority, only: [:edit, :update]
  before_action :requires_delete_authority, only: [:delete, :destroy]
  before_action :set_breadcrumbs, except: [:sitepath, :index]
  before_action :set_new, only: [:new, :create]
  before_action :set_edit, only: [:edit, :update]

  # process arbitrary paths
  def sitepath
    sitepath = params[:url].to_s
    @path = Path.find_for_path(sitepath)
    if @path.nil?
      if sitepath == '/'
        page_metadata(title: Wayground::Application::NAME, description: Wayground::Application::DESCRIPTION)
        render template: 'paths/default_home'
      else
        missing
      end
    elsif @path.redirect?
      redirect_to @path.redirect
    else
      requires_view_authority
      render_path_item(@path.item)
    end
  rescue Wayground::AccessDenied
    # don’t reveal to unauthorized users that an item exists if it is access controlled
    missing
  end

  # GET /paths
  # GET /paths.xml
  def index
    page_metadata(title: 'Custom Paths')
    @paths = paginate(Path.for_user(current_user))
  end

  # GET /paths/1
  # GET /paths/1.xml
  def show
    page_metadata(title: "Custom Path: #{@path.sitepath}")
  end

  # GET /paths/new
  # GET /paths/new.xml
  def new
  end

  # POST /paths
  # POST /paths.xml
  def create
    if @path.save
      redirect_to(@path, notice: 'Path was successfully created.')
    else
      render action: "new"
    end
  end

  # GET /paths/1/edit
  def edit
  end

  # PUT /paths/1
  # PUT /paths/1.xml
  def update
    if @path.update_attributes(params[:path])
      redirect_to(@path, notice: 'Path was successfully updated.')
    else
      render action: "edit"
    end
  end

  # GET /paths/1/delete
  def delete
    page_metadata(title: "Delete Custom Path: #{@path.sitepath}")
  end

  # DELETE /paths/1
  # DELETE /paths/1.xml
  def destroy
    @path.destroy
    redirect_to(paths_url)
  end

  protected

  # The actions for this controller, except for viewing, require that the user is authorized.
  def requires_authority(action)
    unless (
      (@path && @path.has_authority_for_user_to?(current_user, action)) ||
      (current_user && current_user.has_authority_for_area(Path.authority_area, action))
    )
      raise Wayground::AccessDenied
    end
  end
  def requires_view_authority
    requires_authority(:can_view)
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

  # Most of the actions for this controller receive the id of a Path as a parameter.
  def set_path
    @path = Path.find(params[:id])
  end

  # Breadcrumbs for actions on this controller start with the index page.
  def set_breadcrumbs
    @site_breadcrumbs = [{:text => 'Paths', :url => paths_path}]
  end

  def set_new
    page_metadata(title: 'New Custom Path')
    @path = Path.new(params[:path])
  end

  def set_edit
    page_metadata(title: "Edit Custom Path: #{@path.sitepath}")
  end

  def render_path_item(item)
    # TODO: handle security-access for private items
    if item.is_a? Page
      render_item_as_page(item)
    # TODO: handle use of Paths for items other than Pages
    #elsif item.is_a? ???
    else
      render template: 'paths/unimplemented', status: '501 Not Implemented'
    end
  end

  def render_item_as_page(item)
      @page = item
      page_metadata(title: @page.title, description: @page.description)
      @site_breadcrumbs = @page.breadcrumbs
      render template: 'paths/page'
  end
end
