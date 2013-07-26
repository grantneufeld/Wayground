# encoding: utf-8
require 'spec_helper'
require 'ballots_controller'

describe BallotsController do

  before(:all) do
    Level.delete_all
    Election.delete_all
    Office.delete_all
    Ballot.delete_all
    @level = FactoryGirl.create(:level, name: 'Ballots Controller Level', filename: 'ballots_controller_level')
    @election = FactoryGirl.create(:election, level: @level, name: 'Ballots Controller Election', filename: 'ballots_controller_election')
    @office = FactoryGirl.create(:office, level: @level, name: 'Ballots Controller Office', filename: 'ballots_controller_office')
    @ballot = FactoryGirl.create(:ballot, election: @election, office: @office)
    Authority.delete_all
    @user_admin = User.first || FactoryGirl.create(:user, name: 'Admin User')
    @user_admin.make_admin!
    @user_normal = User.offset(1).first || FactoryGirl.create(:user, name: 'Normal User')
    @sequence_counter = 0
  end

  def set_logged_in_admin
    controller.stub!(:current_user).and_return(@user_admin)
  end
  def set_logged_in_user
    controller.stub!(:current_user).and_return(@user_normal)
  end

  let(:valid_attributes) do
    @sequence_counter += 1
    $valid_attributes = {
      term_start_on: '2013-10-19', term_end_on: '2017-10-18', is_byelection: '1',
      url: "http://valid.url/#{@sequence_counter}", description: "Valid #{@sequence_counter}."
    }
  end
  let(:ballot) { $ballot = @ballot }

  describe 'GET index' do
    before(:each) do
      @election.stub(:ballots).and_return([ballot])
      get :index, level_id: @level.to_param, election_id: @election.to_param
    end
    it 'assigns all ballots as @ballots' do
      expect( assigns(:ballots) ).to eq([ballot])
    end
    it 'assigns a title to the page_metadata' do
      expect( assigns(:page_metadata).title ).to match /Ballots/
    end
    it 'renders the ‘index’ template' do
      expect( response ).to render_template('ballots/index')
    end
    it 'assigns the site section' do
      expect( assigns(:site_section) ).to eq :ballots
    end
  end

  describe 'GET show' do
    before(:each) do
      get :show, id: ballot.to_param, level_id: @level.to_param, election_id: @election.to_param
    end
    it 'assigns the requested ballot as @ballot' do
      expect( assigns(:ballot) ).to eq(ballot)
    end
    it 'assigns a title to the page_metadata' do
      expect( assigns(:page_metadata).title ).to match /Ballot/
    end
    it 'renders the ‘show’ template' do
      expect( response ).to render_template('ballots/show')
    end
    it 'assigns the site section' do
      expect( assigns(:site_section) ).to eq :ballots
    end
  end

  describe 'GET new' do
    it 'fails if not logged in' do
      get :new, level_id: @level.to_param, election_id: @election.to_param
      expect( response.status ).to eq 403
    end
    it 'fails if not admin' do
      set_logged_in_user
      get :new, level_id: @level.to_param, election_id: @election.to_param
      expect( response.status ).to eq 403
    end
    context 'with authority' do
      before(:each) do
        set_logged_in_admin
        get :new, level_id: @level.to_param, election_id: @election.to_param
      end
      it 'assigns a new ballot as @ballot' do
        expect( assigns(:ballot) ).to be_a_new(Ballot)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Ballot/
      end
      it 'renders the ‘new’ template' do
        expect( response ).to render_template('ballots/new')
      end
      it 'assigns the site section' do
        expect( assigns(:site_section) ).to eq :ballots
      end
    end
  end

  describe 'POST create' do
    it 'fails if not logged in' do
      post :create, ballot: valid_attributes, level_id: @level.to_param, election_id: @election.to_param
      expect( response.status ).to eq 403
    end
    it 'fails if not admin' do
      set_logged_in_user
      post :create, ballot: valid_attributes, level_id: @level.to_param, election_id: @election.to_param
      expect( response.status ).to eq 403
    end

    describe 'with valid params' do
      before(:all) do
        @create_office = FactoryGirl.create(:office, level: @level, filename: 'office_for_create_ballot')
      end
      before(:each) do
        set_logged_in_admin
      end
      after(:each) do
        assigns(:ballot).delete if assigns(:ballot)
      end
      it 'creates a new Ballot' do
        expect {
          post(:create, ballot: valid_attributes,
            level_id: @level.to_param, election_id: @election.to_param, office_id: @create_office.to_param
          )
        }.to change(Ballot, :count).by(1)
      end
      context '...' do
        before(:each) do
          post(:create, ballot: valid_attributes,
            level_id: @level.to_param, election_id: @election.to_param, office_id: @create_office.to_param
          )
        end
        it 'assigns a newly created ballot as @ballot' do
          expect( assigns(:ballot) ).to be_a(Ballot)
          expect( assigns(:ballot) ).to be_persisted
        end
        it 'notifies the user that the ballot was saved' do
          expect( request.flash[:notice] ).to eq 'The ballot has been saved.'
        end
        it 'redirects to the created ballot' do
          expect( response ).to redirect_to([@level, @election, assigns(:ballot)])
        end
        it 'assigns the site section' do
          expect( assigns(:site_section) ).to eq :ballots
        end
      end
    end

    describe 'with invalid params' do
      before(:each) do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        Ballot.any_instance.stub(:save).and_return(false)
        post :create, ballot: {}, level_id: @level.to_param, election_id: @election.to_param
      end
      it 'assigns a newly created but unsaved ballot as @ballot' do
        expect( assigns(:ballot) ).to be_a_new(Ballot)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Ballot/
      end
      it 're-renders the ‘new’ template' do
        expect( response ).to render_template('new')
      end
    end
  end

  describe 'GET edit' do
    it 'requires the user to have authority' do
      set_logged_in_user
      get :edit, id: ballot.to_param, level_id: @level.to_param, election_id: @election.to_param
      expect( response.status ).to eq 403
    end

    context 'with authority' do
      before(:each) do
        set_logged_in_admin
        get :edit, id: ballot.to_param, level_id: @level.to_param, election_id: @election.to_param
      end
      it 'assigns the requested ballot as @ballot' do
        expect( assigns(:ballot) ).to eq(ballot)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Ballot/
      end
      it 'renders the ‘edit’ template' do
        expect( response ).to render_template('ballots/edit')
      end
      it 'assigns the site section' do
        expect( assigns(:site_section) ).to eq :ballots
      end
    end
  end

  describe 'PUT update' do
    it 'requires the user to have authority' do
      set_logged_in_user
      patch :update, id: ballot.to_param, ballot: {}, level_id: @level.to_param, election_id: @election.to_param
      expect( response.status ).to eq 403
    end

    describe 'with valid params' do
      it 'updates the requested ballot' do
        set_logged_in_admin
        Ballot.any_instance.should_receive(:update).with({'these' => 'params'}).and_return(true)
        patch :update, id: ballot.to_param, ballot: { 'these' => 'params' }, level_id: @level.to_param, election_id: @election.to_param
      end
      context 'with attributes' do
        before(:each) do
          set_logged_in_admin
          patch :update, id: ballot.to_param, ballot: valid_attributes, level_id: @level.to_param, election_id: @election.to_param
        end
        it 'assigns the requested ballot as @ballot' do
          expect( assigns(:ballot) ).to eq(ballot)
        end
        it 'notifies the user that the ballot was saved' do
          expect( request.flash[:notice] ).to eq 'The ballot has been saved.'
        end
        it 'redirects to the ballot' do
          expect( response ).to redirect_to([@level, @election, assigns(:ballot)])
        end
        it 'assigns the site section' do
          expect( assigns(:site_section) ).to eq :ballots
        end
      end
    end

    describe 'with invalid params' do
      before(:each) do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        Ballot.any_instance.stub(:save).and_return(false)
        patch :update, id: ballot.to_param, ballot: {}, level_id: @level.to_param, election_id: @election.to_param
      end
      it 'assigns the ballot as @ballot' do
        expect( assigns(:ballot) ).to eq(ballot)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Ballot/
      end
      it 're-renders the ‘edit’ template' do
        expect( response ).to render_template('edit')
      end
    end
  end

  describe 'GET delete' do
    it 'requires the user to have authority' do
      set_logged_in_user
      get :delete, id: ballot.to_param, level_id: @level.to_param, election_id: @election.to_param
      expect( response.status ).to eq 403
    end
    context 'with authority' do
      before(:each) do
        set_logged_in_admin
        get :delete, id: ballot.to_param, level_id: @level.to_param, election_id: @election.to_param
      end
      it 'shows a form for confirming deletion of an ballot' do
        expect( assigns(:ballot) ).to eq ballot
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Ballot/
      end
      it 'renders the ‘delete’ template' do
        expect( response ).to render_template('ballots/delete')
      end
      it 'assigns the site section' do
        expect( assigns(:site_section) ).to eq :ballots
      end
    end
  end

  describe 'DELETE destroy' do
    it 'requires the user to have authority' do
      set_logged_in_user
      delete :destroy, id: ballot.to_param, level_id: @level.to_param, election_id: @election.to_param
      expect( response.status ).to eq 403
    end
    context 'with authority' do
      let(:ballot) { $ballot = FactoryGirl.create(:ballot, election: @election) }
      before(:each) do
        set_logged_in_admin
      end
      it 'destroys the requested ballot' do
        ballot
        expect {
          delete :destroy, id: ballot.to_param, level_id: @level.to_param, election_id: @election.to_param
        }.to change(Ballot, :count).by(-1)
      end
      it 'redirects to the ballots list' do
        delete :destroy, id: ballot.to_param, level_id: @level.to_param, election_id: @election.to_param
        expect( response ).to redirect_to(level_election_ballots_url(@level, @election))
      end
    end
  end

end
