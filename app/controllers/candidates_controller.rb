# encoding: utf-8
require 'ballot'
require 'democracy/candidate_form'

# RESTful controller for Candidate records.
# Called as a sub-controller under ElectionsController
class CandidatesController < ApplicationController
  before_filter :set_user
  before_filter :set_level
  before_filter :set_election
  before_filter :set_ballot
  before_filter :set_candidate, only: [:show, :edit, :update, :delete, :destroy]
  before_filter :prep_new, only: [:new, :create]
  before_filter :prep_edit, only: [:edit, :update]
  before_filter :prep_delete, only: [:delete, :destroy]
  before_filter :set_section

  def index
    page_metadata(title: 'Candidates')
    @candidates = @ballot.candidates
  end

  def show
    page_metadata(title: "Candidate for “#{@office.name}”")
  end

  def new; end

  def create
    if @candidate_form.save
      redirect_to([@level, @election, @ballot, @candidate], notice: 'The candidate has been saved.')
    else
      render action: 'new'
    end
  end

  def edit; end

  def update
    if @candidate_form.save
      redirect_to([@level, @election, @ballot, @candidate], notice: 'The candidate has been saved.')
    else
      render action: 'edit'
    end
  end

  def delete
    page_metadata(title: "Delete Candidate for “#{@office.name}”")
  end

  def destroy
    @candidate.destroy
    redirect_to level_election_ballot_candidates_url(@level, @election, @ballot)
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
    @office = @level.offices.from_param(params[:ballot_id]).first
    missing unless @office
    @ballot = @election.ballots.where(office_id: @office.id).first
    missing unless @ballot
  end

  def set_candidate
    @candidate = @ballot.candidates.from_param(params[:id]).first
    missing unless @candidate
  end

  def prep_new
    requires_authority(:can_create)
    page_metadata(title: 'New Candidate')
    @candidate_form = Wayground::Democracy::CandidateForm.new
    @candidate_form.ballot = @ballot
    if params[:person_id]
      @person = Person.from_param(params[:person_id]).first
      @candidate_form.person = @person
    end
    @candidate_form.attributes = params[:wayground_democracy_candidate_form]
  end

  def prep_edit
    requires_authority(:can_update)
    page_metadata(title: "Edit Candidate for “#{@office.name}”")
    @candidate_form = Wayground::Democracy::CandidateForm.new
    @candidate_form.candidate = @candidate
    @candidate_form.attributes = params[:wayground_democracy_candidate_form]
  end

  def prep_delete
    requires_authority(:can_delete)
  end

  def set_section
    @site_section = :candidates
  end

  def requires_authority(action)
    unless (
      (@candidate && @candidate.has_authority_for_user_to?(@user, action)) ||
      (@user && @user.has_authority_for_area(Candidate.authority_area, action))
    )
      raise Wayground::AccessDenied
    end
  end

end
