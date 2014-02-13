# encoding: utf-8
require 'spec_helper'

describe ExternalLinksController do

  before(:all) do
    ExternalLink.destroy_all
    Event.destroy_all
    Authority.destroy_all
    User.destroy_all
    # first user is automatically an admin
    @user_admin = FactoryGirl.create(:user, :name => 'Admin User')
    @user_normal = FactoryGirl.create(:user, :name => 'Normal User')
    # create some extraneous ExternalLinks to make sure we’re not loading :all when we want a subset
    FactoryGirl.create_list(:external_link, 2)
    @event = FactoryGirl.create(:event)
    # create an extra ExternalLink on the event
    FactoryGirl.create(:external_link, item: @event, position: 1)
    Person.destroy_all
    Candidate.destroy_all
    Ballot.destroy_all
    Office.destroy_all
    Election.destroy_all
    Level.destroy_all
    @level = FactoryGirl.create(:level)
    @election = FactoryGirl.create(:election, level: @level)
    @office = FactoryGirl.create(:office, level: @level)
    @ballot = FactoryGirl.create(:ballot, election: @election, office: @office)
    @candidate = FactoryGirl.create(:candidate, ballot: @ballot, party: nil)
  end

  def set_logged_in_admin
    controller.stub!(:current_user).and_return(@user_admin)
  end
  def set_logged_in_user
    controller.stub!(:current_user).and_return(@user_normal)
  end

  # This should return the minimal set of attributes required to create a valid
  # ExternalLink. As you add validations to ExternalLink, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {:title => 'Valid Title', :url => 'http://valid.url/'}
  end

  let(:event) { @event }
  let(:level) { @level }
  let(:election) { @election }
  let(:office) { @office }
  let(:ballot) { @ballot }
  let(:candidate) { @candidate }
  let(:external_link) { $external_link = FactoryGirl.create(:external_link, :item => event, :position => 99)}

  describe "GET 'index'" do
    it "returns http success" do
      get 'index', :event_id => event.id
      response.should be_success
    end
    it "assigns the item’s external_links as @external_links" do
      external_links = [event.external_links.first, external_link]
      get :index, :event_id => event.id
      assigns(:external_links).should eq(external_links)
    end
    context 'with an event_id param' do
      it 'assigns the event as @item' do
        get :index, event_id: event.to_param
        assigns(:item).should eq(event)
      end
    end
    context 'with a candidate_id param' do
      it "assigns the candidate as @item" do
        get :index,
          candidate_id: candidate.to_param, ballot_id: ballot.to_param,
          election_id: election.to_param, level_id: level.to_param
        assigns(:item).should eq(candidate)
      end
    end
    context 'with a ballot_id param' do
      it 'assigns the ballot as @item' do
        get :index, ballot_id: ballot.to_param, election_id: election.to_param, level_id: level.to_param
        expect(assigns(:item)).to eq ballot
      end
    end
    context 'with an office_id param' do
      it 'assigns the office as @item' do
        get :index, office_id: office.to_param, level_id: level.to_param
        expect(assigns(:item)).to eq office
      end
    end
  end

  describe "GET 'show'" do
    it "returns http success" do
      get 'show', :event_id => event.id, :id => external_link.id
      response.should be_success
    end
    it "assigns the requested external_link as @external_link" do
      get 'show', :event_id => event.id, :id => external_link.id
      assigns(:external_link).should eq(external_link)
    end
    it "returns http missing if invalid id" do
      get 'show', :event_id => event.id, :id => (external_link.id + 10)
      response.status.should eq 404
    end
    it "returns http missing if invalid item id" do
      get 'show', :event_id => (event.id + 10), :id => external_link.id
      response.status.should eq 404
    end
  end

  describe "GET 'new'" do
    it "fails if not sufficent authority" do
      set_logged_in_user
      get :new, :event_id => event.id
      response.status.should eq 403
    end

    it "returns http success" do
      set_logged_in_admin
      get 'new', :event_id => event.id
      response.should be_success
    end
    it "assigns a new ExternalLink as @external_link" do
      set_logged_in_admin
      get :new, :event_id => event.id
      assigns(:external_link).should be_a_new(ExternalLink)
    end
    it 'associates the new ExternalLink with the event' do
      set_logged_in_admin
      get :new, event_id: event.id
      expect( assigns(:external_link).item ).to eq event
    end
  end

  describe "POST 'create'" do
    it "fails if not sufficient authority" do
      set_logged_in_user
      post :create, :event_id => event.id, :external_link => valid_attributes
      response.status.should eq 403
    end

    context 'with valid params' do
      it "creates a new Event" do
        set_logged_in_admin
        expect {
          post :create, :event_id => event.id, :external_link => valid_attributes
        }.to change(event.external_links, :count).by(1)
      end
      it "assigns a newly created ExternalLink as @external_link" do
        set_logged_in_admin
        post :create, :event_id => event.id, :external_link => valid_attributes
        assigns(:external_link).should be_a(ExternalLink)
        assigns(:external_link).should be_persisted
      end
      it 'associates the new ExternalLink with the event' do
        set_logged_in_admin
        post :create, event_id: event.id, external_link: valid_attributes
        expect( assigns(:external_link).item ).to eq event
      end
      it "redirects to the created ExternalLink" do
        set_logged_in_admin
        post :create, :event_id => event.id, :external_link => valid_attributes
        response.should redirect_to([event, event.external_links.last])
      end
    end

    context 'with invalid params' do
      it "assigns a newly created but unsaved ExternalLink as @external_link" do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        ExternalLink.any_instance.stub(:save).and_return(false)
        post :create, :event_id => event.id, :external_link => {}
        assigns(:external_link).should be_a_new(ExternalLink)
      end
      it 'associates the new ExternalLink with the event' do
        set_logged_in_admin
        ExternalLink.any_instance.stub(:save).and_return(false)
        post :create, event_id: event.id, external_link: {}
        expect( assigns(:external_link).item ).to eq event
      end
      it "re-renders the 'new' template" do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        ExternalLink.any_instance.stub(:save).and_return(false)
        post :create, :event_id => event.id, :external_link => {}
        response.should render_template("new")
      end
    end
  end

  describe "GET 'edit'" do
    it "requires the user to have authority" do
      set_logged_in_user
      get :edit, :event_id => event.id, :id => external_link.id
      response.status.should eq 403
    end

    it "assigns the requested external_link as @external_link" do
      set_logged_in_admin
      get :edit, :event_id => event.id, :id => external_link.id
      assigns(:external_link).should eq(external_link)
    end
  end

  describe "PUT 'update'" do
    it "requires the user to have authority" do
      set_logged_in_user
      patch :update, event_id: event.id, id: external_link.id, external_link: { 'these' => 'params' }
      response.status.should eq 403
    end

    describe "with valid params" do
      it "updates the requested external_link" do
        set_logged_in_admin
        # This specifies that the ExternalLink receives the :update message
        # with whatever params are submitted in the request.
        ExternalLink.any_instance.should_receive(:update).with('these' => 'params')
        patch :update, event_id: event.id, id: external_link.id, external_link: { 'these' => 'params' }
      end

      it "assigns the requested external_link as @external_link" do
        set_logged_in_admin
        patch :update, event_id: event.id, id: external_link.id, external_link: valid_attributes
        assigns(:external_link).should eq(external_link)
      end

      it "redirects to the external_link" do
        set_logged_in_admin
        patch :update, event_id: event.id, id: external_link.id, external_link: valid_attributes
        response.should redirect_to([event, external_link])
      end
    end

    describe "with invalid params" do
      it "assigns the external_link as @external_link" do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        ExternalLink.any_instance.stub(:save).and_return(false)
        patch :update, event_id: event.id, id: external_link.id, external_link: { url: 'invalid url' }
        assigns(:external_link).should eq(external_link)
      end

      it "re-renders the 'edit' template" do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        ExternalLink.any_instance.stub(:save).and_return(false)
        patch :update, event_id: event.id, id: external_link.id, external_link: { url: 'invalid url' }
        response.should render_template("edit")
      end
    end
  end

  describe "GET 'delete'" do
    it "requires the user to have authority" do
      set_logged_in_user
      get :delete, :event_id => event.id, :id => external_link.id
      response.status.should eq 403
    end

    it "shows a form for confirming deletion of an external_link" do
      set_logged_in_admin
      get :delete, :event_id => event.id, :id => external_link.id
      assigns(:external_link).should eq external_link
    end
  end

  describe "DELETE 'destroy'" do
    it "requires the user to have authority" do
      set_logged_in_user
      delete :destroy, :event_id => event.id, :id => external_link.id
      response.status.should eq 403
    end

    it "destroys the requested external_link" do
      set_logged_in_admin
      delete_this = FactoryGirl.create(:external_link, :item => event)
      expect {
        delete :destroy, :event_id => event.id, :id => delete_this.id
      }.to change(event.external_links, :count).by(-1)
    end

    it "redirects to the containing item" do
      set_logged_in_admin
      delete_this = FactoryGirl.create(:external_link, :item => event)
      delete :destroy, :event_id => event.id, :id => delete_this.id
      response.should redirect_to(event)
    end
  end

end
