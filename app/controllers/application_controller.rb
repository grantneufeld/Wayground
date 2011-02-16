class ApplicationController < ActionController::Base
	protect_from_forgery
	before_filter :set_locale
	
	
	# Internationalization based on http://guides.rubyonrails.org/i18n.html
	
	def set_locale
		# if params[:locale] is nil then I18n.default_locale will be used
		I18n.locale = params[:locale] || extract_locale_from_subdomain
	end

	# Get locale code from request subdomain (like http://fr.wayground.ca)
	# You have to put something like:
	#   127.0.0.1 fr.wayground.ca
	# in your /etc/hosts file to try this out locally
	def extract_locale_from_subdomain
		parsed_locale = request.subdomains.first
		I18n.available_locales.include?(parsed_locale.to_sym) ? parsed_locale  : nil
	end
end
