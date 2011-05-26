require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by the Rails when you ran the scaffold generator.

describe PagesController do

  before do
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
    @mock_admin ||= mock_model(User, {:id => 1, :email => 'test+mockadmin@wayground.ca', :name => 'The Admin', :has_authority_for_area => mock_admin_authority, :has_authority_for_item => mock_admin_authority}.merge(stubs))
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

  def mock_page(stubs={})
    @mock_page ||= mock_model(Page, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all pages as @pages" do
      Page.stub(:all) { [mock_page] }
      get :index
      assigns(:pages).should eq([mock_page])
    end
  end

  describe "GET show" do
    it "assigns the requested page as @page" do
      set_logged_in_admin
      Page.stub(:find).with("37") { mock_page }
      get :show, :id => "37"
      assigns(:page).should be(mock_page)
    end
  end

  describe "GET new" do
    it "assigns a new page as @page" do
      set_logged_in_admin
      Page.stub(:new) { mock_page }
      get :new
      assigns(:page).should be(mock_page)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "assigns a newly created page as @page" do
        set_logged_in_admin
        Page.stub(:new).with({'these' => 'params'}) { mock_page(:save => true) }
        post :create, :page => {'these' => 'params'}
        assigns(:page).should be(mock_page)
      end

      it "redirects to the created page" do
        set_logged_in_admin
        Page.stub(:new) { mock_page(:save => true) }
        post :create, :page => {}
        response.should redirect_to(page_url(mock_page))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved page as @page" do
        set_logged_in_admin
        Page.stub(:new).with({'these' => 'params'}) { mock_page(:save => false) }
        post :create, :page => {'these' => 'params'}
        assigns(:page).should be(mock_page)
      end

      it "re-renders the 'new' template" do
        set_logged_in_admin
        Page.stub(:new) { mock_page(:save => false) }
        post :create, :page => {}
        response.should render_template("new")
      end
    end
  end

  describe "GET edit" do
    it "assigns the requested page as @page" do
      set_logged_in_admin
      Page.stub(:find).with("37") { mock_page }
      get :edit, :id => "37"
      assigns(:page).should be(mock_page)
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested page" do
        set_logged_in_admin
        Page.stub(:find).with("37") { mock_page }
        mock_page.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :page => {'these' => 'params'}
      end

      it "assigns the requested page as @page" do
        set_logged_in_admin
        Page.stub(:find) { mock_page(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:page).should be(mock_page)
      end

      it "redirects to the page" do
        set_logged_in_admin
        Page.stub(:find) { mock_page(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(page_url(mock_page))
      end
    end

    describe "with invalid params" do
      it "assigns the page as @page" do
        set_logged_in_admin
        Page.stub(:find) { mock_page(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:page).should be(mock_page)
      end

      it "re-renders the 'edit' template" do
        set_logged_in_admin
        Page.stub(:find) { mock_page(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end
  end

  describe "GET delete" do
    it "shows a form for confirming deletion of a page" do
      set_logged_in_admin
      Page.stub(:find).with("37") { mock_page }
      get :delete, :id => "37"
      assigns(:page).should be(mock_page)
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested page" do
      set_logged_in_admin
      Page.stub(:find).with("37") { mock_page }
      mock_page.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the pages list" do
      set_logged_in_admin
      Page.stub(:find) { mock_page }
      delete :destroy, :id => "1"
      response.should redirect_to(pages_url)
    end
  end

end
