require 'rails_helper'
require 'people_controller'

describe PeopleController, type: :controller do

  before(:all) do
    Person.delete_all
    @person = FactoryGirl.create(:person)
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
    $valid_attributes = { filename: "valid_#{@sequence_counter}", fullname: "Valid #{@sequence_counter}" }
  end
  let(:person) { $person = @person }

  describe 'GET index' do
    before(:each) do
      allow(Person).to receive_message_chain(:order, :all) { [person] }
      get :index
    end
    it 'assigns all people as @people' do
      expect( assigns(:people) ).to eq([person])
    end
    it 'assigns a title to the page_metadata' do
      expect( assigns(:page_metadata).title ).to match /People/
    end
    it 'renders the ‘index’ template' do
      expect( response ).to render_template('people/index')
    end
    it 'assigns the site section' do
      expect( assigns(:site_section) ).to eq :people
    end
  end

  describe 'GET show' do
    before(:each) do
      get :show, id: person.filename
    end
    it 'assigns the requested person as @person' do
      expect( assigns(:person) ).to eq(person)
    end
    it 'assigns a title to the page_metadata' do
      expect( assigns(:page_metadata).title ).to match /Person/
    end
    it 'renders the ‘show’ template' do
      expect( response ).to render_template('people/show')
    end
    it 'assigns the site section' do
      expect( assigns(:site_section) ).to eq :people
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
      it 'assigns a new person as @person' do
        expect( assigns(:person) ).to be_a_new(Person)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Person/
      end
      it 'renders the ‘new’ template' do
        expect( response ).to render_template('people/new')
      end
      it 'assigns the site section' do
        expect( assigns(:site_section) ).to eq :people
      end
    end
  end

  describe 'POST create' do
    it 'fails if not logged in' do
      post :create, person: valid_attributes
      expect( response.status ).to eq 403
    end
    it 'fails if not admin' do
      set_logged_in_user
      post :create, person: valid_attributes
      expect( response.status ).to eq 403
    end

    describe 'with valid params' do
      before(:each) do
        set_logged_in_admin
      end
      it 'creates a new Person' do
        expect {
          post :create, person: valid_attributes
        }.to change(Person, :count).by(1)
      end
      context '...' do
        before(:each) do
          post :create, person: valid_attributes
        end
        it 'assigns a newly created person as @person' do
          expect( assigns(:person) ).to be_a(Person)
          expect( assigns(:person) ).to be_persisted
        end
        it 'notifies the user that the person was saved' do
          expect( request.flash[:notice] ).to eq 'The person has been saved.'
        end
        it 'redirects to the created person' do
          expect( response ).to redirect_to(assigns(:person))
        end
        it 'assigns the site section' do
          expect( assigns(:site_section) ).to eq :people
        end
      end
    end

    describe 'with invalid params' do
      before(:each) do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Person).to receive(:save).and_return(false)
        post :create, person: {}
      end
      it 'assigns a newly created but unsaved person as @person' do
        expect( assigns(:person) ).to be_a_new(Person)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Person/
      end
      it 're-renders the ‘new’ template' do
        expect( response ).to render_template('new')
      end
    end
  end

  describe 'GET edit' do
    it 'requires the user to have authority' do
      set_logged_in_user
      get :edit, id: person.filename
      expect( response.status ).to eq 403
    end

    context 'with authority' do
      before(:each) do
        set_logged_in_admin
        get :edit, id: person.filename
      end
      it 'assigns the requested person as @person' do
        expect( assigns(:person) ).to eq(person)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Person/
      end
      it 'renders the ‘edit’ template' do
        expect( response ).to render_template('people/edit')
      end
      it 'assigns the site section' do
        expect( assigns(:site_section) ).to eq :people
      end
    end
  end

  describe 'PUT update' do
    it 'requires the user to have authority' do
      set_logged_in_user
      patch :update, id: person.filename, person: {}
      expect( response.status ).to eq 403
    end

    describe 'with valid params' do
      it 'updates the requested person' do
        set_logged_in_admin
        expected_params = ActionController::Parameters.new('fullname' => 'valid params').permit!
        expect_any_instance_of(Person).to receive(:update).with(expected_params).and_return(true)
        patch :update, id: person.filename, person: { 'fullname' => 'valid params' }
      end
      context 'with attributes' do
        before(:each) do
          set_logged_in_admin
          patch :update, id: person.filename, person: valid_attributes
        end
        it 'assigns the requested person as @person' do
          expect( assigns(:person) ).to eq(person)
        end
        it 'notifies the user that the person was saved' do
          expect( request.flash[:notice] ).to eq 'The person has been saved.'
        end
        it 'redirects to the person' do
          expect( response ).to redirect_to(assigns(:person))
        end
        it 'assigns the site section' do
          expect( assigns(:site_section) ).to eq :people
        end
      end
    end

    describe 'with invalid params' do
      before(:each) do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Person).to receive(:save).and_return(false)
        patch :update, id: person.filename, person: {}
      end
      it 'assigns the person as @person' do
        expect( assigns(:person) ).to eq(person)
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Person/
      end
      it 're-renders the ‘edit’ template' do
        expect( response ).to render_template('edit')
      end
    end
  end

  describe 'GET delete' do
    it 'requires the user to have authority' do
      set_logged_in_user
      get :delete, id: person.filename
      expect( response.status ).to eq 403
    end
    context 'with authority' do
      before(:each) do
        set_logged_in_admin
        get :delete, id: person.filename
      end
      it 'shows a form for confirming deletion of an person' do
        expect( assigns(:person) ).to eq person
      end
      it 'assigns a title to the page_metadata' do
        expect( assigns(:page_metadata).title ).to match /Person/
      end
      it 'renders the ‘delete’ template' do
        expect( response ).to render_template('people/delete')
      end
      it 'assigns the site section' do
        expect( assigns(:site_section) ).to eq :people
      end
    end
  end

  describe 'DELETE destroy' do
    it 'requires the user to have authority' do
      set_logged_in_user
      delete :destroy, id: person.filename
      expect( response.status ).to eq 403
    end
    context 'with authority' do
      let(:person) { $person = FactoryGirl.create(:person) }
      before(:each) do
        set_logged_in_admin
      end
      it 'destroys the requested person' do
        person
        expect {
          delete :destroy, id: person.filename
        }.to change(Person, :count).by(-1)
      end
      it 'redirects to the people list' do
        delete :destroy, id: person.filename
        expect( response ).to redirect_to(people_url)
      end
    end
  end

end
