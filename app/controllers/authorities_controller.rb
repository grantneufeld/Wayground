# Set authorities (permissions / access-control) for users.
class AuthoritiesController < ApplicationController
  before_action :requires_view_authority, only: %i[index show]
  before_action :requires_create_authority, only: %i[new create]
  before_action :requires_update_authority, only: %i[edit update]
  before_action :requires_delete_authority, only: %i[delete destroy]
  before_action :set_authority, except: %i[index new create]
  before_action :set_site_location, except: [:index]

  # GET /authorities
  # GET /authorities.xml
  def index
    @authorities = paginate(Authority)
    page_metadata(title: 'Authorities')
  end

  # GET /authorities/1
  # GET /authorities/1.xml
  def show
    page_metadata(title: 'Authority')
  end

  # GET /authorities/new
  # GET /authorities/new.xml
  def new
    @authority = Authority.new
    page_metadata(title: 'New Authority')
  end

  # POST /authorities
  def create
    create_params = { authority_params: authority_params, authorized_by: current_user }
    @authority = Authority.build_from_params(create_params)
    @user = @authority.user
    page_metadata(title: 'New Authority')
    if @authority.save
      redirect_to(authority_url(@authority.to_param), notice: 'Authority was successfully created.')
    else
      render action: 'new'
    end
  end

  # GET /authorities/1/edit
  def edit
    page_metadata(title: 'Update Authority')
  end

  # PUT /authorities/1
  # PUT /authorities/1.xml
  def update
    @authority.authorized_by = current_user
    page_metadata(title: 'Update Authority')
    if @authority.update(authority_params)
      redirect_to(@authority, notice: 'Authority was successfully updated.')
    else
      render action: 'edit'
    end
  end

  # GET /authorities/1/delete
  def delete
    page_metadata(title: 'Delete Authority')
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
    @site_breadcrumbs = [{ text: 'Authorities', url: authorities_path }]
  end

  def requires_view_authority
    can_view = current_user && current_user.authority_for_area('Authority', :can_view)
    raise Wayground::AccessDenied unless can_view
  end

  def requires_create_authority
    can_create = current_user && current_user.authority_for_area('Authority', :can_create)
    raise Wayground::AccessDenied unless can_create
  end

  def requires_update_authority
    can_update = current_user && current_user.authority_for_area('Authority', :can_update)
    raise Wayground::AccessDenied unless can_update
  end

  def requires_delete_authority
    can_delete = current_user && current_user.authority_for_area('Authority', :can_delete)
    raise Wayground::AccessDenied unless can_delete
  end

  def authority_params
    params.fetch(:authority, {}).permit(
      :item_type, :item_id, :area, :is_owner, :can_create, :can_view, :can_update,
      :can_delete, :can_invite, :can_permit, :can_approve, :user_proxy
    )
  end
end
