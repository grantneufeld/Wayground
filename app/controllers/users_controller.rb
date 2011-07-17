# encoding: utf-8

# User registration and updating.
# Accessed by users as the singular resource “/account”,
# and by admins as the plural resources “/users”.
class UsersController < ApplicationController
  before_filter :set_user, :except => [:new, :create]
  before_filter :set_site_location, :except => [:show]
  before_filter :cant_be_signed_in, :only => [:new, :create]

  def profile
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      cookies[:remember_token] = @user.remember_token_hash
      if @user.admin?
        # an authority was created along with the user, so they must be an admin
        notice = "You are now registered as an administrator for this site."
      else
        notice = "You are now registered on this site."
      end
      redirect_to account_url, :notice => notice
    else
      @user.password = @user.password_confirmation = nil
      render "new"
    end
  end

  def confirm
    if @user.email_confirmed
      message = {:notice => "Your email address was already confirmed."}
    elsif @user.confirm_code!(params[:confirmation_code])
      message = {:notice => "Thank-you for confirming your email address."}
    else
      message = {:alert => "Invalid confirmation code. Your email has not been confirmed."}
    end
    redirect_to account_url, message
  rescue
    redirect_to account_url, :status => 500,
      :alert => "We are sorry. There was a problem while trying to update your information. Please try again or contact a system administrator."
  end


  protected

  def set_user
    @user = current_user
    if @user.nil?
      redirect_to signin_url, :status => 307,
        :notice => "You must be signed-in to access your account."
    ## TODO: support system admins having access to reviewing or modifying other users
    #elsif params[:id].present?
    #  if @user.admin?
    #    unless @user = User.find(params[:id])
    #      redirect_to users_url, :status => 404,
    #      :notice => "No such user (#{params[:id]})."
    #    end
    #  else
    #    redirect_to root_url, :status => 401,
    #    :alert => "You are not authorized to access other user’s accounts."
    #  end
    end
  end

  # Breadcrumbs for actions on this controller start with the index page.
  def set_site_location
    @site_breadcrumbs = [{:text => 'Users', :url => account_path}]
  end

  def cant_be_signed_in
    if current_user.present?
      redirect_to account_url, :notice => "You are already signed up."
    end
  end
end
