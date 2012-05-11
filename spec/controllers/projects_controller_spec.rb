require 'spec_helper'

describe ProjectsController do

  before(:all) do
    Authority.delete_all
    User.delete_all
    # first user is automatically an admin
    @user_admin = FactoryGirl.create(:user, :name => 'Admin User')
    @user_normal = FactoryGirl.create(:user, :name => 'Normal User')
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
    #{:remember_token => @user_admin.remember_token_hash}
  end

  def set_logged_in_admin
    request.cookies['remember_token'] = @user_admin.remember_token_hash
  end
  def set_logged_in_user
    request.cookies['remember_token'] = @user_normal.remember_token_hash
  end

  describe "GET index" do
    it "assigns all projects as @projects" do
      project = FactoryGirl.create(:project, :creator => @user_admin, :owner => @user_admin)
      #set_logged_in_admin
      get :index #, {}, valid_session
      assigns(:projects).should eq([project])
    end
  end

  describe "GET show" do
    it "assigns the requested project as @project" do
      project = FactoryGirl.create(:project, :creator => @user_admin, :owner => @user_admin)
      #set_logged_in_admin
      get :show, {:id => project.to_param} #, valid_session
      assigns(:project).should eq(project)
    end
    it "assigns the requested project from a projecturl" do
      project = FactoryGirl.create(:project, :creator => @user_admin, :owner => @user_admin, :filename => 'test')
      get :show, {:projecturl => 'test'}
      assigns(:project).should eq(project)
    end
    it "assigns the requested project from a projecturl set to the id" do
      Project.delete_all
      project = FactoryGirl.create(:project, :id => 1234, :creator => @user_admin, :owner => @user_admin)
      get :show, {:projecturl => project.id.to_s}
      assigns(:project).should eq(project)
    end
  end

  describe "GET new" do
    it "fails if not logged in" do
      get :new
      response.status.should eq 403
    end

    it "assigns a new project as @project" do
      set_logged_in_admin
      get :new, {}, valid_session
      assigns(:project).should be_a_new(Project)
    end
  end

  describe "GET edit" do
    it "fails if not authorized to update the project" do
      project = FactoryGirl.create(:project, :creator => @user_admin, :owner => @user_admin)
      set_logged_in_user
      get :edit, {:id => project.to_param} #, valid_session
      response.status.should eq 403
    end

    it "assigns the requested project as @project" do
      project = FactoryGirl.create(:project, :creator => @user_admin, :owner => @user_admin)
      set_logged_in_admin
      get :edit, {:id => project.to_param}, valid_session
      assigns(:project).should eq(project)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Project" do
        expect {
          set_logged_in_admin
          post :create, {:project => valid_attributes}, valid_session
        }.to change(Project, :count).by(1)
      end

      it "assigns a newly created project as @project" do
        set_logged_in_admin
        post :create, {:project => valid_attributes}, valid_session
        assigns(:project).should be_a(Project)
        assigns(:project).should be_persisted
      end

      it "redirects to the created project" do
        set_logged_in_admin
        post :create, {:project => valid_attributes}, valid_session
        response.should redirect_to(Project.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved project as @project" do
        # Trigger the behavior that occurs when invalid params are submitted
        Project.any_instance.stub(:save).and_return(false)
        set_logged_in_admin
        post :create, {:project => {}}, valid_session
        assigns(:project).should be_a_new(Project)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Project.any_instance.stub(:save).and_return(false)
        set_logged_in_admin
        post :create, {:project => {}}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested project" do
        project = FactoryGirl.create(:project, :creator => @user_admin, :owner => @user_admin)
        # Assuming there are no other projects in the database, this
        # specifies that the Project created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Project.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        set_logged_in_admin
        put :update, {:id => project.to_param, :project => {'these' => 'params'}}, valid_session
      end

      it "assigns the requested project as @project" do
        project = FactoryGirl.create(:project, :creator => @user_admin, :owner => @user_admin)
        set_logged_in_admin
        put :update, {:id => project.to_param, :project => valid_attributes}, valid_session
        assigns(:project).should eq(project)
      end

      it "redirects to the project" do
        project = FactoryGirl.create(:project, :creator => @user_admin, :owner => @user_admin)
        set_logged_in_admin
        put :update, {:id => project.to_param, :project => valid_attributes}, valid_session
        response.should redirect_to(project_name_url(project.filename))
      end
    end

    describe "with invalid params" do
      it "assigns the project as @project" do
        project = FactoryGirl.create(:project, :creator => @user_admin, :owner => @user_admin)
        # Trigger the behavior that occurs when invalid params are submitted
        Project.any_instance.stub(:save).and_return(false)
        set_logged_in_admin
        put :update, {:id => project.to_param, :project => {}}, valid_session
        assigns(:project).should eq(project)
      end

      it "re-renders the 'edit' template" do
        project = FactoryGirl.create(:project, :creator => @user_admin, :owner => @user_admin)
        # Trigger the behavior that occurs when invalid params are submitted
        Project.any_instance.stub(:save).and_return(false)
        set_logged_in_admin
        put :update, {:id => project.to_param, :project => {}}, valid_session
        response.should render_template("edit")
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
      response.should redirect_to(projects_url)
    end
  end

end
