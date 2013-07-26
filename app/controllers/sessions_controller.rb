# encoding: utf-8
require 'login/password_login'
require 'login/oauth_login'
require 'authentication'

# Actions for the user to sign-in or sign-out (establish/clear the user session).
class SessionsController < ApplicationController
  before_action :cant_be_signed_in, only: [:new, :create]
  before_action :must_be_signed_in, only: [:delete, :destroy]

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
    env = request.env
    login = Wayground::Login::OauthLogin.new(current_user: current_user, auth: env["omniauth.auth"])
    user = login.user
    self.current_user = user
    cookie_set_remember_me(user)
    provider = login.authentication.provider
    session[:source] = provider
    end_up_at_url = env['omniauth.origin'] || account_url
    redirect_to end_up_at_url, only_path: true, notice: "You are now signed in via #{provider}."
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
