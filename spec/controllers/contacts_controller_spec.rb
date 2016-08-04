require 'rails_helper'

describe ContactsController, type: :controller do

  before(:all) do
    Contact.destroy_all
    Person.destroy_all
    Authority.destroy_all
    User.destroy_all
    Candidate.destroy_all
    Ballot.destroy_all
    Office.destroy_all
    Election.destroy_all
    Level.destroy_all
    # first user is automatically an admin
    @user_admin = FactoryGirl.create(:user, name: 'Admin User')
    @user_normal = FactoryGirl.create(:user, name: 'Normal User')
    # create some extraneous Contacts to make sure we’re not loading :all when we want a subset
    FactoryGirl.create_list(:contact, 2)
    @person = FactoryGirl.create(:person)
    # create an extra Contact on the person
    FactoryGirl.create(:contact, item: @person, position: 1)
    @level = FactoryGirl.create(:level)
    @election = FactoryGirl.create(:election, level: @level)
    @office = FactoryGirl.create(:office, level: @level)
    @ballot = FactoryGirl.create(:ballot, election: @election, office: @office)
    @candidate = FactoryGirl.create(:candidate, ballot: @ballot, party: nil)
  end

  def set_logged_in_admin
    allow(controller).to receive(:current_user).and_return(@user_admin)
  end
  def set_logged_in_user
    allow(controller).to receive(:current_user).and_return(@user_normal)
  end

  def valid_attributes
    { name: 'Valid Name', url: 'http://valid.url/' }
  end

  let(:person) { @person }
  let(:level) { @level }
  let(:election) { @election }
  let(:ballot) { @ballot }
  let(:candidate) { @candidate }
  let(:contact) { $contact = FactoryGirl.create(:contact, item: person, position: 99) }
  let(:private_contact) do
    $contact = FactoryGirl.create(:contact, item: person, position: 99, is_public: false)
  end

  describe 'GET “index”' do
    it 'returns http success' do
      get 'index', person_id: person.to_param
      expect( response ).to be_success
    end
    it 'assigns the item’s contacts as @contacts' do
      contacts = [person.contacts.first, contact]
      get :index, person_id: person.to_param
      expect( assigns(:contacts) ).to eq(contacts)
    end
    context 'with an person_id param' do
      it 'assigns the person as @item' do
        get :index, person_id: person.to_param
        expect( assigns(:item) ).to eq(person)
      end
    end
    context 'with a candidate_id param' do
      it 'assigns the candidate as @item' do
        get :index,
          candidate_id: candidate.to_param, ballot_id: ballot.to_param,
          election_id: election.to_param, level_id: level.to_param
        expect( assigns(:item) ).to eq(candidate)
      end
    end
  end

  describe 'GET “show”' do
    it 'returns http success' do
      get 'show', person_id: person.to_param, id: contact.id
      expect( response ).to be_success
    end
    it 'assigns the requested contact as @contact' do
      get 'show', person_id: person.to_param, id: contact.id
      expect( assigns(:contact) ).to eq(contact)
    end
    it 'returns http missing if invalid id' do
      get 'show', person_id: person.to_param, id: (contact.id + 1000)
      expect( response.status ).to eq 404
    end
    it 'returns http missing if invalid item id' do
      get 'show', person_id: (person.id + 1000), id: contact.id
      expect( response.status ).to eq 404
    end
    context 'with a private contact' do
      it 'returns http unauthorized if the user does not have access' do
        set_logged_in_user
        get 'show', person_id: person.to_param, id: private_contact.id
        expect( response.status ).to eq 403
      end
      it 'assigns the requested private contact as @contact if the user has access' do
        set_logged_in_admin
        get 'show', person_id: person.to_param, id: private_contact.id
        expect( assigns(:contact) ).to eq(private_contact)
      end
    end
  end

  describe 'GET “new”' do
    it 'fails if not sufficent authority' do
      set_logged_in_user
      get :new, person_id: person.to_param
      expect( response.status ).to eq 403
    end

    it 'returns http success' do
      set_logged_in_admin
      get 'new', person_id: person.to_param
      expect( response ).to be_success
    end
    it 'assigns a new Contact as @contact' do
      set_logged_in_admin
      get :new, person_id: person.to_param
      expect( assigns(:contact) ).to be_a_new(Contact)
    end
    it 'associates the new Contact with the person' do
      set_logged_in_admin
      get :new, person_id: person.to_param
      expect( assigns(:contact).item ).to eq person
    end
  end

  describe 'POST “create”' do
    it 'fails if not sufficient authority' do
      set_logged_in_user
      post :create, person_id: person.to_param, contact: valid_attributes
      expect( response.status ).to eq 403
    end

    context 'with valid params' do
      it 'creates a new Event' do
        set_logged_in_admin
        expect {
          post :create, person_id: person.to_param, contact: valid_attributes
        }.to change(person.contacts, :count).by(1)
      end
      it 'assigns a newly created Contact as @contact' do
        set_logged_in_admin
        post :create, person_id: person.to_param, contact: valid_attributes
        expect( assigns(:contact) ).to be_a(Contact)
        expect( assigns(:contact) ).to be_persisted
      end
      it 'associates the new Contact with the person' do
        set_logged_in_admin
        post :create, person_id: person.to_param, contact: valid_attributes
        expect( assigns(:contact).item ).to eq person
      end
      it 'redirects to the created Contact' do
        set_logged_in_admin
        post :create, person_id: person.to_param, contact: valid_attributes
        expect( response ).to redirect_to([person, person.contacts.last])
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved Contact as @contact' do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Contact).to receive(:save).and_return(false)
        post :create, person_id: person.to_param, contact: {}
        expect( assigns(:contact) ).to be_a_new(Contact)
      end
      it 'associates the new Contact with the person' do
        set_logged_in_admin
        allow_any_instance_of(Contact).to receive(:save).and_return(false)
        post :create, person_id: person.to_param, contact: {}
        expect( assigns(:contact).item ).to eq person
      end
      it 're-renders the “new” template' do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Contact).to receive(:save).and_return(false)
        post :create, person_id: person.to_param, contact: {}
        expect( response ).to render_template('new')
      end
    end
  end

  describe 'GET “edit”' do
    it 'requires the user to have authority' do
      set_logged_in_user
      get :edit, person_id: person.to_param, id: contact.id
      expect( response.status ).to eq 403
    end

    it 'assigns the requested contact as @contact' do
      set_logged_in_admin
      get :edit, person_id: person.to_param, id: contact.id
      expect( assigns(:contact) ).to eq(contact)
    end
  end

  describe 'PUT “update”' do
    it 'requires the user to have authority' do
      set_logged_in_user
      patch :update, person_id: person.to_param, id: contact.id, contact: { 'these' => 'params' }
      expect( response.status ).to eq 403
    end

    describe 'with valid params' do
      it 'updates the requested contact' do
        set_logged_in_admin
        # This specifies that the Contact receives the :update message
        # with whatever params are submitted in the request.
        expect_any_instance_of(Contact).to receive(:update).with('name' => 'valid params')
        patch :update, person_id: person.to_param, id: contact.id, contact: { 'name' => 'valid params' }
      end

      it 'assigns the requested contact as @contact' do
        set_logged_in_admin
        patch :update, person_id: person.to_param, id: contact.id, contact: valid_attributes
        expect( assigns(:contact) ).to eq(contact)
      end

      it 'redirects to the contact' do
        set_logged_in_admin
        patch :update, person_id: person.to_param, id: contact.id, contact: valid_attributes
        expect( response ).to redirect_to([person, contact])
      end
    end

    describe 'with invalid params' do
      it 'assigns the contact as @contact' do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Contact).to receive(:save).and_return(false)
        patch :update, person_id: person.to_param, id: contact.id, contact: { url: 'invalid url' }
        expect( assigns(:contact) ).to eq(contact)
      end

      it 're-renders the “edit” template' do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Contact).to receive(:save).and_return(false)
        patch :update, person_id: person.to_param, id: contact.id, contact: { url: 'invalid url' }
        expect( response ).to render_template('edit')
      end
    end
  end

  describe 'GET “delete”' do
    it 'requires the user to have authority' do
      set_logged_in_user
      get :delete, person_id: person.to_param, id: contact.id
      expect( response.status ).to eq 403
    end

    it 'shows a form for confirming deletion of an contact' do
      set_logged_in_admin
      get :delete, person_id: person.to_param, id: contact.id
      expect( assigns(:contact) ).to eq contact
    end
  end

  describe 'DELETE “destroy”' do
    it 'requires the user to have authority' do
      set_logged_in_user
      delete :destroy, person_id: person.to_param, id: contact.id
      expect( response.status ).to eq 403
    end

    it 'destroys the requested contact' do
      set_logged_in_admin
      delete_this = FactoryGirl.create(:contact, item: person)
      expect {
        delete :destroy, person_id: person.to_param, id: delete_this.id
      }.to change(person.contacts, :count).by(-1)
    end

    it 'redirects to the containing item' do
      set_logged_in_admin
      delete_this = FactoryGirl.create(:contact, item: person)
      delete :destroy, person_id: person.to_param, id: delete_this.id
      expect( response ).to redirect_to(person)
    end
  end

end
