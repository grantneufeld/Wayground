# Access Items and redirects by arbitrary url paths.
class PathsController < ApplicationController
  before_action :set_path, except: %i(sitepath index new create)
  before_action :requires_view_authority, only: [:show]
  before_action :requires_create_authority, only: %i(new create)
  before_action :requires_update_authority, only: %i(edit update)
  before_action :requires_delete_authority, only: %i(delete destroy)
  before_action :set_breadcrumbs, except: %i(sitepath index)
  before_action :set_new, only: %i(new create)
  before_action :set_edit, only: %i(edit update)

  # process arbitrary paths
  def sitepath
    sitepath = params[:url].to_s
    @path = Path.find_for_path(sitepath)
    if !@path
      missing unless sitepath == '/'
      page_metadata(title: Wayground::Application::NAME, description: Wayground::Application::DESCRIPTION)
      render template: 'paths/default_home'
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

  def index
    page_metadata(title: 'Custom Paths')
    @paths = paginate(Path.for_user(current_user))
  end

  def show
    page_metadata(title: "Custom Path: #{@path.sitepath}")
  end

  def new; end

  def create
    if @path.save
      redirect_to(@path, notice: 'Path was successfully created.')
    else
      render action: 'new'
    end
  end

  def edit; end

  def update
    if @path.update(path_params)
      redirect_to(@path, notice: 'Path was successfully updated.')
    else
      render action: 'edit'
    end
  end

  def delete
    page_metadata(title: "Delete Custom Path: #{@path.sitepath}")
  end

  def destroy
    @path.destroy
    redirect_to(paths_url)
  end

  protected

  # The actions for this controller, except for viewing, require that the user is authorized.
  def requires_authority(action)
    path_allowed = @path && @path.has_authority_for_user_to?(current_user, action)
    unless path_allowed || (current_user && current_user.has_authority_for_area(Path.authority_area, action))
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
    @site_breadcrumbs = [{ text: 'Paths', url: paths_path }]
  end

  def set_new
    page_metadata(title: 'New Custom Path')
    @path = Path.new(path_params)
  end

  def set_edit
    page_metadata(title: "Edit Custom Path: #{@path.sitepath}")
  end

  def render_path_item(item)
    # TODO: handle security-access for private items
    if item.is_a? Page
      render_item_as_page(item)
    # TODO: handle use of Paths for items other than Pages
    # elsif item.is_a? ???
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

  def path_params
    params.fetch(:path, {}).permit(:sitepath, :redirect)
  end
end
