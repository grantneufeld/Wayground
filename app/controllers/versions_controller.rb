# Reviewing versions of arbitrary items (such as Pages or Events).
# This controller is always routed as a sub-controller to an item class (e.g., pages/1/versions).
class VersionsController < ApplicationController
  before_action :set_item
  before_action :requires_view_authority

  def index
    @versions = paginate(@item.versions)
    page_metadata(title: "Revision history of “#{@item.title}”", nocache: true)
  end

  def show
    @version = @item.versions.find(params[:id])
    page_metadata(
      title: "“#{@item.title}” (version from #{@version.edited_at.to_s(:compact_datetime)})",
      nocache: true
    )
  end

  protected

  def set_item
    page_id = params[:page_id]
    event_id = params[:event_id]
    if page_id.present?
      @item = Page.find(page_id)
    elsif event_id.present?
      @item = Event.find(event_id)
    end
  end

  def requires_view_authority
    unless @item.has_authority_for_user_to?(current_user)
      raise Wayground::AccessDenied
    end
  end
end
