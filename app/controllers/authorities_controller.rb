# encoding: utf-8

# Set authorities (permissions / access-control) for users.
class AuthoritiesController < ApplicationController
  before_filter :requires_view_authority, :only => [:index, :show]
  before_filter :requires_create_authority, :only => [:new, :create]
  before_filter :requires_update_authority, :only => [:edit, :update]
  before_filter :requires_delete_authority, :only => [:delete, :destroy]
  before_filter :set_authority, :except => [:index, :new, :create]
  before_filter :set_site_location, :except => [:index]

  # GET /authorities
  # GET /authorities.xml
  def index
    @authorities = paginate(Authority)
    @page_title = "Authorities"
  end

  # GET /authorities/1
  # GET /authorities/1.xml
  def show
    @page_title = "Authority"
  end

  # GET /authorities/new
  # GET /authorities/new.xml
  def new
    @authority = Authority.new
    @page_title = "New Authority"
  end

  # POST /authorities
  def create
    @authority = Authority.build_from_params(authority_params: params[:authority], authorized_by: current_user)
    @user = @authority.user
    @page_title = "New Authority"

    if @authority.save
      redirect_to(@authority, notice: 'Authority was successfully created.')
    else
      render action: "new"
    end
  end

  # GET /authorities/1/edit
  def edit
    @page_title = "Update Authority"
  end

  # PUT /authorities/1
  # PUT /authorities/1.xml
  def update
    @authority.authorized_by = current_user
    @page_title = "Update Authority"

    if @authority.update_attributes(params[:authority])
      redirect_to(@authority, notice: 'Authority was successfully updated.')
    else
      render action: "edit"
    end
  end

  # GET /authorities/1/delete
  def delete
    @page_title = "Delete Authority"
  end

  # DELETE /authorities/1
  # DELETE /authorities/1.xml
  def destroy
    @authority.destroy
    redirect_to(authorities_url)
  end

  protected

  # Most of the actions for this controller receive the id of an Authority as a parameter.
  def set_authority
    @authority = Authority.find(params[:id])
  end

  # Breadcrumbs for actions on this controller start with the index page.
  def set_site_location
    @site_breadcrumbs = [{:text => 'Authorities', :url => authorities_path}]
  end

  def requires_view_authority
    unless current_user && current_user.has_authority_for_area('Authority', :can_view)
      raise Wayground::AccessDenied
    end
  end

  def requires_create_authority
    unless current_user && current_user.has_authority_for_area('Authority', :can_create)
      raise Wayground::AccessDenied
    end
  end

  def requires_update_authority
    unless current_user && current_user.has_authority_for_area('Authority', :can_update)
      raise Wayground::AccessDenied
    end
  end

  def requires_delete_authority
    unless current_user && current_user.has_authority_for_area('Authority', :can_delete)
      raise Wayground::AccessDenied
    end
  end
end
