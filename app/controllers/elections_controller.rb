require 'election'
require 'level'
require 'democracy/election_builder'

# RESTful controller for Election records.
# Called as a sub-controller under LevelsController
class ElectionsController < ApplicationController
  before_action :set_user
  before_action :set_level
  before_action :set_election, except: %i(index new create)
  before_action :prep_new, only: %i(new create)
  before_action :prep_edit, only: %i(edit update)
  before_action :prep_delete, only: %i(delete destroy)
  before_action :prep_generate, only: %i(ballot_maker generate_ballots)
  before_action :set_section

  def index
    page_metadata(title: 'Elections')
    @elections = @level.elections
  end

  def show
    page_metadata(title: "#{@election.descriptor}, #{@level.descriptor}")
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
    if @election.update(election_params)
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

  def ballot_maker
    page_metadata(title: "Generate Ballots for “#{@election.name}”")
  end

  def generate_ballots
    page_metadata(title: "Generate Ballots for “#{@election.descriptor}”")
    term_start_on = try_date(params[:term_start_on])
    term_end_on = try_date(params[:term_end_on])
    builder = Wayground::Democracy::ElectionBuilder.new(
      election: @election, term_start_on: term_start_on, term_end_on: term_end_on
    )
    @ballots = builder.generate_ballots
  end

  protected

  def try_date(param)
    Date.parse(param)
  rescue
    nil
  end

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
    @election = @level.elections.build(election_params)
  end

  def prep_edit
    requires_authority(:can_update)
    page_metadata(title: "Edit Election “#{@election.name}”")
  end

  def prep_delete
    requires_authority(:can_delete)
  end

  def prep_generate
    requires_authority(:can_create)
  end

  def requires_authority(action)
    authority = @election && @election.authority_for_user_to?(@user, action)
    unauthorized unless authority || (@user && @user.authority_for_area(Election.authority_area, action))
  end

  def election_params
    params.fetch(:election, {}).permit(:filename, :name, :start_on, :end_on, :url, :description)
  end
end