# encoding: utf-8

# Actions for the user to sign-in or sign-out (establish/clear the user session).
class SessionsController < ApplicationController
	before_filter :cant_be_signed_in, :only => [:new, :create]
	before_filter :must_be_signed_in, :only => [:delete, :destroy]

	def new
	end

	def create
		user = User.authenticate(params[:email], params[:password])
		if user
			session[:user_id] = user.id
			session[:source] = nil
			redirect_to root_url, :notice => "You are now signed in."
		else
			flash.now.alert = "Wrong email or password"
			render "new"
		end
	end

	# presents a confirmation form for logging out when user isn’t able to use javascript
	def delete
	end

	def destroy
		session[:user_id] = nil
		session[:source] = nil
		redirect_to root_url, :notice => "You are now signed out."
	end

	def oauth_callback
		auth = request.env["omniauth.auth"]
		user = current_user
		end_up_at_url = request.env['omniauth.origin'] || account_url
		authentication = Authentication.authenticate_callback!(auth, user)
		if user.present? # added an authentication to the user
			notice = "Added authentication from #{auth['provider']}."
		elsif authentication.new_user? # created a new user
			notice = "You are now registered on this site."
		else # signed in
			notice = "You are now signed in."
		end
		session[:user_id] = authentication.user_id
		session[:source] = authentication.provider
		redirect_to end_up_at_url, :notice => notice
	rescue Wayground::WrongUserForAuthentication
		redirect_to end_up_at_url, :alert => "ERROR: The authentication failed because the requested authentication is already assigned to a different account!"
	end


	protected

	def cant_be_signed_in
		if current_user.present?
			redirect_to account_url, :notice => "You are already signed in."
		end
	end

	def must_be_signed_in
		if current_user.nil?
			redirect_to signin_url, :notice => "You are not signed in."
		end
	end
end
