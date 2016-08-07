require 'external_link'
require 'event'
require 'level'

# This controller must always be a sub-controller (e.g., /events/:event_id/external_links).
class ExternalLinksController < ApplicationController
  before_action :set_user
  before_action :set_item
  before_action :set_external_link, except: %i(index new create)
  before_action :requires_create_authority, only: %i(new create)
  before_action :requires_update_authority, only: %i(edit update)
  before_action :requires_delete_authority, only: %i(delete destroy)
  before_action :set_new_external_link, only: %i(new create)

  def index
    page_metadata(title: "#{@item.descriptor}: External Links")
    @external_links = @item.external_links
    @user = current_user
  end

  def show
    page_metadata(title: "#{@item.descriptor}: #{@external_link.title}")
  end

  def new
  end

  def create
    if @external_link.save
      redirect_to(@external_link.items_for_path, notice: 'The external link has been saved.')
    else
      render action: 'new'
    end
  end

  def edit
    page_metadata(title: "Edit External Link: #{@external_link.title}")
  end

  def update
    page_metadata(title: "Edit External Link: #{@external_link.title}")
    if @external_link.update(external_link_params)
      redirect_to(@external_link.items_for_path, notice: 'The external link has been saved.')
    else
      render action: 'edit'
    end
  end

  def delete
    page_metadata(title: "Delete External Link: #{@external_link.title}")
  end

  def destroy
    @external_link.destroy
    redirect_to(@item.items_for_path)
  end

  protected

  def set_user
    @user = current_user
  end

  # The actions for this controller, other than viewing, require authorization.
  def requires_authority(action)
    link_allowed = @external_link && @external_link.authority_for_user_to?(@user, action)
    unless link_allowed || item_allowed(action) || link_item_allowed(action) || links_allowed(action)
      raise Wayground::AccessDenied
    end
  end

  def item_allowed(action)
    !@external_link && @item && @item.authority_for_user_to?(@user, action)
  end

  def link_item_allowed(action)
    @user && @external_link && @user.authority_for_area(@external_link.authority_area, action)
  end

  def links_allowed(action)
    @user && @user.authority_for_area(ExternalLink.authority_area, action)
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

  # all actions for this controller should have an item that the external link(s) are attached to.
  def set_item
    level = Level.from_param(params[:level_id]).first if params[:level_id]
    office = level.offices.from_param(params[:ballot_id]).first if params[:ballot_id]
    item_from_param(level, office)
    item_from_event unless @item
    missing unless @item
  end

  def item_from_param(level, office)
    if params[:candidate_id]
      item_from_candidate(level, office)
    elsif params[:ballot_id]
      item_from_ballot(level, office)
    elsif params[:office_id]
      @item = level.offices.from_param(params[:office_id]).first
    end
  end

  def item_from_candidate(level, office)
    election = level.elections.from_param(params[:election_id]).first
    ballot = election.ballots.where(office_id: office.id).first
    @item = ballot.candidates.from_param(params[:candidate_id]).first
  end

  def item_from_ballot(level, office)
    election = level.elections.from_param(params[:election_id]).first
    @item = election.ballots.where(office_id: office.id).first
  end

  def item_from_event
    event_id = params[:event_id]
    @item = Event.find(event_id) if event_id.present?
  end

  # Most of the actions for this controller receive the id of an ExternalLink as a parameter.
  def set_external_link
    @external_link = @item.external_links.find(params[:id])
    missing unless @external_link
  end

  def set_new_external_link
    page_metadata(title: 'New External Link')
    @external_link = @item.external_links.build(external_link_params)
  end

  def external_link_params
    params.fetch(:external_link, {}).permit(:title, :url)
  end
end
