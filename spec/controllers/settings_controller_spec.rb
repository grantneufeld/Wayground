require 'spec_helper'

# Most of this is based on the rspec scaffold generated tests.
describe SettingsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Setting. As you add validations to Setting, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {:key => 'valid'}
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # SettingsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  before(:all) do
    Authority.delete_all
    User.destroy_all
    # first user is automatically an admin
    @user_admin = FactoryGirl.create(:user, :name => 'Admin User')
    @user_normal = FactoryGirl.create(:user, :name => 'Normal User')
  end

  def set_logged_in_admin
    allow(controller).to receive(:current_user).and_return(@user_admin)
  end
  def set_logged_in_user
    allow(controller).to receive(:current_user).and_return(@user_normal)
  end

  describe "GET initialize_defaults" do
    it "requires the user to have authority" do
      set_logged_in_user
      get :initialize_defaults
      expect(response.status).to eq 403
    end
    it "initializes the default settings" do
      Setting.destroy_all
      set_logged_in_admin
      get :initialize_defaults
      expect(Setting[:global_start_date]).to eq(Time.now.to_date.to_s)
    end
    it "redirects to the settings index" do
      set_logged_in_admin
      get :initialize_defaults
      expect(response).to redirect_to(settings_url)
    end
  end

  describe "GET index" do
    it "requires the user to have authority" do
      set_logged_in_user
      setting = Setting.create! valid_attributes
      get :index
      expect(response.status).to eq 403
    end
    it "assigns all settings as @settings" do
      set_logged_in_admin
      setting = Setting.create! valid_attributes
      get :index
      expect(assigns(:settings)).to eq([setting])
    end
  end

  describe "GET show" do
    let(:setting) { FactoryGirl.create(:setting) }
    it "assigns the requested setting as @setting" do
      set_logged_in_admin
      get :show, {:id => setting.to_param}, valid_session
      expect(assigns(:setting)).to eq(setting)
    end
  end

  describe "GET new" do
    it "assigns a new setting as @setting" do
      set_logged_in_admin
      get :new, {}, valid_session
      expect(assigns(:setting)).to be_a_new(Setting)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Setting" do
        set_logged_in_admin
        expect {
          post :create, {:setting => valid_attributes}, valid_session
        }.to change(Setting, :count).by(1)
      end

      it "assigns a newly created setting as @setting" do
        set_logged_in_admin
        post :create, {:setting => valid_attributes}, valid_session
        expect(assigns(:setting)).to be_a(Setting)
        expect(assigns(:setting)).to be_persisted
      end

      it "redirects to the created setting" do
        set_logged_in_admin
        post :create, {:setting => valid_attributes}, valid_session
        expect(response).to redirect_to(Setting.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved setting as @setting" do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Setting).to receive(:save).and_return(false)
        post :create, {:setting => {}}, valid_session
        expect(assigns(:setting)).to be_a_new(Setting)
      end

      it "re-renders the 'new' template" do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Setting).to receive(:save).and_return(false)
        post :create, {:setting => {}}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "GET edit" do
    let(:setting) { FactoryGirl.create(:setting) }
    it "assigns the requested setting as @setting" do
      set_logged_in_admin
      get :edit, {:id => setting.to_param}, valid_session
      expect(assigns(:setting)).to eq(setting)
    end
  end

  describe "PUT update" do
    let(:setting) { FactoryGirl.create(:setting) }
    describe "with valid params" do
      it "updates the requested setting" do
        set_logged_in_admin
        # Assuming there are no other settings in the database, this
        # specifies that the Setting created on the previous line
        # receives the :update message with whatever params are
        # submitted in the request.
        expect_any_instance_of(Setting).to receive(:update).with('these' => 'params')
        patch :update, { id: setting.to_param, setting: { 'these' => 'params' } }, valid_session
      end

      it "assigns the requested setting as @setting" do
        set_logged_in_admin
        patch :update, { id: setting.to_param, setting: valid_attributes }, valid_session
        expect(assigns(:setting)).to eq(setting)
      end

      it "redirects to the setting" do
        set_logged_in_admin
        patch :update, { id: setting.to_param, setting: valid_attributes }, valid_session
        expect(response).to redirect_to(setting)
      end
    end

    describe "with invalid params" do
      it "assigns the setting as @setting" do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Setting).to receive(:save).and_return(false)
        patch :update, { id: setting.to_param, setting: {} }, valid_session
        expect(assigns(:setting)).to eq(setting)
      end

      it "re-renders the 'edit' template" do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Setting).to receive(:save).and_return(false)
        patch :update, { id: setting.to_param, setting: {} }, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "GET delete" do
    let(:setting) { FactoryGirl.create(:setting) }
    it "assigns the requested setting as @setting" do
      set_logged_in_admin
      get :delete, {:id => setting.to_param}, valid_session
      expect(assigns(:setting)).to eq(setting)
    end
  end

  describe "DELETE destroy" do
    let(:setting) { FactoryGirl.create(:setting) }
    it "destroys the requested setting" do
      set_logged_in_admin
      setting # make sure it's loaded before the next block so the count will actually count it
      expect {
        delete :destroy, {:id => setting.to_param}, valid_session
      }.to change(Setting, :count).by(-1)
    end

    it "redirects to the settings list" do
      set_logged_in_admin
      delete :destroy, {:id => setting.to_param}, valid_session
      expect(response).to redirect_to(settings_url)
    end
  end

end
