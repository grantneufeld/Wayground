# encoding: utf-8
require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by the Rails when you ran the scaffold generator.

describe PathsController do

  before(:all) do
    Authority.delete_all
    User.destroy_all
  end

  def set_logged_in_admin(stubs={})
    controller.stub!(:current_user).and_return(mock_admin(stubs))
  end
  def set_logged_in_user(stubs={})
    controller.stub!(:current_user).and_return(mock_user(stubs))
  end
  def mock_admin(stubs={})
    @mock_admin ||= mock_model(User, {:id => 1, :email => 'test+mockadmin@wayground.ca', :name => 'The Admin', :has_authority_for_area => mock_admin_authority}.merge(stubs))
  end
  def mock_user(stubs={})
    @mock_user ||= mock_model(User, {:id => 2, :email => 'test+mockuser@wayground.ca', :name => 'A. User', :has_authority_for_area => nil}.merge(stubs))
  end
  def mock_authority(stubs={})
    @mock_authority ||= mock_model(Authority, {:area => 'Content', :user => @mock_user}.merge(stubs)).as_null_object
  end
  def mock_admin_authority(stubs={})
    @mock_admin_authority ||= mock_model(Authority, {:area => 'Content', :is_owner => true, :user => @mock_admin}.merge(stubs)).as_null_object
  end

  def mock_path(stubs={})
    @mock_path ||= mock_model(Path, stubs).as_null_object
  end

  describe "GET sitepath" do
    it "displays the default home page if the root url was called and there is no Path found" do
      get :sitepath, {:url => '/'}
      response.should render_template('default_home')
    end
    it "shows the 404 missing error if no Path was found and not the root url" do
      get :sitepath, {:url => '/no/such/path'}
      response.status.should eq 404
      response.should render_template('missing')
    end
    it "redirects if the Path is a redirect" do
      path = FactoryGirl.create(:path, {:redirect => '/'})
      get :sitepath, {:url => path.sitepath}
      response.should redirect_to('/')
    end
    it "shows the Page if the Path’s item is a Page" do
      page = FactoryGirl.create(:page)
      path = FactoryGirl.create(:path, {:item => page})
      get :sitepath, {:url => path.sitepath}
      response.status.should eq 200
      response.should render_template('page')
      assigns(:page).should eq page
    end
    it "shows the 501 unimplemented error if the Path’s item is not supported" do
      set_logged_in_admin
      item = FactoryGirl.create(:user)
      path = FactoryGirl.create(:path, {:item => item})
      get :sitepath, {:url => path.sitepath}
      response.status.should eq 501
    end
    it "shows the 404 missing error if the Path’s item requires authority to view" do
      page = FactoryGirl.create(:page, {:is_authority_controlled => true})
      path = FactoryGirl.create(:path, {:item => page})
      get :sitepath, {:url => path.sitepath}
      response.status.should eq 404
    end
    it "allows an authorized user to access an authority controlled item" do
      set_logged_in_admin
      page = FactoryGirl.create(:page, {:is_authority_controlled => true})
      path = FactoryGirl.create(:path, {:item => page})
      get :sitepath, {:url => path.sitepath}
      response.status.should eq 200
    end
  end

  describe "GET index" do
    it "assigns all paths as @paths" do
      set_logged_in_admin
      controller.stub(:paginate).and_return([mock_path])
      get :index
      assigns(:paths).should eq([mock_path])
    end
  end

  describe "GET show" do
    it "assigns the requested path as @path" do
      set_logged_in_admin
      Path.stub(:find).with("37") { mock_path }
      get :show, :id => "37"
      assigns(:path).should be(mock_path)
    end
  end

  describe "GET new" do
    it "requires the user to have authority" do
      get :new
      response.status.should eq 403
    end

    it "assigns a new path as @path" do
      set_logged_in_admin
      Path.stub(:new) { mock_path }
      get :new
      assigns(:path).should be(mock_path)
    end
  end

  describe "POST create" do
    it "requires the user to have authority" do
      post :create
      response.status.should eq 403
    end

    describe "with valid params" do
      it "assigns a newly created path as @path" do
        set_logged_in_admin
        Path.stub(:new).with({'these' => 'params'}) { mock_path(:save => true) }
        post :create, :path => {'these' => 'params'}
        assigns(:path).should be(mock_path)
      end

      it "redirects to the created path" do
        set_logged_in_admin
        Path.stub(:new) { mock_path(:save => true) }
        post :create, :path => {}
        response.should redirect_to(path_url(mock_path))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved path as @path" do
        set_logged_in_admin
        Path.stub(:new).with({'these' => 'params'}) { mock_path(:save => false) }
        post :create, :path => {'these' => 'params'}
        assigns(:path).should be(mock_path)
      end

      it "re-renders the 'new' template" do
        set_logged_in_admin
        Path.stub(:new) { mock_path(:save => false) }
        post :create, :path => {}
        response.should render_template("new")
      end
    end
  end

  describe "GET edit" do
    it "requires the user to have authority" do
      path = FactoryGirl.create(:path, {:redirect => '/'})
      get :edit, :id => path.id.to_s
      response.status.should eq 403
    end

    it "assigns the requested path as @path" do
      set_logged_in_admin
      Path.stub(:find).with("37") { mock_path }
      get :edit, :id => "37"
      assigns(:path).should be(mock_path)
    end
  end

  describe "PUT update" do
    it "requires the user to have authority" do
      path = FactoryGirl.create(:path, {:redirect => '/'})
      patch :update, id: path.id.to_s
      response.status.should eq 403
    end

    describe "with valid params" do
      it "updates the requested path" do
        set_logged_in_admin
        Path.stub(:find).with("37") { mock_path }
        mock_path.should_receive(:update).with('these' => 'params')
        patch :update, id: '37', path: { 'these' => 'params' }
      end

      it "assigns the requested path as @path" do
        set_logged_in_admin
        Path.stub(:find) { mock_path(update: true) }
        patch :update, id: '1'
        assigns(:path).should be(mock_path)
      end

      it "redirects to the path" do
        set_logged_in_admin
        Path.stub(:find) { mock_path(update: true) }
        patch :update, id: '1'
        response.should redirect_to(path_url(mock_path))
      end
    end

    describe "with invalid params" do
      it "assigns the path as @path" do
        set_logged_in_admin
        Path.stub(:find) { mock_path(update: false) }
        patch :update, id: '1'
        assigns(:path).should be(mock_path)
      end

      it "re-renders the 'edit' template" do
        set_logged_in_admin
        Path.stub(:find) { mock_path(update: false) }
        patch :update, id: '1'
        response.should render_template("edit")
      end
    end
  end

  describe "GET delete" do
    it "requires the user to have authority" do
      path = FactoryGirl.create(:path, {:redirect => '/'})
      get :delete, :id => path.id.to_s
      response.status.should eq 403
    end
    it "shows a form for confirming deletion of a path" do
      set_logged_in_admin
      Path.stub(:find).with("37") { mock_path }
      get :delete, :id => "37"
      assigns(:path).should be(mock_path)
    end
  end

  describe "DELETE destroy" do
    it "requires the user to have authority" do
      path = FactoryGirl.create(:path, {:redirect => '/'})
      delete :destroy, :id => path.id.to_s
      response.status.should eq 403
    end

    it "destroys the requested path" do
      set_logged_in_admin
      Path.stub(:find).with("37") { mock_path }
      mock_path.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the paths list" do
      set_logged_in_admin
      Path.stub(:find) { mock_path }
      delete :destroy, :id => "1"
      response.should redirect_to(paths_url)
    end
  end

end
