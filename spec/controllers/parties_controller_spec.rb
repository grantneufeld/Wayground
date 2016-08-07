require 'rails_helper'
require 'parties_controller'

describe PartiesController, type: :controller do

  before(:all) do
    Level.delete_all
    Party.delete_all
    @level = FactoryGirl.create(:level, name: 'Parties Controller Level', filename: 'parties_controller_level')
    @party = FactoryGirl.create(:party, level: @level)
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
    $valid_attributes = {
      filename: "valid_#{@sequence_counter}", name: "Valid #{@sequence_counter}",
      abbrev: "val#{@sequence_counter}", ended_on: '2013-10-18'
    }
  end
  let(:party) { $party = @party }

  describe 'GET index' do
    before(:each) do
      allow(@level).to receive(:parties).and_return([party])
      get :index, level_id: @level.to_param
    end
    it 'assigns all parties as @parties' do
      expect( assigns(:parties) ).to eq([party])
    end
    it 'assigns a title to the page_metadata' do
      expect( assigns(:page_metadata).title ).to match /Parties/
    end
    it 'renders the ‘index’ template' do
      expect( response ).to render_template('parties/index')
    end
    it 'assigns the site section' do
      expect( assigns(:site_section) ).to eq :parties
    end
  end

  describe 'GET show' do
    before(:each) do
      get :show, id: party.filename, level_id: @level.to_param
    end
    it 'assigns the requested party as @party' do
      expect( assigns(:party) ).to eq(party)
    end
    it 'assigns a title to the page_metadata' do
      expect( assigns(:page_metadata).title ).to match /Party/
    end
    it 'renders the ‘show’ template' do
      expect( response ).to render_template('parties/show')
    end
    it 'assigns the site section' do
      expect( assigns(:site_section) ).to eq :parties
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
      it 'assigns a new party as @party' do
        expect( assigns(:party) ).to be_a_new(Party)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Party/
      end
      it 'renders the ‘new’ template' do
        expect( response ).to render_template('parties/new')
      end
      it 'assigns the site section' do
        expect( assigns(:site_section) ).to eq :parties
      end
    end
  end

  describe 'POST create' do
    it 'fails if not logged in' do
      post :create, party: valid_attributes, level_id: @level.to_param
      expect( response.status ).to eq 403
    end
    it 'fails if not admin' do
      set_logged_in_user
      post :create, party: valid_attributes, level_id: @level.to_param
      expect( response.status ).to eq 403
    end

    describe 'with valid params' do
      before(:each) do
        set_logged_in_admin
      end
      it 'creates a new Party' do
        expect {
          post :create, party: valid_attributes, level_id: @level.to_param
        }.to change(Party, :count).by(1)
      end
      context '...' do
        before(:each) do
          post :create, party: valid_attributes, level_id: @level.to_param
        end
        it 'assigns a newly created party as @party' do
          expect( assigns(:party) ).to be_a(Party)
          expect( assigns(:party) ).to be_persisted
        end
        it 'notifies the user that the party was saved' do
          expect( request.flash[:notice] ).to eq 'The party has been saved.'
        end
        it 'redirects to the created party' do
          expect( response ).to redirect_to([@level, assigns(:party)])
        end
        it 'assigns the site section' do
          expect( assigns(:site_section) ).to eq :parties
        end
      end
    end

    describe 'with invalid params' do
      before(:each) do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Party).to receive(:save).and_return(false)
        post :create, party: {}, level_id: @level.to_param
      end
      it 'assigns a newly created but unsaved party as @party' do
        expect( assigns(:party) ).to be_a_new(Party)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Party/
      end
      it 're-renders the ‘new’ template' do
        expect( response ).to render_template('new')
      end
    end
  end

  describe 'GET edit' do
    it 'requires the user to have authority' do
      set_logged_in_user
      get :edit, id: party.filename, level_id: @level.to_param
      expect( response.status ).to eq 403
    end

    context 'with authority' do
      before(:each) do
        set_logged_in_admin
        get :edit, id: party.filename, level_id: @level.to_param
      end
      it 'assigns the requested party as @party' do
        expect( assigns(:party) ).to eq(party)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Party/
      end
      it 'renders the ‘edit’ template' do
        expect( response ).to render_template('parties/edit')
      end
      it 'assigns the site section' do
        expect( assigns(:site_section) ).to eq :parties
      end
    end
  end

  describe 'PUT update' do
    it 'requires the user to have authority' do
      set_logged_in_user
      patch :update, id: party.filename, party: {}, level_id: @level.to_param
      expect( response.status ).to eq 403
    end

    describe 'with valid params' do
      it 'updates the requested party' do
        set_logged_in_admin
        expected_params = ActionController::Parameters.new('name' => 'valid params').permit!
        expect_any_instance_of(Party).to receive(:update).with(expected_params).and_return(true)
        patch :update, id: party.filename, party: { 'name' => 'valid params' }, level_id: @level.to_param
      end
      context 'with attributes' do
        before(:each) do
          set_logged_in_admin
          allow_any_instance_of(Party).to receive(:update).and_return(true)
          patch :update, id: party.filename, party: valid_attributes, level_id: @level.to_param
        end
        it 'assigns the requested party as @party' do
          expect( assigns(:party) ).to eq(party)
        end
        it 'notifies the user that the party was saved' do
          expect( request.flash[:notice] ).to eq 'The party has been saved.'
        end
        it 'redirects to the party' do
          expect( response ).to redirect_to([@level, assigns(:party)])
        end
        it 'assigns the site section' do
          expect( assigns(:site_section) ).to eq :parties
        end
      end
    end

    describe 'with invalid params' do
      before(:all) do
        @invalid_party = FactoryGirl.build(:party, level: @level, filename: 'invalidparty')
      end
      let(:party) { @invalid_party }
      before(:each) do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow(party).to receive(:save).and_return(false)
        allow_any_instance_of(Level).to receive_message_chain(:parties, :from_param).and_return([party])
        patch :update, id: party.filename, party: {}, level_id: @level.to_param
      end
      it 'assigns the party as @party' do
        expect( assigns(:party) ).to eq(party)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Party/
      end
      it 're-renders the ‘edit’ template' do
        expect( response ).to render_template('edit')
      end
    end
  end

  describe 'GET delete' do
    it 'requires the user to have authority' do
      set_logged_in_user
      get :delete, id: party.filename, level_id: @level.to_param
      expect( response.status ).to eq 403
    end
    context 'with authority' do
      before(:each) do
        set_logged_in_admin
        allow(party).to receive(:destroy).and_return(party)
        allow_any_instance_of(Level).to receive_message_chain(:parties, :from_param).and_return([party])
        get :delete, id: party.filename, level_id: @level.to_param
      end
      it 'shows a form for confirming deletion of an party' do
        expect( assigns(:party) ).to eq party
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Party/
      end
      it 'renders the ‘delete’ template' do
        expect( response ).to render_template('parties/delete')
      end
      it 'assigns the site section' do
        expect( assigns(:site_section) ).to eq :parties
      end
    end
  end

  describe 'DELETE destroy' do
    it 'requires the user to have authority' do
      set_logged_in_user
      delete :destroy, id: party.filename, level_id: @level.to_param
      expect( response.status ).to eq 403
    end
    context 'with authority' do
      let(:party) { $party = FactoryGirl.create(:party, level: @level) }
      before(:each) do
        set_logged_in_admin
      end
      it 'destroys the requested party' do
        party
        expect {
          delete :destroy, id: party.filename, level_id: @level.to_param
        }.to change(Party, :count).by(-1)
      end
      it 'redirects to the parties list' do
        delete :destroy, id: party.filename, level_id: @level.to_param
        expect( response ).to redirect_to(level_parties_url(@level))
      end
    end
  end

end
