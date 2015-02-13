require 'spec_helper'

describe AuthoritiesController, type: :controller do

  before(:all) do
    Authority.delete_all
    User.destroy_all
    @default_admin = FactoryGirl.create(:user, email: 'test+mockadmin@wayground.ca', name: 'The Admin')
    @default_admin_authority = @default_admin.authorizations.first
    @default_user = FactoryGirl.create(:user, email: 'test+mockuser@wayground.ca', name: 'A. User')
  end

  def default_admin_authority
    @default_admin_authority
  end
  def default_user
    @default_user
  end

  def set_logged_in_default_admin
    allow(controller).to receive(:current_user).and_return(@default_admin)
  end
  def set_logged_in_default_user
    allow(controller).to receive(:current_user).and_return(@default_user)
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

  describe "GET index" do
    it "blocks users without the :can_view authority" do
      set_logged_in_default_user
      get :index
      expect(response.status).to eq 403 # "403 Forbidden"
    end
    it "assigns all authorities as @authorities" do
      set_logged_in_default_admin
      allow(controller).to receive(:paginate).and_return([mock_admin_authority])
      get :index
      expect(assigns(:authorities)).to eq([mock_admin_authority])
    end
  end

  describe "GET show" do
    it "blocks users without the :can_view authority" do
      set_logged_in_default_user
      get :show, :id => "37"
      expect(response.status).to eq 403 # "403 Forbidden"
    end
    it "assigns the requested authority as @authority" do
      set_logged_in_default_admin
      allow(Authority).to receive(:find).with("37") { mock_admin_authority }
      get :show, :id => "37"
      expect(assigns(:authority)).to be(mock_admin_authority)
    end
    it "give a 404 Missing error when a non-existent authority is requested" do
      set_logged_in_default_admin
      get :show, :id => "12345"
      expect(response.status).to eq 404 # "404 Missing"
    end
  end

  describe "GET new" do
    it "blocks users without the :can_create authority" do
      set_logged_in_default_user
      get :new
      expect(response.status).to eq 403 # "403 Forbidden"
    end
    it "assigns a new authority as @authority" do
      set_logged_in_default_admin
      allow(Authority).to receive(:new) { mock_admin_authority }
      get :new
      expect(assigns(:authority)).to be(mock_admin_authority)
    end
  end

  describe "POST create" do
    it "blocks users without the :can_create authority" do
      set_logged_in_default_user
      post :create, :authority => {'these' => 'params'}
      expect(response.status).to eq 403 # "403 Forbidden"
    end

    describe "with valid params" do
      it "assigns a newly created authority as @authority" do
        set_logged_in_default_admin
        allow(Authority).to receive(:new).with({'these' => 'params'}) {
          mock_authority(save: true, user: default_user)
        }
        post :create, :authority => {'these' => 'params'}
        expect(assigns(:authority)).to be(mock_authority)
        expect(assigns(:user)).not_to be_nil
      end
      it "redirects to the created authority" do
        set_logged_in_default_admin
        allow(Authority).to receive(:new) { mock_authority(:save => true) }
        post :create, :authority => {}
        expect(response).to redirect_to(authority_url(mock_authority))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved authority as @authority" do
        set_logged_in_default_admin
        allow(Authority).to receive(:new).with({'these' => 'params'}) { mock_authority(:save => false) }
        post :create, :authority => {'these' => 'params'}
        expect(assigns(:authority)).to be(mock_authority)
      end
      it "re-renders the 'new' template" do
        set_logged_in_default_admin
        allow(Authority).to receive(:new) { mock_authority(:save => false) }
        post :create, :authority => {}
        expect(response).to render_template("new")
      end
    end
  end

  describe "GET edit" do
    it "blocks users without the :can_update authority" do
      set_logged_in_default_user
      get :edit, :id => "37"
      expect(response.status).to eq 403 # "403 Forbidden"
    end
    it "assigns the requested authority as @authority" do
      set_logged_in_default_admin
      allow(Authority).to receive(:find).with("37") { mock_admin_authority }
      get :edit, :id => "37"
      expect(assigns(:authority)).to be(mock_admin_authority)
    end
  end

  describe "PUT update" do
    it "blocks users without the :can_update authority" do
      set_logged_in_default_user
      patch :update, id: '37', authority: { 'these' => 'params' }
      expect(response.status).to eq 403 # "403 Forbidden"
    end

    describe "with valid params" do
      it "updates the requested authority" do
        set_logged_in_default_admin
        authority = default_admin_authority
        allow(Authority).to receive(:find).with("37") { authority }
        expect(authority).to receive(:update).with('these' => 'params').and_return(true)
        patch :update, id: '37', authority: { 'these' => 'params' }
      end
      it "assigns the requested authority as @authority" do
        set_logged_in_default_admin
        authority = default_admin_authority
        # don’t actually update the authority:
        allow(authority).to receive(:update).and_return(true)
        allow(Authority).to receive(:find) { authority }
        patch :update, id: '1'
        expect(assigns(:authority)).to be(authority)
      end
      it "redirects to the authority" do
        set_logged_in_default_admin
        authority = default_admin_authority
        # don’t actually update the authority:
        allow(authority).to receive(:update).and_return(true)
        allow(Authority).to receive(:find) { authority }
        patch :update, id: '1'
        expect(response).to redirect_to(authority_url(authority))
      end
    end

    describe "with invalid params" do
      it "assigns the authority as @authority" do
        set_logged_in_default_admin
        allow(Authority).to receive(:find) { mock_admin_authority(update: false) }
        patch :update, id: '1'
        expect(assigns(:authority)).to be(mock_admin_authority)
      end
      it "re-renders the 'edit' template" do
        set_logged_in_default_admin
        allow(Authority).to receive(:find) { mock_authority(update: false) }
        patch :update, id: '1'
        expect(response).to render_template("edit")
      end
    end
  end

  describe "GET delete" do
    it "blocks users without the :can_delete authority" do
      set_logged_in_default_user
      get :delete, :id => "37"
      expect(response.status).to eq 403 # "403 Forbidden"
    end
    it "shows a form for confirming deletion of an authority" do
      set_logged_in_default_admin
      allow(Authority).to receive(:find).with("37") { mock_admin_authority }
      get :delete, :id => "37"
      expect(assigns(:authority)).to be(mock_admin_authority)
    end
  end

  describe "DELETE destroy" do
    it "blocks users without the :can_delete authority" do
      set_logged_in_default_user
      delete :destroy, :id => "37"
      expect(response.status).to eq 403 # "403 Forbidden"
    end
    it "destroys the requested authority" do
      set_logged_in_default_admin
      allow(Authority).to receive(:find).with("37") { mock_admin_authority }
      expect(mock_admin_authority).to receive(:destroy)
      delete :destroy, :id => "37"
    end
    it "redirects to the authorities list" do
      set_logged_in_default_admin
      allow(Authority).to receive(:find) { mock_admin_authority }
      delete :destroy, :id => "1"
      expect(response).to redirect_to(authorities_url)
    end
  end
end
