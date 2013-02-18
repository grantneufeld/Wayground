# encoding: utf-8
require 'login/password_login'
require 'authentication'

# Actions for the user to sign-in or sign-out (establish/clear the user session).
class SessionsController < ApplicationController
  before_filter :cant_be_signed_in, :only => [:new, :create]
  before_filter :must_be_signed_in, :only => [:delete, :destroy]

  def new
  end

  def create
    login = Wayground::Login::PasswordLogin.new(username: params[:email], password: params[:password])
    user = login.user
    if user
      if params[:remember_me] == '1'
        cookie_set_remember_me_permanent(user)
      else
        cookie_set_remember_me(user)
      end
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
    cookies.delete(:remember_token)
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
      user = authentication.user
      notice = "You are now registered on this site."
    else # signed in
      user = authentication.user
      notice = "You are now signed in."
    end
    cookie_set_remember_me(user)
    session[:source] = authentication.provider
    redirect_to end_up_at_url, only_path: true, notice: notice
  rescue Wayground::WrongUserForAuthentication
    redirect_to(end_up_at_url, only_path: true,
      alert: "ERROR: The authentication failed because the requested authentication is unavailable!"
    )
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
