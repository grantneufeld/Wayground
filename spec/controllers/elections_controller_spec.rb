require 'rails_helper'
require 'elections_controller'
require 'democracy/election_builder'

describe ElectionsController, type: :controller do

  before(:all) do
    Level.delete_all
    Election.delete_all
    @level = FactoryGirl.create(:level, name: 'Elections Controller Level', filename: 'elections_controller_level')
    @election = FactoryGirl.create(:election, level: @level)
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
      filename: "valid_#{@sequence_counter}", name: "Valid #{@sequence_counter}", end_on: '2013-10-18'
    }
  end
  let(:election) { $election = @election }

  describe 'GET index' do
    before(:each) do
      allow(@level).to receive(:elections).and_return([election])
      get :index, level_id: @level.to_param
    end
    it 'assigns all elections as @elections' do
      expect( assigns(:elections) ).to eq([election])
    end
    it 'assigns a title to the page_metadata' do
      expect( assigns(:page_metadata).title ).to match /Elections/
    end
    it 'renders the ‘index’ template' do
      expect( response ).to render_template('elections/index')
    end
    it 'assigns the site section' do
      expect( assigns(:site_section) ).to eq :elections
    end
  end

  describe 'GET show' do
    before(:each) do
      get :show, id: election.filename, level_id: @level.to_param
    end
    it 'assigns the requested election as @election' do
      expect( assigns(:election) ).to eq(election)
    end
    it 'assigns a title to the page_metadata' do
      expect( assigns(:page_metadata).title ).to match /Election/
    end
    it 'renders the ‘show’ template' do
      expect( response ).to render_template('elections/show')
    end
    it 'assigns the site section' do
      expect( assigns(:site_section) ).to eq :elections
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
      it 'assigns a new election as @election' do
        expect( assigns(:election) ).to be_a_new(Election)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Election/
      end
      it 'renders the ‘new’ template' do
        expect( response ).to render_template('elections/new')
      end
      it 'assigns the site section' do
        expect( assigns(:site_section) ).to eq :elections
      end
    end
  end

  describe 'POST create' do
    it 'fails if not logged in' do
      post :create, election: valid_attributes, level_id: @level.to_param
      expect( response.status ).to eq 403
    end
    it 'fails if not admin' do
      set_logged_in_user
      post :create, election: valid_attributes, level_id: @level.to_param
      expect( response.status ).to eq 403
    end

    describe 'with valid params' do
      before(:each) do
        set_logged_in_admin
      end
      it 'creates a new Election' do
        expect {
          post :create, election: valid_attributes, level_id: @level.to_param
        }.to change(Election, :count).by(1)
      end
      context '...' do
        before(:each) do
          post :create, election: valid_attributes, level_id: @level.to_param
        end
        it 'assigns a newly created election as @election' do
          expect( assigns(:election) ).to be_a(Election)
          expect( assigns(:election) ).to be_persisted
        end
        it 'notifies the user that the election was saved' do
          expect( request.flash[:notice] ).to eq 'The election has been saved.'
        end
        it 'redirects to the created election' do
          expect( response ).to redirect_to([@level, assigns(:election)])
        end
        it 'assigns the site section' do
          expect( assigns(:site_section) ).to eq :elections
        end
      end
    end

    describe 'with invalid params' do
      before(:each) do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Election).to receive(:save).and_return(false)
        post :create, election: {}, level_id: @level.to_param
      end
      it 'assigns a newly created but unsaved election as @election' do
        expect( assigns(:election) ).to be_a_new(Election)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Election/
      end
      it 're-renders the ‘new’ template' do
        expect( response ).to render_template('new')
      end
    end
  end

  describe 'GET edit' do
    it 'requires the user to have authority' do
      set_logged_in_user
      get :edit, id: election.filename, level_id: @level.to_param
      expect( response.status ).to eq 403
    end

    context 'with authority' do
      before(:each) do
        set_logged_in_admin
        get :edit, id: election.filename, level_id: @level.to_param
      end
      it 'assigns the requested election as @election' do
        expect( assigns(:election) ).to eq(election)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Election/
      end
      it 'renders the ‘edit’ template' do
        expect( response ).to render_template('elections/edit')
      end
      it 'assigns the site section' do
        expect( assigns(:site_section) ).to eq :elections
      end
    end
  end

  describe 'PUT update' do
    it 'requires the user to have authority' do
      set_logged_in_user
      patch :update, id: election.filename, election: {}, level_id: @level.to_param
      expect( response.status ).to eq 403
    end

    describe 'with valid params' do
      it 'updates the requested election' do
        set_logged_in_admin
        expect_any_instance_of(Election).to receive(:update).with({'these' => 'params'}).and_return(true)
        patch :update, id: election.filename, election: { 'these' => 'params' }, level_id: @level.to_param
      end
      context 'with attributes' do
        before(:each) do
          set_logged_in_admin
          patch :update, id: election.filename, election: valid_attributes, level_id: @level.to_param
        end
        it 'assigns the requested election as @election' do
          expect( assigns(:election) ).to eq(election)
        end
        it 'notifies the user that the election was saved' do
          expect( request.flash[:notice] ).to eq 'The election has been saved.'
        end
        it 'redirects to the election' do
          expect( response ).to redirect_to([@level, assigns(:election)])
        end
        it 'assigns the site section' do
          expect( assigns(:site_section) ).to eq :elections
        end
      end
    end

    describe 'with invalid params' do
      before(:each) do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Election).to receive(:save).and_return(false)
        patch :update, id: election.filename, election: {}, level_id: @level.to_param
      end
      it 'assigns the election as @election' do
        expect( assigns(:election) ).to eq(election)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Election/
      end
      it 're-renders the ‘edit’ template' do
        expect( response ).to render_template('edit')
      end
    end
  end

  describe 'GET delete' do
    it 'requires the user to have authority' do
      set_logged_in_user
      get :delete, id: election.filename, level_id: @level.to_param
      expect( response.status ).to eq 403
    end
    context 'with authority' do
      before(:each) do
        set_logged_in_admin
        get :delete, id: election.filename, level_id: @level.to_param
      end
      it 'shows a form for confirming deletion of an election' do
        expect( assigns(:election) ).to eq election
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Election/
      end
      it 'renders the ‘delete’ template' do
        expect( response ).to render_template('elections/delete')
      end
      it 'assigns the site section' do
        expect( assigns(:site_section) ).to eq :elections
      end
    end
  end

  describe 'DELETE destroy' do
    it 'requires the user to have authority' do
      set_logged_in_user
      delete :destroy, id: election.filename, level_id: @level.to_param
      expect( response.status ).to eq 403
    end
    context 'with authority' do
      let(:election) { $election = FactoryGirl.create(:election, level: @level) }
      before(:each) do
        set_logged_in_admin
      end
      it 'destroys the requested election' do
        election
        expect {
          delete :destroy, id: election.filename, level_id: @level.to_param
        }.to change(Election, :count).by(-1)
      end
      it 'redirects to the elections list' do
        delete :destroy, id: election.filename, level_id: @level.to_param
        expect( response ).to redirect_to(level_elections_url(@level))
      end
    end
  end

  describe 'GET ballot_maker' do
    it 'requires the user to have authority' do
      set_logged_in_user
      get :ballot_maker, id: election.filename, level_id: @level.to_param
      expect(response.status).to eq 403
    end
    context 'with authority' do
      before(:each) do
        set_logged_in_admin
        get :ballot_maker, id: election.filename, level_id: @level.to_param
      end
      it 'assigns the election' do
        expect(assigns(:election)).to eq election
      end
      it 'assigns a title to the page_metadata' do
        expect(assigns(:page_metadata).title).to match /Generate Ballots/
      end
      it 'renders the ‘ballot_maker’ template' do
        expect(response).to render_template('elections/ballot_maker')
      end
      it 'assigns the site section' do
        expect(assigns(:site_section)).to eq :elections
      end
    end
  end

  describe 'POST generate_ballots' do
    it 'requires the user to have authority' do
      set_logged_in_user
      post :generate_ballots, id: election.filename, level_id: @level.to_param
      expect(response.status).to eq 403
    end
    context 'with authority' do
      before(:each) do
        set_logged_in_admin
      end
      it 'assigns the election' do
        post :generate_ballots, id: election.filename, level_id: @level.to_param
        expect(assigns(:election)).to eq election
      end
      it 'assigns a title to the page_metadata' do
        post :generate_ballots, id: election.filename, level_id: @level.to_param
        expect(assigns(:page_metadata).title).to match /Generate Ballots/
      end
      it 'assigns the site section' do
        post :generate_ballots, id: election.filename, level_id: @level.to_param
        expect(assigns(:site_section)).to eq :elections
      end
      it 'uses the date parameters' do
        builder = Wayground::Democracy::ElectionBuilder.new(election: election)
        allow(builder).to receive(:generate_ballots).and_return([])
        expect(Wayground::Democracy::ElectionBuilder).to receive(:new).with(
          election: election, term_start_on: '2001-02-03'.to_date, term_end_on: '2002-03-04'.to_date
        ).and_return(builder)
        post :generate_ballots, id: election.filename, level_id: @level.to_param, term_start_on: '2001-02-03', term_end_on: '2002-03-04'
      end
      it 'assigns the ballots' do
        ballot = Ballot.new
        ballots = [ballot]
        builder = Wayground::Democracy::ElectionBuilder.new(election: election)
        allow(builder).to receive(:generate_ballots).and_return(ballots)
        allow(Wayground::Democracy::ElectionBuilder).to receive(:new).and_return(builder)
        post :generate_ballots, id: election.filename, level_id: @level.to_param
        expect(assigns(:ballots)).to eq [ballot]
      end
      it 'renders the ‘generate_ballots’ template' do
        post :generate_ballots, id: election.filename, level_id: @level.to_param
        expect(response).to render_template('elections/generate_ballots')
      end
    end
  end

end
