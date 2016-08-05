# Access Projects.
class ProjectsController < ApplicationController
  before_action :set_user
  before_action :set_project, except: %i(index new create)
  before_action :requires_login, only: %i(new create)
  before_action :requires_update_authority, only: %i(edit update)
  before_action :requires_delete_authority, only: %i(delete destroy)
  before_action :set_section
  before_action :set_new_project, only: %i(new create)

  def index
    @projects = Project.all
  end

  def show
    page_metadata(title: @project.name, description: @project.description)
  end

  def new
  end

  def create
    if @project.save
      redirect_to_project(@project, notice: 'Project was successfully created.')
    else
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to_project(@project, notice: 'Project was successfully updated.')
    else
      render action: 'edit'
    end
  end

  def delete
  end

  def destroy
    @project.destroy
    redirect_to(projects_url)
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
    raise Wayground::LoginRequired unless @user
  end

  def requires_authority(action)
    project_allowed = @project && @project.has_authority_for_user_to?(@user, action)
    unless project_allowed || (@user && @user.authority_for_area(Project.authority_area, action))
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

  # Most of the actions for this controller receive the id or projecturl of an Project as a parameter.
  def set_project
    project_url = params[:projecturl]
    @project =
      if project_url.blank?
        Project.find(params[:id])
      elsif project_url =~ /\A[0-9]+\z/
        Project.find(project_url.to_i)
      else
        Project.where(filename: project_url).first
      end
  end

  def set_section
    @site_section = :projects
  end

  def set_new_project
    page_metadata(title: 'New Project')
    @project = Project.new(project_params)
    @project.creator = @project.owner = @user
  end

  def project_params
    params.fetch(:project, {}).permit(
      :is_visible, :is_public_content, :is_visible_member_list, :is_joinable,
      :is_members_can_invite, :is_not_unsubscribable, :is_moderated, :is_only_admin_posts,
      :is_no_comments, :name, :filename, :description # , :editor, :edit_comment
    )
  end
end
