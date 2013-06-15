# encoding: utf-8
require 'level'

class LevelsController < ApplicationController
  before_filter :set_user
  before_filter :set_level, only: [:show, :edit, :update, :delete, :destroy]
  before_filter :prep_new, only: [:new, :create]
  before_filter :prep_edit, only: [:edit, :update]
  before_filter :prep_delete, only: [:delete, :destroy]
  before_filter :set_section

  def index
    page_metadata(title: 'Levels')
    @levels = Level.all
  end

  def show
    page_metadata(title: 'Level' + (@level.name? ? " “#{@level.name}”" : ''))
  end

  #def new; end

  def create
    if @level.save
      redirect_to(@level, notice: 'The level has been saved.')
    else
      render action: 'new'
    end
  end

  #def edit; end

  def update
    if @level.update_attributes(params[:level])
      redirect_to(@level, notice: 'The level has been saved.')
    else
      render action: 'edit'
    end
  end

  def delete
    page_metadata(title: "Delete Level “#{@level.name}”")
  end

  def destroy
    @level.destroy
    redirect_to levels_url
  end

  protected

  def set_user
    @user = current_user
  end

  def set_level
    @level = Level.from_param(params[:id]).first
  end

  def set_section
    @site_section = :levels
  end

  def prep_new
    requires_authority(:can_create)
    page_metadata(title: 'New Level')
    @level = Level.new(params[:level])
    if params[:parent_id]
      @level.parent = Level.from_param(params[:parent_id]).first
    end
  end

  def prep_edit
    requires_authority(:can_update)
    page_metadata(title: "Edit Level “#{@level.name}”")
  end

  def prep_delete
    requires_authority(:can_delete)
  end

  def requires_authority(action)
    unless (
      (@level && @level.has_authority_for_user_to?(@user, action)) ||
      (@user && @user.has_authority_for_area(Level.authority_area, action))
    )
      raise Wayground::AccessDenied
    end
  end

end
