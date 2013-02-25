# encoding: utf-8

class SettingsController < ApplicationController
  before_filter :set_setting, :except => [:initialize_defaults, :index, :new, :create]
  before_filter :requires_view_authority, :only => [:index, :show]
  before_filter :requires_create_authority, :only => [:initialize_defaults, :new, :create]
  before_filter :requires_update_authority, :only => [:edit, :update]
  before_filter :requires_delete_authority, :only => [:delete, :destroy]
  before_filter :set_section
  before_filter :set_new_setting, :only => [:new, :create]

  # Setup default Settings for the system as a whole.
  # Currently, just the global_start_date.
  def initialize_defaults
    Setting.set_defaults(
      {:global_start_date => Time.now.to_date}.merge((params[:settings] || {}))
    )
    flash.notice = 'Settings have been initialized to defaults (where not already set).'
    redirect_to settings_url
  end

  # GET /settings
  # GET /settings.xml
  def index
    @settings = Setting.all
    @page_title = "Settings"
  end

  # GET /settings/1
  # GET /settings/1.xml
  def show
    @page_title = "Setting: #{@setting.key}"
  end

  # GET /settings/new
  # GET /settings/new.xml
  def new
  end

  # POST /settings
  # POST /settings.xml
  def create
    if @setting.save
      redirect_to(@setting, notice: 'Setting was successfully created.')
    else
      render action: "new"
    end
  end

  # GET /settings/1/edit
  def edit
    @page_title = "Edit Setting: #{@setting.key}"
  end

  # PUT /settings/1
  # PUT /settings/1.xml
  def update
    if @setting.update_attributes(params[:setting])
      redirect_to(@setting, notice: 'Setting was successfully updated.')
    else
      @page_title = "Edit Setting: #{@setting.key}"
      render action: "edit"
    end
  end

  # GET /settings/1/delete
  def delete
    @page_title = "Delete Setting: #{@setting.key}"
  end

  # DELETE /settings/1
  # DELETE /settings/1.xml
  def destroy
    @setting.destroy
    redirect_to(settings_url, notice: "The setting for “#{@setting.key}” has been removed.")
  end

  protected

  # Most of the actions for this controller receive the id of a Setting as a parameter.
  def set_setting
    @setting = Setting.find(params[:id])
  end

  def requires_authority(action)
    user = current_user
    unless (
      (@setting && @setting.has_authority_for_user_to?(user, action)) ||
      (user && user.has_authority_for_area(Setting.authority_area, action))
    )
      raise Wayground::AccessDenied
    end
  end
  def requires_view_authority
    requires_authority(:can_view)
  end
  def requires_create_authority
    requires_authority(:can_create)
  end
  def requires_update_authority
    requires_authority(:can_update)
  end
  def requires_delete_authority
    requires_authority(:can_delete)
  end

  def set_section
    @site_section = :settings
  end

  def set_new_setting
    @page_title = 'New Setting'
    @setting = Setting.new(params[:setting])
  end
end
