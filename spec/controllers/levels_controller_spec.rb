# encoding: utf-8
require 'spec_helper'
require 'levels_controller'

describe LevelsController do

  before(:all) do
    Level.delete_all
    @level = FactoryGirl.create(:level)
    Authority.delete_all
    @user_admin = User.first || FactoryGirl.create(:user, name: 'Admin User')
    @user_admin.make_admin!
    @user_normal = User.offset(1).first || FactoryGirl.create(:user, name: 'Normal User')
    @sequence_counter = 0
  end

  def set_logged_in_admin
    controller.stub(:current_user).and_return(@user_admin)
  end
  def set_logged_in_user
    controller.stub(:current_user).and_return(@user_normal)
  end

  let(:valid_attributes) do
    @sequence_counter += 1
    $valid_attributes = { filename: "valid_#{@sequence_counter}", name: "Valid #{@sequence_counter}" }
  end
  let(:level) { $level = @level }

  describe 'GET index' do
    before(:each) do
      Level.stub(:all).and_return([level])
      get :index
    end
    it 'assigns all levels as @levels' do
      expect( assigns(:levels) ).to eq([level])
    end
    it 'assigns a title to the page_metadata' do
      expect( assigns(:page_metadata).title ).to match /Levels/
    end
    it 'renders the ‘index’ template' do
      expect( response ).to render_template('levels/index')
    end
    it 'assigns the site section' do
      expect( assigns(:site_section) ).to eq :levels
    end
  end

  describe 'GET show' do
    before(:each) do
      get :show, id: level.filename
    end
    it 'assigns the requested level as @level' do
      expect( assigns(:level) ).to eq(level)
    end
    it 'assigns a title to the page_metadata' do
      expect( assigns(:page_metadata).title ).to match /Level/
    end
    it 'renders the ‘show’ template' do
      expect( response ).to render_template('levels/show')
    end
    it 'assigns the site section' do
      expect( assigns(:site_section) ).to eq :levels
    end
  end

  describe 'GET new' do
    it 'fails if not logged in' do
      get :new
      expect( response.status ).to eq 403
    end
    it 'fails if not admin' do
      set_logged_in_user
      get :new
      expect( response.status ).to eq 403
    end
    context 'with authority' do
      before(:each) do
        set_logged_in_admin
        get :new
      end
      it 'assigns a new level as @level' do
        expect( assigns(:level) ).to be_a_new(Level)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Level/
      end
      it 'renders the ‘new’ template' do
        expect( response ).to render_template('levels/new')
      end
      it 'assigns the site section' do
        expect( assigns(:site_section) ).to eq :levels
      end
    end
    context 'with a parent_id' do
      it 'assigns the parent as @level.parent' do
        set_logged_in_admin
        get :new, { parent_id: level.filename }
        expect( assigns(:level).parent ).to eq level
      end
    end
  end

  describe 'POST create' do
    it 'fails if not logged in' do
      post :create, level: valid_attributes
      expect( response.status ).to eq 403
    end
    it 'fails if not admin' do
      set_logged_in_user
      post :create, level: valid_attributes
      expect( response.status ).to eq 403
    end

    describe 'with valid params' do
      it 'creates a new Level' do
        set_logged_in_admin
        expect {
          post :create, level: valid_attributes
        }.to change(Level, :count).by(1)
      end
      context 'without a parent_id' do
        before(:each) do
          set_logged_in_admin
          post :create, level: valid_attributes
        end
        it 'assigns a newly created level as @level' do
          expect( assigns(:level) ).to be_a(Level)
          expect( assigns(:level) ).to be_persisted
        end
        it 'notifies the user that the level was saved' do
          expect( request.flash[:notice] ).to eq 'The level has been saved.'
        end
        it 'redirects to the created level' do
          expect( response ).to redirect_to(assigns(:level))
        end
        it 'assigns the site section' do
          expect( assigns(:site_section) ).to eq :levels
        end
      end
      context 'with a parent_id' do
        it 'assigns the parent to the new level' do
          set_logged_in_admin
          post :create, { level: valid_attributes, parent_id: level.filename }
          expect( assigns(:level).parent ).to eq level
        end
      end
    end

    describe 'with invalid params' do
      before(:each) do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        Level.any_instance.stub(:save).and_return(false)
        post :create, level: {}
      end
      it 'assigns a newly created but unsaved level as @level' do
        expect( assigns(:level) ).to be_a_new(Level)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Level/
      end
      it 're-renders the ‘new’ template' do
        expect( response ).to render_template('new')
      end
    end
  end

  describe 'GET edit' do
    it 'requires the user to have authority' do
      set_logged_in_user
      get :edit, id: level.filename
      expect( response.status ).to eq 403
    end

    context 'with authority' do
      before(:each) do
        set_logged_in_admin
        get :edit, id: level.filename
      end
      it 'assigns the requested level as @level' do
        expect( assigns(:level) ).to eq(level)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Level/
      end
      it 'renders the ‘edit’ template' do
        expect( response ).to render_template('levels/edit')
      end
      it 'assigns the site section' do
        expect( assigns(:site_section) ).to eq :levels
      end
    end
  end

  describe 'PUT update' do
    it 'requires the user to have authority' do
      set_logged_in_user
      patch :update, id: level.filename, level: {}
      expect( response.status ).to eq 403
    end

    describe 'with valid params' do
      it 'updates the requested level' do
        set_logged_in_admin
        Level.any_instance.should_receive(:update).with({'these' => 'params'}).and_return(true)
        patch :update, id: level.filename, level: { 'these' => 'params' }
      end
      context 'with attributes' do
        before(:each) do
          set_logged_in_admin
          patch :update, id: level.filename, level: valid_attributes
        end
        it 'assigns the requested level as @level' do
          expect( assigns(:level) ).to eq(level)
        end
        it 'notifies the user that the level was saved' do
          expect( request.flash[:notice] ).to eq 'The level has been saved.'
        end
        it 'redirects to the level' do
          expect( response ).to redirect_to(assigns(:level))
        end
        it 'assigns the site section' do
          expect( assigns(:site_section) ).to eq :levels
        end
      end
    end

    describe 'with invalid params' do
      before(:each) do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        Level.any_instance.stub(:save).and_return(false)
        patch :update, id: level.filename, level: {}
      end
      it 'assigns the level as @level' do
        expect( assigns(:level) ).to eq(level)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Level/
      end
      it 're-renders the ‘edit’ template' do
        expect( response ).to render_template('edit')
      end
    end
  end

  describe 'GET delete' do
    it 'requires the user to have authority' do
      set_logged_in_user
      get :delete, id: level.filename
      expect( response.status ).to eq 403
    end
    context 'with authority' do
      before(:each) do
        set_logged_in_admin
        get :delete, id: level.filename
      end
      it 'shows a form for confirming deletion of an level' do
        expect( assigns(:level) ).to eq level
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Level/
      end
      it 'renders the ‘delete’ template' do
        expect( response ).to render_template('levels/delete')
      end
      it 'assigns the site section' do
        expect( assigns(:site_section) ).to eq :levels
      end
    end
  end

  describe 'DELETE destroy' do
    it 'requires the user to have authority' do
      set_logged_in_user
      delete :destroy, id: level.filename
      expect( response.status ).to eq 403
    end
    context 'with authority' do
      let(:level) { $level = FactoryGirl.create(:level) }
      before(:each) do
        set_logged_in_admin
      end
      it 'destroys the requested level' do
        level
        expect {
          delete :destroy, id: level.filename
        }.to change(Level, :count).by(-1)
      end
      it 'redirects to the levels list' do
        delete :destroy, id: level.filename
        expect( response ).to redirect_to(levels_url)
      end
    end
  end

end
