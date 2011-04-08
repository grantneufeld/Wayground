# encoding: utf-8

# Set authorities (permissions / access-control) for users.
class AuthoritiesController < ApplicationController
  before_filter :requires_authority
  before_filter :set_authority, :except => [:index, :new, :create]
  before_filter :set_site_location, :except => [:index]

  # GET /authorities
  # GET /authorities.xml
  def index
    @authorities = Authority.all
    @page_title = "Authorities"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @authorities }
    end
  end

  # GET /authorities/1
  # GET /authorities/1.xml
  def show
    @page_title = "Authority"

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @authority }
    end
  end

  # GET /authorities/new
  # GET /authorities/new.xml
  def new
    raise Wayground::AccessDenied unless current_user.has_authority_for_area('Authority', :can_create)
    @authority = Authority.new
    @page_title = "New Authority"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @authority }
    end
  end

  # POST /authorities
  # POST /authorities.xml
  def create
    raise Wayground::AccessDenied unless current_user.has_authority_for_area('Authority', :can_create)
    @authority = Authority.build_from_params(params[:authority])
    @authority.authorized_by = current_user
    @user = @authority.user
    @page_title = "New Authority"

    respond_to do |format|
      if @authority.save
        format.html { redirect_to(@authority, :notice => 'Authority was successfully created.') }
        format.xml  { render :xml => @authority, :status => :created, :location => @authority }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @authority.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /authorities/1/edit
  def edit
    raise Wayground::AccessDenied unless current_user.has_authority_for_area('Authority', :can_edit)
    @page_title = "Update Authority"
  end

  # PUT /authorities/1
  # PUT /authorities/1.xml
  def update
    raise Wayground::AccessDenied unless current_user.has_authority_for_area('Authority', :can_edit)
    @authority.authorized_by = current_user
    @page_title = "Update Authority"

    respond_to do |format|
      if @authority.update_attributes(params[:authority])
        format.html { redirect_to(@authority, :notice => 'Authority was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @authority.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /authorities/1/delete
  def delete
    raise Wayground::AccessDenied unless current_user.has_authority_for_area('Authority', :can_delete)
    @page_title = "Delete Authority"
  end

  # DELETE /authorities/1
  # DELETE /authorities/1.xml
  def destroy
    raise Wayground::AccessDenied unless current_user.has_authority_for_area('Authority', :can_delete)
    @authority.destroy

    respond_to do |format|
      format.html { redirect_to(authorities_url) }
      format.xml  { head :ok }
    end
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

  # The actions for this controller all require that the user is authorized to view Authority records.
  def requires_authority
    unless current_user && current_user.has_authority_for_area('Authority')
      raise Wayground::AccessDenied
    end
  end
end
