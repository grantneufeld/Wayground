require 'spec_helper'
require 'project'
require 'authority'
require 'user'
require 'user_token'
require 'rememberer'

describe ProjectsController, type: :controller do

  before(:all) do
    Authority.delete_all
    User.delete_all
    UserToken.delete_all
    Project.delete_all
    # first user is automatically an admin
    @user_admin = FactoryGirl.create(:user, :name => 'Admin User')
    @user_admin_token = @user_admin.tokens.create(token: 'user admin token')
    @user_normal = FactoryGirl.create(:user, :name => 'Normal User')
    @user_normal_token = @user_normal.tokens.create(token: 'user normal token')
    @admin_project = FactoryGirl.create(:project,
      creator: @user_admin, owner: @user_admin, filename: 'admin_project'
    )
  end

  # This should return the minimal set of attributes required to create a valid
  # Project. As you add validations to Project, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {:name => 'Valid Attributes Name'}
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ProjectsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  def set_logged_in_admin
    request.cookies['remember_token'] = Wayground::Rememberer.new(
      remember: @user_admin, token: @user_admin_token
    ).cookie_token
  end
  def set_logged_in_user
    request.cookies['remember_token'] = Wayground::Rememberer.new(
      remember: @user_normal, token: @user_normal_token
    ).cookie_token
  end

  describe "GET index" do
    it "assigns all projects as @projects" do
      get :index
      expect( assigns(:projects) ).to include(@admin_project)
    end
  end

  describe "GET show" do
    it "assigns the requested project as @project" do
      get :show, {id: @admin_project.to_param}
      expect( assigns(:project) ).to eq @admin_project
    end
    it "assigns the requested project from a projecturl" do
      get :show, {projecturl: 'admin_project'}
      expect( assigns(:project)).to eq @admin_project
    end
    it "assigns the requested project from a projecturl set to the id" do
      get :show, {projecturl: @admin_project.id.to_s}
      expect( assigns(:project) ).to eq @admin_project
    end
  end

  describe "GET new" do
    it "fails if not logged in" do
      get :new
      expect(response.status).to eq 401
    end

    it "assigns a new project as @project" do
      set_logged_in_admin
      get :new
      expect(assigns(:project)).to be_a_new(Project)
    end
  end

  describe "POST create" do
    context "with valid params" do
      it "creates a new Project" do
        expect {
          set_logged_in_admin
          post :create, {:project => valid_attributes}, valid_session
        }.to change(Project, :count).by(1)
      end

      it "assigns a newly created project as @project" do
        set_logged_in_admin
        post :create, {:project => valid_attributes}, valid_session
        expect(assigns(:project)).to be_a(Project)
        expect(assigns(:project)).to be_persisted
      end

      it "redirects to the created project" do
        set_logged_in_admin
        post :create, {:project => valid_attributes}, valid_session
        expect(response).to redirect_to(Project.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved project as @project" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Project).to receive(:save).and_return(false)
        set_logged_in_admin
        post :create, {:project => {}}, valid_session
        expect(assigns(:project)).to be_a_new(Project)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Project).to receive(:save).and_return(false)
        set_logged_in_admin
        post :create, {:project => {}}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "GET edit" do
    it "fails if not authorized to update the project" do
      set_logged_in_user
      get :edit, {id: @admin_project.to_param}
      expect( response.status ).to eq 403
    end

    it "assigns the requested project as @project" do
      set_logged_in_admin
      get :edit, {id: @admin_project.to_param}, valid_session
      expect( assigns(:project) ).to eq @admin_project
    end
  end

  describe "PUT update" do
    context "with valid params" do
      it "updates the requested project" do
        project = FactoryGirl.create(:project, :creator => @user_admin, :owner => @user_admin)
        # Assuming there are no other projects in the database, this
        # specifies that the Project created on the previous line
        # receives the :update message with whatever params are
        # submitted in the request.
        expect_any_instance_of(Project).to receive(:update).with('these' => 'params')
        set_logged_in_admin
        patch :update, { id: project.to_param, project: { 'these' => 'params' } }, valid_session
      end

      it "assigns the requested project as @project" do
        project = FactoryGirl.create(:project, :creator => @user_admin, :owner => @user_admin)
        set_logged_in_admin
        patch :update, { id: project.to_param, project: valid_attributes }, valid_session
        expect(assigns(:project)).to eq(project)
      end

      it "redirects to the project" do
        project = FactoryGirl.create(:project, :creator => @user_admin, :owner => @user_admin)
        set_logged_in_admin
        patch :update, { id: project.to_param, project: valid_attributes }, valid_session
        expect(response).to redirect_to(project_name_url(project.filename))
      end
    end

    context "with invalid params" do
      it "assigns the project as @project" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Project).to receive(:save).and_return(false)
        set_logged_in_admin
        patch :update, { id: @admin_project.to_param, project: {} }
        expect( assigns(:project) ).to eq @admin_project
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Project).to receive(:save).and_return(false)
        set_logged_in_admin
        patch :update, { id: @admin_project.to_param, project: {} }
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested project" do
      project = FactoryGirl.create(:project, :creator => @user_admin, :owner => @user_admin)
      expect {
        set_logged_in_admin
        delete :destroy, {:id => project.to_param}, valid_session
      }.to change(Project, :count).by(-1)
    end

    it "redirects to the projects list" do
      project = FactoryGirl.create(:project, :creator => @user_admin, :owner => @user_admin)
      set_logged_in_admin
      delete :destroy, {:id => project.to_param}, valid_session
      expect(response).to redirect_to(projects_url)
    end
  end

end
