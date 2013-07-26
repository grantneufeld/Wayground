# encoding: utf-8

# This controller must always be a sub-controller (e.g., /events/:event_id/external_links).
class ExternalLinksController < ApplicationController
  before_action :set_user
  before_action :set_item
  before_action :set_external_link, except: [:index, :new, :create]
  before_action :requires_create_authority, only: [:new, :create]
  before_action :requires_update_authority, only: [:edit, :update]
  before_action :requires_delete_authority, only: [:delete, :destroy]
  before_action :set_new_external_link, only: [:new, :create]

  def index
    page_metadata(title: "#{@item.title}: External Links")
    #@external_links = paginate(@item.external_links)
    @external_links = @item.external_links
    @user = current_user
  end

  def show
    page_metadata(title: "#{@item.title}: #{@external_link.title}")
  end

  def new
  end

  def create
    if @external_link.save
      redirect_to([@item, @external_link], notice: 'The external link has been saved.')
    else
      render action: "new"
    end
  end

  def edit
    page_metadata(title: "Edit External Link: #{@external_link.title}")
  end

  def update
    page_metadata(title: "Edit External Link: #{@external_link.title}")
    if @external_link.update(params[:external_link])
      redirect_to([@item, @external_link], notice: 'The external link has been saved.')
    else
      render action: "edit"
    end
  end

  def delete
    page_metadata(title: "Delete External Link: #{@external_link.title}")
  end

  def destroy
    @external_link.destroy
    redirect_to(@item)
  end

  protected

  def set_user
    @user = current_user
  end

  # The actions for this controller, other than viewing, require authorization.
  def requires_authority(action)
    unless (
      (@external_link && @external_link.has_authority_for_user_to?(@user, action)) ||
      (!@external_link && @item && @item.has_authority_for_user_to?(@user, action)) ||
      (@user && @external_link && @user.has_authority_for_area(@external_link.authority_area, action)) ||
      (@user && @user.has_authority_for_area(ExternalLink.authority_area, action))
    )
      raise Wayground::AccessDenied
    end
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
    if params[:event_id].present?
      @item = Event.find(params[:event_id])
    end
  end

  # Most of the actions for this controller receive the id of an ExternalLink as a parameter.
  def set_external_link
    @external_link = @item.external_links.find(params[:id])
  end

  def set_new_external_link
    page_metadata(title: 'New External Link')
    @external_link = @item.external_links.build(params[:external_link])
  end

end
