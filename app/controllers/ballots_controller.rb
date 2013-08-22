# encoding: utf-8
require 'ballot'
require 'election'

# RESTful controller for Ballot records.
# Called as a sub-controller under ElectionsController
class BallotsController < ApplicationController
  before_action :set_user
  before_action :set_level
  before_action :set_election
  before_action :set_ballot, only: [:show, :edit, :update, :delete, :destroy]
  before_action :prep_new, only: [:new, :create]
  before_action :prep_edit, only: [:edit, :update]
  before_action :prep_delete, only: [:delete, :destroy]
  before_action :set_section

  def index
    page_metadata(title: 'Ballots')
    @ballots = @election.ballots
  end

  def show
    page_metadata(title: "Ballot for “#{@office.name}”")
    @candidates = @ballot.candidates
  end

  def new; end

  def create
    if @ballot.save
      redirect_to([@level, @election, @ballot], notice: 'The ballot has been saved.')
    else
      render action: 'new'
    end
  end

  def edit; end

  def update
    if @ballot.update(params[:ballot])
      redirect_to([@level, @election, @ballot], notice: 'The ballot has been saved.')
    else
      render action: 'edit'
    end
  end

  def delete
    page_metadata(title: "Delete Ballot for “#{@office.name}”")
  end

  def destroy
    @ballot.destroy
    redirect_to level_election_ballots_url(@level, @election)
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
    @election = @level.elections.from_param(params[:election_id]).first
    missing unless @election
  end

  def set_ballot
    # ballot inherits its filename from office
    @office = @level.offices.from_param(params[:id]).first
    missing unless @office
    @ballot = @election.ballots.where(office_id: @office.id).first
    missing unless @ballot
  end

  def prep_new
    requires_authority(:can_create)
    page_metadata(title: 'New Ballot')
    @ballot = @election.ballots.build(params[:ballot])
    @offices = @level.offices
    @office_id = params[:office_id]
    @ballot.office = Office.from_param(@office_id).first if @office_id
  end

  def prep_edit
    requires_authority(:can_update)
    page_metadata(title: "Edit Ballot for “#{@office.name}”")
  end

  def prep_delete
    requires_authority(:can_delete)
  end

  def set_section
    @site_section = :ballots
  end

  def requires_authority(action)
    unless (
      (@ballot && @ballot.has_authority_for_user_to?(@user, action)) ||
      (@user && @user.has_authority_for_area(Ballot.authority_area, action))
    )
      raise Wayground::AccessDenied
    end
  end

end
