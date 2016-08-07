require 'rails_helper'
require 'candidates_controller'
require 'level'
require 'election'
require 'office'
require 'ballot'
require 'person'
require 'candidate'
require 'authority'
require 'democracy/candidate_form'

describe CandidatesController, type: :controller do

  before(:all) do
    Level.delete_all
    Election.delete_all
    Office.delete_all
    Ballot.delete_all
    Person.delete_all
    Candidate.delete_all
    @level = FactoryGirl.create(:level,
      name: 'Candidates Controller Level', filename: 'candidates_controller_level'
    )
    @election = FactoryGirl.create(:election,
      level: @level, name: 'Candidates Controller Election', filename: 'candidates_controller_election'
    )
    @office = FactoryGirl.create(:office,
      level: @level, name: 'Candidates Controller Office', filename: 'candidates_controller_office'
    )
    @ballot = FactoryGirl.create(:ballot, election: @election, office: @office)
    @person = FactoryGirl.create(:person,
      fullname: 'Candidates Controller Person', filename: 'candidates_controller_person'
    )
    @candidate = FactoryGirl.create(:candidate, ballot: @ballot, party: nil)
    Authority.delete_all
    @user_admin = User.first || FactoryGirl.create(:user, name: 'Admin User')
    @user_admin.make_admin!
    @user_normal = User.offset(1).first || FactoryGirl.create(:user, name: 'Normal User')
  end

  def set_logged_in_admin
    allow(controller).to receive(:current_user).and_return(@user_admin)
  end
  def set_logged_in_user
    allow(controller).to receive(:current_user).and_return(@user_normal)
  end

  let(:valid_attributes) do
    $valid_attributes = {
      announced_on: '2013-10-19', quit_on: '2017-10-18',
      is_rumoured: '0', is_confirmed: '1', is_incumbent: '0', is_leader: '0',
      is_acclaimed: '0', is_elected: '0',
      vote_count: '1234'
    }
  end
  let(:candidate) { $candidate = @candidate }

  describe 'GET index' do
    before(:each) do
      allow(@ballot).to receive(:candidates).and_return([candidate])
      get :index, params: { level_id: @level.to_param, election_id: @election.to_param, ballot_id: @ballot.to_param }
    end
    it 'assigns all candidates as @candidates' do
      expect( assigns(:candidates) ).to eq([candidate])
    end
    it 'assigns a title to the page_metadata' do
      expect( assigns(:page_metadata).title ).to match /Candidates/
    end
    it 'renders the ‘index’ template' do
      expect( response ).to render_template('candidates/index')
    end
    it 'assigns the site section' do
      expect( assigns(:site_section) ).to eq :candidates
    end
  end

  describe 'GET show' do
    before(:each) do
      get(
        :show,
        params: {
          id: candidate.to_param, level_id: @level.to_param,
          election_id: @election.to_param, ballot_id: @ballot.to_param
        }
      )
    end
    it 'assigns the requested candidate as @candidate' do
      expect( assigns(:candidate) ).to eq(candidate)
    end
    it 'assigns a title to the page_metadata' do
      expect( assigns(:page_metadata).title ).to match /Candidate/
    end
    it 'renders the ‘show’ template' do
      expect( response ).to render_template('candidates/show')
    end
    it 'assigns the site section' do
      expect( assigns(:site_section) ).to eq :candidates
    end
  end

  describe 'GET new' do
    it 'fails if not logged in' do
      get :new, params: { level_id: @level.to_param, election_id: @election.to_param, ballot_id: @ballot.to_param }
      expect( response.status ).to eq 403
    end
    it 'fails if not admin' do
      set_logged_in_user
      get :new, params: { level_id: @level.to_param, election_id: @election.to_param, ballot_id: @ballot.to_param }
      expect( response.status ).to eq 403
    end
    context 'with authority' do
      before(:each) do
        set_logged_in_admin
        get :new, params: { level_id: @level.to_param, election_id: @election.to_param, ballot_id: @ballot.to_param }
      end
      it 'assigns a CandidateForm as @candidate_form' do
        expect( assigns(:candidate_form) ).to be_a(Wayground::Democracy::CandidateForm)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Candidate/
      end
      it 'renders the ‘new’ template' do
        expect( response ).to render_template('candidates/new')
      end
      it 'assigns the site section' do
        expect( assigns(:site_section) ).to eq :candidates
      end
    end
  end

  describe 'POST create' do
    it 'fails if not logged in' do
      post(
        :create,
        params: {
          wayground_democracy_candidate_form: valid_attributes, level_id: @level.to_param,
          election_id: @election.to_param, ballot_id: @ballot.to_param
        }
      )
      expect( response.status ).to eq 403
    end
    it 'fails if not admin' do
      set_logged_in_user
      post(
        :create,
        params: {
          wayground_democracy_candidate_form: valid_attributes, level_id: @level.to_param,
          election_id: @election.to_param, ballot_id: @ballot.to_param
        }
      )
      expect( response.status ).to eq 403
    end

    describe 'with valid params' do
      before(:all) do
        @create_office = FactoryGirl.create(:office, level: @level, filename: 'office_for_create_candidate')
      end
      before(:each) do
        set_logged_in_admin
      end
      after(:each) do
        assigns(:candidate).delete if assigns(:candidate)
      end
      it 'creates a new Candidate' do
        expect {
          post(
            :create,
            params: {
              wayground_democracy_candidate_form: valid_attributes, person_id: @person.to_param,
              level_id: @level.to_param, election_id: @election.to_param,
              ballot_id: @ballot.to_param, office_id: @create_office.to_param
            }
          )
        }.to change(Candidate, :count).by(1)
      end
      context '...' do
        before(:each) do
          post(
            :create,
            params: {
              wayground_democracy_candidate_form: valid_attributes, person_id: @person.to_param,
              level_id: @level.to_param, election_id: @election.to_param,
              ballot_id: @ballot.to_param, office_id: @create_office.to_param
            }
          )
        end
        it 'creates a candidate on the CandidateForm' do
          created_candidate = assigns(:candidate_form).candidate
          expect( created_candidate ).to be_a(Candidate)
          expect( created_candidate ).to be_persisted
        end
        it 'notifies the user that the candidate was saved' do
          expect( request.flash[:notice] ).to eq 'The candidate has been saved.'
        end
        it 'redirects to the created candidate' do
          expect( response ).to redirect_to([@level, @election, @ballot, assigns(:candidate)])
        end
        it 'assigns the site section' do
          expect( assigns(:site_section) ).to eq :candidates
        end
      end
    end

    describe 'with invalid params' do
      before(:each) do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Candidate).to receive(:save).and_return(false)
        post(
          :create,
          params: {
            wayground_democracy_candidate_form: {}, level_id: @level.to_param,
            election_id: @election.to_param, ballot_id: @ballot.to_param
          }
        )
      end
      it 'assigns a CandidateForm as @candidate_form' do
        expect( assigns(:candidate_form) ).to be_a(Wayground::Democracy::CandidateForm)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Candidate/
      end
      it 're-renders the ‘new’ template' do
        expect( response ).to render_template('new')
      end
    end
  end

  describe 'GET edit' do
    it 'requires the user to have authority' do
      set_logged_in_user
      get(
        :edit,
        params: {
          id: candidate.to_param, level_id: @level.to_param,
          election_id: @election.to_param, ballot_id: @ballot.to_param
        }
      )
      expect( response.status ).to eq 403
    end

    context 'with authority' do
      before(:each) do
        set_logged_in_admin
        get(
          :edit,
          params: {
            id: candidate.to_param, level_id: @level.to_param,
            election_id: @election.to_param, ballot_id: @ballot.to_param
          }
        )
      end
      it 'assigns the requested candidate as @candidate' do
        expect( assigns(:candidate) ).to eq(candidate)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Candidate/
      end
      it 'renders the ‘edit’ template' do
        expect( response ).to render_template('candidates/edit')
      end
      it 'assigns the site section' do
        expect( assigns(:site_section) ).to eq :candidates
      end
    end
  end

  describe 'PUT update' do
    it 'requires the user to have authority' do
      set_logged_in_user
      put(
        :update,
        params: {
          id: candidate.to_param, wayground_democracy_candidate_form: {},
          level_id: @level.to_param, election_id: @election.to_param, ballot_id: @ballot.to_param
        }
      )
      expect( response.status ).to eq 403
    end

    describe 'with valid params' do
      it 'updates the requested candidate' do
        set_logged_in_admin
        expect_any_instance_of(Wayground::Democracy::CandidateForm).to receive(:save).and_return(true)
        put(
          :update,
          params: {
            id: candidate.to_param, wayground_democracy_candidate_form: { 'these' => 'params' },
            level_id: @level.to_param, election_id: @election.to_param, ballot_id: @ballot.to_param
          }
        )
      end
      context 'with attributes' do
        before(:each) do
          set_logged_in_admin
          put(
            :update,
            params: {
              id: candidate.to_param, wayground_democracy_candidate_form: valid_attributes,
              level_id: @level.to_param, election_id: @election.to_param, ballot_id: @ballot.to_param
            }
          )
        end
        it 'assigns the requested candidate as @candidate' do
          expect( assigns(:candidate) ).to eq(candidate)
        end
        it 'notifies the user that the candidate was saved' do
          expect( request.flash[:notice] ).to eq 'The candidate has been saved.'
        end
        it 'redirects to the candidate' do
          expect( response ).to redirect_to([@level, @election, @ballot, assigns(:candidate)])
        end
        it 'assigns the site section' do
          expect( assigns(:site_section) ).to eq :candidates
        end
      end
    end

    describe 'with invalid params' do
      before(:each) do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Candidate).to receive(:save).and_return(false)
        put(
          :update,
          params: {
            id: candidate.to_param, wayground_democracy_candidate_form: {},
            level_id: @level.to_param, election_id: @election.to_param, ballot_id: @ballot.to_param
          }
        )
      end
      it 'assigns the candidate as @candidate' do
        expect( assigns(:candidate) ).to eq(candidate)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Candidate/
      end
      it 're-renders the ‘edit’ template' do
        expect( response ).to render_template('edit')
      end
    end
  end

  describe 'GET delete' do
    it 'requires the user to have authority' do
      set_logged_in_user
      get(
        :delete,
        params: {
          id: candidate.to_param, level_id: @level.to_param,
          election_id: @election.to_param, ballot_id: @ballot.to_param
        }
      )
      expect( response.status ).to eq 403
    end
    context 'with authority' do
      before(:each) do
        set_logged_in_admin
        get(
          :delete,
          params: {
            id: candidate.to_param, level_id: @level.to_param,
            election_id: @election.to_param, ballot_id: @ballot.to_param
          }
        )
      end
      it 'shows a form for confirming deletion of an candidate' do
        expect( assigns(:candidate) ).to eq candidate
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Candidate/
      end
      it 'renders the ‘delete’ template' do
        expect( response ).to render_template('candidates/delete')
      end
      it 'assigns the site section' do
        expect( assigns(:site_section) ).to eq :candidates
      end
    end
  end

  describe 'DELETE destroy' do
    it 'requires the user to have authority' do
      set_logged_in_user
      delete(
        :destroy,
        params: {
          id: candidate.to_param, level_id: @level.to_param,
          election_id: @election.to_param, ballot_id: @ballot.to_param
        }
      )
      expect( response.status ).to eq 403
    end
    context 'with authority' do
      let(:candidate) { $candidate = FactoryGirl.create(:candidate, ballot: @ballot) }
      before(:each) do
        set_logged_in_admin
      end
      it 'destroys the requested candidate' do
        candidate
        expect {
          delete(
            :destroy,
            params: {
              id: candidate.to_param, level_id: @level.to_param,
              election_id: @election.to_param, ballot_id: @ballot.to_param
            }
          )
        }.to change(Candidate, :count).by(-1)
      end
      it 'redirects to the candidates list' do
        delete(
          :destroy,
          params: {
            id: candidate.to_param, level_id: @level.to_param,
            election_id: @election.to_param, ballot_id: @ballot.to_param
          }
        )
        expect( response ).to redirect_to(level_election_ballot_candidates_url(@level, @election, @ballot))
      end
    end
  end

end
