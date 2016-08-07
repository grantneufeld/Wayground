require 'party'
require 'level'

# RESTful controller for Party records.
# Called as a sub-controller under LevelsController
class PartiesController < ApplicationController
  before_action :set_user
  before_action :set_level
  before_action :set_party, only: [:show, :edit, :update, :delete, :destroy]
  before_action :prep_new, only: [:new, :create]
  before_action :prep_edit, only: [:edit, :update]
  before_action :prep_delete, only: [:delete, :destroy]
  before_action :set_section

  def index
    page_metadata(title: 'Parties')
    @parties = @level.parties
  end

  def show
    page_metadata(title: "Party “#{@party.name}”")
  end

  def new; end

  def create
    if @party.save
      redirect_to([@level, @party], notice: 'The party has been saved.')
    else
      render action: 'new'
    end
  end

  def edit; end

  def update
    if @party.update(party_params)
      redirect_to([@level, @party], notice: 'The party has been saved.')
    else
      render action: 'edit'
    end
  end

  def delete
    page_metadata(title: "Delete Party “#{@party.name}”")
  end

  def destroy
    @party.destroy
    redirect_to level_parties_url(@level)
  end

  protected

  def set_user
    @user = current_user
  end

  def set_level
    @level = Level.from_param(params[:level_id]).first
    missing unless @level
  end

  def set_party
    @party = @level.parties.from_param(params[:id]).first
    missing unless @party
  end

  def set_section
    @site_section = :parties
  end

  def prep_new
    requires_authority(:can_create)
    page_metadata(title: 'New Party')
    @party = @level.parties.build(party_params)
  end

  def prep_edit
    requires_authority(:can_update)
    page_metadata(title: "Edit Party “#{@party.name}”")
  end

  def prep_delete
    requires_authority(:can_delete)
  end

  def requires_authority(action)
    unless (
      (@party && @party.authority_for_user_to?(@user, action)) ||
      (@user && @user.authority_for_area(Party.authority_area, action))
    )
      unauthorized
    end
  end

  def party_params
    params.fetch(:party, {}).permit(
      :filename, :name, :aliases, :abbrev, :is_registered, :colour,
      :url, :description, :established_on, :registered_on, :ended_on
    )
  end
end
