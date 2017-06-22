require 'login/password_login'
require 'login/oauth_login'
require 'authentication'

# Actions for the user to sign-in or sign-out (establish/clear the user session).
class SessionsController < ApplicationController
  before_action :cant_be_signed_in, only: %i[new create]
  before_action :must_be_signed_in, only: %i[delete destroy]

  def new; end

  def create
    login = Wayground::Login::PasswordLogin.new(username: params[:email], password: params[:password])
    user = login.user
    if user
      create_session(user)
    else
      flash.now.alert = 'Wrong email or password'
      render 'new'
    end
  end

  def create_session(user)
    cookie_set_remember_me(user, params[:remember_me] == '1')
    session[:source] = nil
    redirect_to root_url, notice: 'You are now signed in.'
  end

  # presents a confirmation form for logging out when user isn’t able to use javascript
  def delete; end

  def destroy
    cookies.delete(:remember_token)
    session[:source] = nil
    redirect_to root_url, notice: 'You are now signed out.'
  end

  def oauth_callback
    env = request.env
    login = Wayground::Login::OauthLogin.new(current_user: current_user, auth: env['omniauth.auth'])
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
    redirect_to account_url, notice: 'You are already signed in.' if current_user.present?
  end

  def must_be_signed_in
    redirect_to signin_url, notice: 'You are not signed in.' unless current_user
  end
end
