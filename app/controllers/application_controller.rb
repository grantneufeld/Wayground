require 'user_token'
require 'rememberer'
require 'page_metadata'

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_user
  helper_method :page_metadata
  helper_method :add_submenu_item
  helper_method :page_submenu_items

  rescue_from ActiveRecord::RecordNotFound, with: :missing
  rescue_from Wayground::AccessDenied, with: :unauthorized
  rescue_from Wayground::LoginRequired, with: :login_required

  protected

  # report that the requested url does not exist (missing - 404 error)
  # TODO: support params for missing (such as name of missing resource, e.g., "Group ID 123")
  def missing
    page_metadata(title: '404 Missing', nocache: true)
    flash.now[:alert] ||= 'Requested page not found.'
    render template: 'paths/missing', status: '404 Missing'
  end

  # report that the user is not authorized
  def unauthorized
    page_metadata(title: 'Unauthorized', nocache: true)
    flash.now[:alert] ||= 'You are not authorized for accessing the requested resource'
    render template: 'authorities/unauthorized', status: '403 Forbidden'
  end

  # report that the user must sign in
  def login_required
    page_metadata(title: 'Sign In Required', nocache: true)
    flash.now[:alert] ||= 'You must sign in to access the requested resource'
    render template: 'authorities/login_required', status: '401 Unauthorized'
  end

  def page_metadata(params = {})
    if @page_metadata
      @page_metadata.merge_params(params)
    else
      @page_metadata = Wayground::PageMetadata.new(params)
    end
    @page_metadata
  end

  def add_submenu_item(params)
    @page_submenu_items ||= []
    @page_submenu_items << { title: params[:title], path: params[:path], attrs: params[:attrs] }
  end

  def page_submenu_items
    @page_submenu_items ||= []
  end

  # set the remember me cookie for a user’s session.
  # If `permanent`, set the cookie for the user to be re-logged-in across sessions
  def cookie_set_remember_me(user, permanent = false)
    if permanent
      cookies.permanent[:remember_token] = Wayground::Rememberer.new(remember: user).cookie_token
    else
      cookies[:remember_token] = Wayground::Rememberer.new(remember: user).cookie_token
    end
  end

  # Setup the pagination variables based on the params passed into the controller and the source class.
  # Returns the paginated items.
  # source: Must be an ActiveRecord-type relation (e.g., AREL) or ActiveRecord class.
  # @default_max: Normally defaults to 20, but can be overridden before calling this method.
  # @max: The maximum number of entries per page.
  # @pagenum: The page number (starting with page 1).
  # @source_total: The total number of items available from the source, without pagination.
  # @selected_total: The number of items being displayed on the page.
  def paginate(source)
    set_paginate_max
    @pagenum = pagenum_from_param(params[:page])
    @source_total = source.count
    items = source.limit(@max).offset((@pagenum - 1) * @max)
    @selected_total = items.size
    items
  end

  private

  def current_user
    @current_user ||= UserToken.from_cookie_token(cookies[:remember_token]).user
    cookies.delete(:remember_token) unless @current_user
    @current_user
  end

  attr_writer :current_user

  # determine which page number to use, for pagination
  def pagenum_from_param(page_param)
    pagenum = page_param
    if pagenum
      pagenum = pagenum.to_i
      pagenum = 1 if pagenum < 1
    end
    pagenum ||= 1
    pagenum
  end

  def set_paginate_max
    @default_max ||= 20
    @max = params[:max]
    @max = @max.to_i if @max
    @max ||= @default_max
  end
end
