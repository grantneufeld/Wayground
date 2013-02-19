# encoding: utf-8
require 'user_token'
require 'rememberer'

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user

  rescue_from ActiveRecord::RecordNotFound, :with => :missing
  rescue_from Wayground::AccessDenied, :with => :unauthorized
  rescue_from Wayground::LoginRequired, :with => :login_required


  protected

  # report that the requested url does not exist (missing - 404 error)
  # TODO: support params for missing (such as name of missing resource, e.g., "Group ID 123")
  def missing
    @page_title = '404 Missing'
    flash.now[:alert] ||= 'Requested page not found.'
    render :template => 'paths/missing', :status => '404 Missing'
  end

  # report that the user is not authorized
  def unauthorized
    @page_title = 'Unauthorized'
    flash.now[:alert] ||= 'You are not authorized for accessing the requested resource'
    browser_dont_cache
    render :template => 'authorities/unauthorized', :status => '403 Forbidden'
  end

  # report that the user must sign in
  def login_required
    @page_title = 'Sign In Required'
    flash.now[:alert] ||= 'You must sign in to access the requested resource'
    browser_dont_cache
    render :template => 'authorities/login_required', :status => '403 Forbidden'
  end

  def browser_dont_cache
    @browser_nocache = true
  end

  # set the remember me cookie for a user’s session
  def cookie_set_remember_me(user)
    cookies[:remember_token] = Wayground::Rememberer.new(remember: user).cookie_token
  end

  # set the remember me cookie for the user to be re-logged-in across sessions
  def cookie_set_remember_me_permanent(user)
    cookies.permanent[:remember_token] = Wayground::Rememberer.new(remember: user).cookie_token
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
    @default_max ||= 20
    @max = params[:max].to_i if params[:max].present?
    @max ||= @default_max
    @pagenum = params[:page].to_i if params[:page].present?
    @pagenum ||= 1
    @pagenum = 1 if @pagenum < 1
    @source_total = source.count
    items = source.limit(@max).offset((@pagenum - 1) * @max).all
    @selected_total = items.size
    items
  end


  private

  def current_user
    @current_user ||= UserToken.from_cookie_token(cookies[:remember_token]).user
    cookies.delete(:remember_token) unless @current_user
    @current_user
  end

  def current_user=(user)
    @current_user = user
  end
end
