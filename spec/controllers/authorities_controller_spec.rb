require 'spec_helper'

describe AuthoritiesController do

  before(:all) do
    Authority.delete_all
    User.destroy_all
  end

  def mock_admin(stubs={})
    @mock_admin ||= mock_model(
      User, {
        id: 1, email: 'test+mockadmin@wayground.ca', name: 'The Admin',
        has_authority_for_area: mock_admin_authority
      }.merge(stubs)
    )
  end
  def mock_user(stubs={})
    @mock_user ||= mock_model(
      User, {
        id: 2, email: 'test+mockuser@wayground.ca', name: 'A. User', has_authority_for_area: nil
      }.merge(stubs)
    )
  end

  def set_logged_in_admin(stubs={})
    controller.stub(:current_user).and_return(mock_admin(stubs))
  end
  def set_logged_in_user(stubs={})
    controller.stub(:current_user).and_return(mock_user(stubs))
  end

  def mock_authority(stubs={})
    @mock_authority ||= mock_model(
      Authority, { area: 'global', user: @mock_user }.merge(stubs)
    ).as_null_object
  end
  def mock_admin_authority(stubs={})
    @mock_admin_authority ||= mock_model(
      Authority, { area: 'global', is_owner: true, user: @mock_admin }.merge(stubs)
    ).as_null_object
  end
  def reset_mock_admin_authority(stubs={})
    @mock_admin_authority = nil
    mock_admin_authority(stubs)
  end

  describe "GET index" do
    it "blocks users without the :can_view authority" do
      set_logged_in_user
      get :index
      response.status.should eq 403 # "403 Forbidden"
    end
    it "assigns all authorities as @authorities" do
      set_logged_in_admin
      controller.stub(:paginate).and_return([mock_admin_authority])
      get :index
      assigns(:authorities).should eq([mock_admin_authority])
    end
  end

  describe "GET show" do
    it "blocks users without the :can_view authority" do
      set_logged_in_user
      get :show, :id => "37"
      response.status.should eq 403 # "403 Forbidden"
    end
    it "assigns the requested authority as @authority" do
      set_logged_in_admin
      Authority.stub(:find).with("37") { mock_admin_authority }
      get :show, :id => "37"
      assigns(:authority).should be(mock_admin_authority)
    end
    it "give a 404 Missing error when a non-existent authority is requested" do
      set_logged_in_admin
      get :show, :id => "12345"
      response.status.should eq 404 # "404 Missing"
    end
  end

  describe "GET new" do
    it "blocks users without the :can_create authority" do
      set_logged_in_user
      get :new
      response.status.should eq 403 # "403 Forbidden"
    end
    it "assigns a new authority as @authority" do
      set_logged_in_admin
      Authority.stub(:new) { mock_admin_authority }
      get :new
      assigns(:authority).should be(mock_admin_authority)
    end
  end

  describe "POST create" do
    it "blocks users without the :can_create authority" do
      set_logged_in_user
      post :create, :authority => {'these' => 'params'}
      response.status.should eq 403 # "403 Forbidden"
    end

    describe "with valid params" do
      it "assigns a newly created authority as @authority" do
        set_logged_in_admin
        Authority.stub(:new).with({'these' => 'params'}) { mock_authority(:save => true, :user => mock_user) }
        post :create, :authority => {'these' => 'params'}
        assigns(:authority).should be(mock_authority)
        assigns(:user).should_not be_nil
      end
      it "redirects to the created authority" do
        set_logged_in_admin
        Authority.stub(:new) { mock_authority(:save => true) }
        post :create, :authority => {}
        response.should redirect_to(authority_url(mock_authority))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved authority as @authority" do
        set_logged_in_admin
        Authority.stub(:new).with({'these' => 'params'}) { mock_authority(:save => false) }
        post :create, :authority => {'these' => 'params'}
        assigns(:authority).should be(mock_authority)
      end
      it "re-renders the 'new' template" do
        set_logged_in_admin
        Authority.stub(:new) { mock_authority(:save => false) }
        post :create, :authority => {}
        response.should render_template("new")
      end
    end
  end

  describe "GET edit" do
    it "blocks users without the :can_update authority" do
      set_logged_in_user
      get :edit, :id => "37"
      response.status.should eq 403 # "403 Forbidden"
    end
    it "assigns the requested authority as @authority" do
      set_logged_in_admin
      Authority.stub(:find).with("37") { mock_admin_authority }
      get :edit, :id => "37"
      assigns(:authority).should be(mock_admin_authority)
    end
  end

  describe "PUT update" do
    it "blocks users without the :can_update authority" do
      set_logged_in_user
      patch :update, id: '37', authority: { 'these' => 'params' }
      response.status.should eq 403 # "403 Forbidden"
    end

    describe "with valid params" do
      it "updates the requested authority" do
        set_logged_in_admin
        Authority.stub(:find).with("37") { mock_admin_authority }
        mock_admin_authority.should_receive(:update).with('these' => 'params')
        patch :update, id: '37', authority: { 'these' => 'params' }
      end
      it "assigns the requested authority as @authority" do
        set_logged_in_admin
        Authority.stub(:find) { reset_mock_admin_authority(update: true) }
        patch :update, id: '1'
        assigns(:authority).should be(mock_admin_authority)
      end
      it "redirects to the authority" do
        set_logged_in_admin
        Authority.stub(:find) { reset_mock_admin_authority(update: true) }
        patch :update, id: '1'
        response.should redirect_to(authority_url(mock_admin_authority))
      end
    end

    describe "with invalid params" do
      it "assigns the authority as @authority" do
        set_logged_in_admin
        Authority.stub(:find) { mock_admin_authority(update: false) }
        patch :update, id: '1'
        assigns(:authority).should be(mock_admin_authority)
      end
      it "re-renders the 'edit' template" do
        set_logged_in_admin
        Authority.stub(:find) { mock_authority(update: false) }
        patch :update, id: '1'
        response.should render_template("edit")
      end
    end
  end

  describe "GET delete" do
    it "blocks users without the :can_delete authority" do
      set_logged_in_user
      get :delete, :id => "37"
      response.status.should eq 403 # "403 Forbidden"
    end
    it "shows a form for confirming deletion of an authority" do
      set_logged_in_admin
      Authority.stub(:find).with("37") { mock_admin_authority }
      get :delete, :id => "37"
      assigns(:authority).should be(mock_admin_authority)
    end
  end

  describe "DELETE destroy" do
    it "blocks users without the :can_delete authority" do
      set_logged_in_user
      delete :destroy, :id => "37"
      response.status.should eq 403 # "403 Forbidden"
    end
    it "destroys the requested authority" do
      set_logged_in_admin
      Authority.stub(:find).with("37") { mock_admin_authority }
      mock_admin_authority.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
    it "redirects to the authorities list" do
      set_logged_in_admin
      Authority.stub(:find) { mock_admin_authority }
      delete :destroy, :id => "1"
      response.should redirect_to(authorities_url)
    end
  end
end
