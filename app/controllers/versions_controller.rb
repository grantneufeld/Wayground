# encoding: utf-8

# Reviewing versions of arbitrary items (such as Pages).
# This controller is always routed as a sub-controller to an item class (e.g., pages).
class VersionsController < ApplicationController
  before_filter :set_item
  before_filter :requires_view_authority

  # GET /versions
  # GET /versions.xml
  def index
    @versions = @item.versions
    @page_title = "Revision history of “#{@item.title}”"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @versions }
    end
  end

  # GET /versions/1
  # GET /versions/1.xml
  def show
    @version = @item.versions.find(params[:id])
    @page_title = "“#{@item.title}” (version from #{@version.edited_at.to_s(:compact_datetime)})"

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @version }
    end
  end

  protected

  def set_item
    @item = Page.find(params[:page_id])
  end

  def requires_view_authority
    unless @item.has_authority_for_user_to?(current_user)
      raise Wayground::AccessDenied
    end
  end
end
