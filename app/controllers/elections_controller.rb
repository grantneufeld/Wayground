# encoding: utf-8
require 'election'
require 'level'

# RESTful controller for Election records.
# Called as a sub-controller under LevelsController
class ElectionsController < ApplicationController
  before_action :set_user
  before_action :set_level
  before_action :set_election, only: [:show, :edit, :update, :delete, :destroy]
  before_action :prep_new, only: [:new, :create]
  before_action :prep_edit, only: [:edit, :update]
  before_action :prep_delete, only: [:delete, :destroy]
  before_action :set_section

  def index
    page_metadata(title: 'Elections')
    @elections = @level.elections
  end

  def show
    page_metadata(title: "Election “#{@election.name}”")
  end

  def new; end

  def create
    if @election.save
      redirect_to([@level, @election], notice: 'The election has been saved.')
    else
      render action: 'new'
    end
  end

  def edit; end

  def update
    if @election.update(params[:election])
      redirect_to([@level, @election], notice: 'The election has been saved.')
    else
      render action: 'edit'
    end
  end

  def delete
    page_metadata(title: "Delete Election “#{@election.name}”")
  end

  def destroy
    @election.destroy
    redirect_to level_elections_url(@level)
  end

  protected

  def set_user
    @user = current_user
  end

  def set_level
    @level = Level.from_param(params[:level_id]).first
    missing unless @level
  end

  def set_election
    @election = @level.elections.from_param(params[:id]).first
    missing unless @election
  end

  def set_section
    @site_section = :elections
  end

  def prep_new
    requires_authority(:can_create)
    page_metadata(title: 'New Election')
    @election = @level.elections.build(params[:election])
  end

  def prep_edit
    requires_authority(:can_update)
    page_metadata(title: "Edit Election “#{@election.name}”")
  end

  def prep_delete
    requires_authority(:can_delete)
  end

  def requires_authority(action)
    unless (
      (@election && @election.has_authority_for_user_to?(@user, action)) ||
      (@user && @user.has_authority_for_area(Election.authority_area, action))
    )
      raise Wayground::AccessDenied
    end
  end

end
