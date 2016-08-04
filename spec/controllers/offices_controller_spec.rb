require 'rails_helper'
require 'offices_controller'

describe OfficesController, type: :controller do

  before(:all) do
    Level.delete_all
    Office.delete_all
    @level = FactoryGirl.create(:level, name: 'Offices Controller Level', filename: 'offices_controller_level')
    @office = FactoryGirl.create(:office, level: @level)
    Authority.delete_all
    @user_admin = User.first || FactoryGirl.create(:user, name: 'Admin User')
    @user_admin.make_admin!
    @user_normal = User.offset(1).first || FactoryGirl.create(:user, name: 'Normal User')
    @sequence_counter = 0
  end

  def set_logged_in_admin
    allow(controller).to receive(:current_user).and_return(@user_admin)
  end
  def set_logged_in_user
    allow(controller).to receive(:current_user).and_return(@user_normal)
  end

  let(:valid_attributes) do
    @sequence_counter += 1
    $valid_attributes = { filename: "valid_#{@sequence_counter}", name: "Valid #{@sequence_counter}" }
  end
  let(:office) { $office = @office }

  describe 'GET index' do
    before(:each) do
      allow(@level).to receive(:offices).and_return([office])
      get :index, level_id: @level.to_param
    end
    it 'assigns all offices as @offices' do
      expect( assigns(:offices) ).to eq([office])
    end
    it 'assigns a title to the page_metadata' do
      expect( assigns(:page_metadata).title ).to match /Offices/
    end
    it 'renders the ‘index’ template' do
      expect( response ).to render_template('offices/index')
    end
    it 'assigns the site section' do
      expect( assigns(:site_section) ).to eq :offices
    end
  end

  describe 'GET show' do
    before(:each) do
      get :show, id: office.filename, level_id: @level.to_param
    end
    it 'assigns the requested office as @office' do
      expect( assigns(:office) ).to eq(office)
    end
    it 'assigns a title to the page_metadata' do
      expect( assigns(:page_metadata).title ).to match /Office/
    end
    it 'renders the ‘show’ template' do
      expect( response ).to render_template('offices/show')
    end
    it 'assigns the site section' do
      expect( assigns(:site_section) ).to eq :offices
    end
  end

  describe 'GET new' do
    it 'fails if not logged in' do
      get :new, level_id: @level.to_param
      expect( response.status ).to eq 403
    end
    it 'fails if not admin' do
      set_logged_in_user
      get :new, level_id: @level.to_param
      expect( response.status ).to eq 403
    end
    context 'with authority' do
      before(:each) do
        set_logged_in_admin
        get :new, level_id: @level.to_param
      end
      it 'assigns a new office as @office' do
        expect( assigns(:office) ).to be_a_new(Office)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Office/
      end
      it 'renders the ‘new’ template' do
        expect( response ).to render_template('offices/new')
      end
      it 'assigns the site section' do
        expect( assigns(:site_section) ).to eq :offices
      end
    end
    context 'with a previous_id' do
      it 'assigns the previous as @office.previous' do
        set_logged_in_admin
        get :new, previous_id: office.filename, level_id: @level.to_param
        expect( assigns(:office).previous ).to eq office
      end
    end
  end

  describe 'POST create' do
    it 'fails if not logged in' do
      post :create, office: valid_attributes, level_id: @level.to_param
      expect( response.status ).to eq 403
    end
    it 'fails if not admin' do
      set_logged_in_user
      post :create, office: valid_attributes, level_id: @level.to_param
      expect( response.status ).to eq 403
    end

    describe 'with valid params' do
      it 'creates a new Office' do
        set_logged_in_admin
        expect {
          post :create, office: valid_attributes, level_id: @level.to_param
        }.to change(Office, :count).by(1)
      end
      context 'without a previous_id' do
        before(:each) do
          set_logged_in_admin
          post :create, office: valid_attributes, level_id: @level.to_param
        end
        it 'assigns a newly created office as @office' do
          expect( assigns(:office) ).to be_a(Office)
          expect( assigns(:office) ).to be_persisted
        end
        it 'notifies the user that the office was saved' do
          expect( request.flash[:notice] ).to eq 'The office has been saved.'
        end
        it 'redirects to the created office' do
          expect( response ).to redirect_to([@level, assigns(:office)])
        end
        it 'assigns the site section' do
          expect( assigns(:site_section) ).to eq :offices
        end
      end
      context 'with a previous_id' do
        it 'assigns the previous to the new office' do
          set_logged_in_admin
          post :create, office: valid_attributes, previous_id: office.filename, level_id: @level.to_param
          expect( assigns(:office).previous ).to eq office
        end
      end
    end

    describe 'with invalid params' do
      before(:each) do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Office).to receive(:save).and_return(false)
        post :create, office: {}, level_id: @level.to_param
      end
      it 'assigns a newly created but unsaved office as @office' do
        expect( assigns(:office) ).to be_a_new(Office)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Office/
      end
      it 're-renders the ‘new’ template' do
        expect( response ).to render_template('new')
      end
    end
  end

  describe 'GET edit' do
    it 'requires the user to have authority' do
      set_logged_in_user
      get :edit, id: office.filename, level_id: @level.to_param
      expect( response.status ).to eq 403
    end

    context 'with authority' do
      before(:each) do
        set_logged_in_admin
        get :edit, id: office.filename, level_id: @level.to_param
      end
      it 'assigns the requested office as @office' do
        expect( assigns(:office) ).to eq(office)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Office/
      end
      it 'renders the ‘edit’ template' do
        expect( response ).to render_template('offices/edit')
      end
      it 'assigns the site section' do
        expect( assigns(:site_section) ).to eq :offices
      end
    end
  end

  describe 'PUT update' do
    it 'requires the user to have authority' do
      set_logged_in_user
      patch :update, id: office.filename, office: {}, level_id: @level.to_param
      expect( response.status ).to eq 403
    end

    describe 'with valid params' do
      it 'updates the requested office' do
        set_logged_in_admin
        expect_any_instance_of(Office).to receive(:update).with('name' => 'valid params').and_return(true)
        patch :update, id: office.filename, office: { 'name' => 'valid params' }, level_id: @level.to_param
      end
      context 'with attributes' do
        before(:each) do
          set_logged_in_admin
          patch :update, id: office.filename, office: valid_attributes, level_id: @level.to_param
        end
        it 'assigns the requested office as @office' do
          expect( assigns(:office) ).to eq(office)
        end
        it 'notifies the user that the office was saved' do
          expect( request.flash[:notice] ).to eq 'The office has been saved.'
        end
        it 'redirects to the office' do
          expect( response ).to redirect_to([@level, assigns(:office)])
        end
        it 'assigns the site section' do
          expect( assigns(:site_section) ).to eq :offices
        end
      end
    end

    describe 'with invalid params' do
      before(:each) do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Office).to receive(:save).and_return(false)
        patch :update, id: office.filename, office: {}, level_id: @level.to_param
      end
      it 'assigns the office as @office' do
        expect( assigns(:office) ).to eq(office)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Office/
      end
      it 're-renders the ‘edit’ template' do
        expect( response ).to render_template('edit')
      end
    end
  end

  describe 'GET delete' do
    it 'requires the user to have authority' do
      set_logged_in_user
      get :delete, id: office.filename, level_id: @level.to_param
      expect( response.status ).to eq 403
    end
    context 'with authority' do
      before(:each) do
        set_logged_in_admin
        get :delete, id: office.filename, level_id: @level.to_param
      end
      it 'shows a form for confirming deletion of an office' do
        expect( assigns(:office) ).to eq office
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Office/
      end
      it 'renders the ‘delete’ template' do
        expect( response ).to render_template('offices/delete')
      end
      it 'assigns the site section' do
        expect( assigns(:site_section) ).to eq :offices
      end
    end
  end

  describe 'DELETE destroy' do
    it 'requires the user to have authority' do
      set_logged_in_user
      delete :destroy, id: office.filename, level_id: @level.to_param
      expect( response.status ).to eq 403
    end
    context 'with authority' do
      let(:office) { $office = FactoryGirl.create(:office, level: @level) }
      before(:each) do
        set_logged_in_admin
      end
      it 'destroys the requested office' do
        office
        expect {
          delete :destroy, id: office.filename, level_id: @level.to_param
        }.to change(Office, :count).by(-1)
      end
      it 'redirects to the offices list' do
        delete :destroy, id: office.filename, level_id: @level.to_param
        expect( response ).to redirect_to(level_offices_url(@level))
      end
    end
  end

end
