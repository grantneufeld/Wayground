# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user

  rescue_from ActiveRecord::RecordNotFound, :with => :missing
  rescue_from Wayground::AccessDenied, :with => :unauthorized


  protected

  # report that the requested url does not exist (missing - 404 error)
  # TODO: support params for missing (such as name of missing resource, e.g., "Group ID 123")
  def missing
    @page_title = '404 Missing'
    flash.now[:warning] ||= 'Requested page not found.'
    render :template => 'paths/missing', :status => '404 Missing'
  end

  # report that the user is not authorized
  def unauthorized
    @page_title = 'Unauthorized'
    flash.now[:warning] ||= 'You are not authorized for accessing the requested resource'
    browser_dont_cache
    render :template => 'authorities/unauthorized', :status => '403 Forbidden'
  end

  def browser_dont_cache
    @browser_nocache = true
  end


  private

  def current_user
    user_id = session[:user_id]
    @current_user ||= User.find(user_id) if user_id
  rescue ActiveRecord::RecordNotFound
    session[:user_id] = nil
  end
end
