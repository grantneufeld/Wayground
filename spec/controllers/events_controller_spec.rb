require 'spec_helper'

describe EventsController do

  before do
    Authority.delete_all
    User.destroy_all
  end

  def mock_admin(stubs={})
    @mock_admin ||= mock_model(User, {:id => 1, :email => 'test+mockadmin@wayground.ca', :name => 'The Admin', :has_authority_for_area => mock_admin_authority}.merge(stubs))
  end
  def mock_user(stubs={})
    @mock_user ||= mock_model(User, {:id => 2, :email => 'test+mockuser@wayground.ca', :name => 'A. User', :has_authority_for_area => nil}.merge(stubs))
  end

  def set_logged_in_admin(stubs={})
    controller.stub!(:current_user).and_return(mock_admin(stubs))
  end
  def set_logged_in_user(stubs={})
    controller.stub!(:current_user).and_return(mock_user(stubs))
  end

  def mock_authority(stubs={})
    @mock_authority ||= mock_model(Authority, {:area => 'global', :user => @mock_user}.merge(stubs)).as_null_object
  end
  def mock_admin_authority(stubs={})
    @mock_admin_authority ||= mock_model(Authority, {:area => 'global', :is_owner => true, :user => @mock_admin}.merge(stubs)).as_null_object
  end
  def reset_mock_admin_authority(stubs={})
    @mock_admin_authority = nil
    mock_admin_authority(stubs)
  end

  def mock_event(stubs={})
    @mock_event ||= mock_model(Event, stubs).as_null_object
  end


  # This should return the minimal set of attributes required to create a valid
  # Event. As you add validations to Event, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {:start_at => '2012-01-02 03:04:05', :title => 'event controller title'}
  end

  describe "GET index" do
    it "assigns all events as @events" do
      event = Event.create! valid_attributes
      get :index
      assigns(:events).should eq([event])
    end
  end

  describe "GET show" do
    it "assigns the requested event as @event" do
      event = Event.create! valid_attributes
      get :show, :id => event.id
      assigns(:event).should eq(event)
    end
  end

  describe "GET new" do
    it "fails if not logged in" do
      get :new
      response.status.should eq 403
    end

    it "assigns a new event as @event" do
      set_logged_in_user
      get :new
      assigns(:event).should be_a_new(Event)
    end
  end

  describe "POST create" do
    it "fails if not logged in" do
      post :create, :event => valid_attributes
      response.status.should eq 403
    end

    describe "with valid params" do
      it "creates a new Event" do
        set_logged_in_user
        expect {
          post :create, :event => valid_attributes
        }.to change(Event, :count).by(1)
      end

      it "assigns a newly created event as @event" do
        set_logged_in_user
        post :create, :event => valid_attributes
        assigns(:event).should be_a(Event)
        assigns(:event).should be_persisted
      end

      it "redirects to the created event" do
        set_logged_in_user
        post :create, :event => valid_attributes
        response.should redirect_to(Event.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved event as @event" do
        set_logged_in_user
        # Trigger the behavior that occurs when invalid params are submitted
        Event.any_instance.stub(:save).and_return(false)
        post :create, :event => {}
        assigns(:event).should be_a_new(Event)
      end

      it "re-renders the 'new' template" do
        set_logged_in_user
        # Trigger the behavior that occurs when invalid params are submitted
        Event.any_instance.stub(:save).and_return(false)
        post :create, :event => {}
        response.should render_template("new")
      end
    end

    describe "as admin" do
      it "saves and posts the event" do
        set_logged_in_admin
        post :create, :event => valid_attributes
        request.flash[:notice].should eq 'The event has been saved.'
        assigns(:event).is_approved.should be_true
      end
    end
    describe "as non-admin user" do
      it "saves and submits the event for review" do
        set_logged_in_user
        post :create, :event => valid_attributes
        request.flash[:notice].should eq 'The event has been submitted.'
        assigns(:event).is_approved.should be_false
      end
    end
  end

  describe "GET edit" do
    it "requires the user to have authority" do
      set_logged_in_user
      event = Event.create!(valid_attributes)
      get :edit, :id => event.id
      response.status.should eq 403
    end

    it "assigns the requested event as @event" do
      set_logged_in_admin
      event = Event.create! valid_attributes
      get :edit, :id => event.id
      assigns(:event).should eq(event)
    end
  end

  describe "PUT update" do
    it "requires the user to have authority" do
      set_logged_in_user
      event = Event.create!(valid_attributes)
      put :update, :id => event.id, :event => {'these' => 'params'}
      response.status.should eq 403
    end

    describe "with valid params" do
      it "updates the requested event" do
        set_logged_in_admin
        event = Event.create! valid_attributes
        # Assuming there are no other events in the database, this
        # specifies that the Event created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Event.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => event.id, :event => {'these' => 'params'}
      end

      it "assigns the requested event as @event" do
        set_logged_in_admin
        event = Event.create! valid_attributes
        put :update, :id => event.id, :event => valid_attributes
        assigns(:event).should eq(event)
      end

      it "redirects to the event" do
        set_logged_in_admin
        event = Event.create! valid_attributes
        put :update, :id => event.id, :event => valid_attributes
        response.should redirect_to(event)
      end
    end

    describe "with invalid params" do
      it "assigns the event as @event" do
        set_logged_in_admin
        event = Event.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Event.any_instance.stub(:save).and_return(false)
        put :update, :id => event.id, :event => {}
        assigns(:event).should eq(event)
      end

      it "re-renders the 'edit' template" do
        set_logged_in_admin
        event = Event.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Event.any_instance.stub(:save).and_return(false)
        put :update, :id => event.id, :event => {}
        response.should render_template("edit")
      end
    end
  end

  describe "GET delete" do
    it "requires the user to have authority" do
      set_logged_in_user
      event = Event.create!(valid_attributes)
      get :delete, :id => event.id
      response.status.should eq 403
    end

    it "shows a form for confirming deletion of an event" do
      set_logged_in_admin
      Event.stub(:find).with("37") { mock_event }
      get :delete, :id => "37"
      assigns(:event).should be(mock_event)
    end
  end

  describe "DELETE destroy" do
    it "requires the user to have authority" do
      set_logged_in_user
      event = Event.create!(valid_attributes)
      delete :destroy, :id => event.id
      response.status.should eq 403
    end

    it "destroys the requested event" do
      set_logged_in_admin
      event = Event.create! valid_attributes
      expect {
        delete :destroy, :id => event.id
      }.to change(Event, :count).by(-1)
    end

    it "redirects to the events list" do
      set_logged_in_admin
      event = Event.create! valid_attributes
      delete :destroy, :id => event.id
      response.should redirect_to(events_url)
    end
  end

end
