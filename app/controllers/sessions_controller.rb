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
		authentication, auth_user = Authentication.authenticate(auth, user)
		if authentication
			# found an authentication, so sign in
			notice = "You are now signed in."
		else
			authentication, auth_user = Authentication.create_with_auth!(auth, user)
			if user
				# added authentication to already signed in user
				notice = "Added authentication from #{auth['provider']}."
			else
				# created a new user
				notice = "You are now registered on this site."
			end
		end
		session[:user_id] = auth_user.id
		session[:source] = authentication.provider
		redirect_to end_up_at_url, :notice => notice
	rescue Wayground::WrongUserForAuthentication
		redirect_to end_up_at_url, :alert => "ERROR: The authentication failed because the requested authentication is already assigned to a different account!"
	end

	## if this actually gets called, we have an OmniAuth failure
	#def blank
	#	render :text => "Not found. (OmniAuth routing failure.)", :status => 404
	#end


	protected

	def cant_be_signed_in
		if current_user.present?
			redirect_to account_url, :notice => "You are already signed in."
		end
	end

	def must_be_signed_in
		if current_user.nil?
			redirect_to sign_in_url, :notice => "You are not signed in."
		end
	end
end
