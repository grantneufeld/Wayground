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
		redirect_to root_url, :notice => "You are now signed out."
	end


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
