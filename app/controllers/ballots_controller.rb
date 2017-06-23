require 'ballot'
require 'election'

# RESTful controller for Ballot records.
# Called as a sub-controller under ElectionsController
class BallotsController < ApplicationController
  before_action :set_user
  before_action :set_level
  before_action :set_election
  before_action :set_ballot, only: %i[show edit update delete destroy]
  before_action :prep_new, only: %i[new create]
  before_action :prep_edit, only: %i[edit update]
  before_action :prep_delete, only: %i[delete destroy]
  before_action :set_section

  def index
    page_metadata(
      title: "Candidates for #{@level.name} #{@election.descriptor}",
      description:
        'Listings of citizen and voter resources about of ballots and ' \
        "candidates for #{@election.descriptor} in #{@level.name}."
    )
    @ballots = @election.ballots
  end

  def show
    page_metadata(title: "#{@office.name} candidates in #{@election.descriptor}")
    @candidates = @ballot.candidates.running
    @candidates_who_quit = @ballot.candidates.not_running
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
    if @ballot.update(ballot_params)
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
    @ballot = @election.ballots.build(ballot_params)
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
    authority = @ballot && @ballot.authority_for_user_to?(@user, action)
    unauthorized unless authority || (@user && @user.authority_for_area(Ballot.authority_area, action))
  end

  def ballot_params
    params.fetch(:ballot, {}).permit(
      :position, :section, :term_start_on, :term_end_on, :is_byelection, :url, :description
    )
  end
end
