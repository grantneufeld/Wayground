# encoding: utf-8

class ProjectsController < ApplicationController
  before_filter :set_user
  before_filter :set_project, :except => [:index, :new, :create]
  before_filter :requires_login, :only => [:new, :create]
  before_filter :requires_update_authority, :only => [:edit, :update]
  before_filter :requires_delete_authority, :only => [:delete, :destroy]
  before_filter :set_section
  before_filter :set_new_project, :only => [:new, :create]

  def index
    @projects = Project.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @projects }
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @project }
    end
  end

  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @project }
    end
  end

  def create
    respond_to do |format|
      if @project.save
        format.html { redirect_to_project(@project, :notice => 'Project was successfully created.') }
        format.xml  { render :xml => @project, :status => :created, :location => @project }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @project.update_attributes(params[:project])
        format.html { redirect_to_project(@project, :notice => 'Project was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  def delete
  end

  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to(projects_url) }
      format.xml  { head :ok }
    end
  end

  protected

  def redirect_to_project(project, args = {})
    if project.filename?
      redirect_to project_name_url(project.filename), args
    else
      redirect_to project, args
    end
  end

  # The actions for this controller, other than viewing, require login and usually authorization.
  def requires_login
    unless @user
      raise Wayground::LoginRequired
    end
  end
  def requires_authority(action)
    unless (
      (@project && @project.has_authority_for_user_to?(@user, action)) ||
      (@user && @user.has_authority_for_area(Project.authority_area, action))
    )
      raise Wayground::AccessDenied
    end
  end
  def requires_update_authority
    requires_authority(:can_update)
  end
  def requires_delete_authority
    requires_authority(:can_delete)
  end

  def set_user
    @user = current_user
  end

  # Most of the actions for this controller receive the id of an Project as a parameter.
  def set_project
    if params[:projecturl].present?
      if params[:projecturl].match /\A[0-9]+\z/
        @project = Project.find(params[:projecturl].to_i)
      else
        @project = Project.find_by_filename(params[:projecturl])
      end
    else
      @project = Project.find(params[:id])
    end
  end

  def set_section
    @site_section = 'Projects'
  end

  def set_new_project
    @page_title = 'New Project'
    @project = Project.new(params[:project])
    @project.creator = @project.owner = @user
  end
end
