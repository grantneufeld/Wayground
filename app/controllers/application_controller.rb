# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
	protect_from_forgery

	helper_method :current_user


	private

	def current_user
		user_id = session[:user_id]
		@current_user ||= User.find(user_id) if user_id
	end
end
