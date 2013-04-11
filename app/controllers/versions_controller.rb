# encoding: utf-8

# Reviewing versions of arbitrary items (such as Pages or Events).
# This controller is always routed as a sub-controller to an item class (e.g., pages).
class VersionsController < ApplicationController
  before_filter :set_item
  before_filter :requires_view_authority

  # GET /versions
  # GET /versions.xml
  def index
    @versions = paginate(@item.versions)
    page_metadata(title: "Revision history of “#{@item.title}”")
  end

  # GET /versions/1
  # GET /versions/1.xml
  def show
    @version = @item.versions.find(params[:id])
    page_metadata(title: "“#{@item.title}” (version from #{@version.edited_at.to_s(:compact_datetime)})")
  end

  protected

  def set_item
    if params[:page_id].present?
      @item = Page.find(params[:page_id])
    elsif params[:event_id].present?
      @item = Event.find(params[:event_id])
    end
  end

  def requires_view_authority
    unless @item.has_authority_for_user_to?(current_user)
      raise Wayground::AccessDenied
    end
  end
end
