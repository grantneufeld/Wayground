require 'spec_helper'

describe EventsController do

  before do
    Event.destroy_all
    Authority.delete_all
    User.destroy_all
    # first user is automatically an admin
    @user_admin = FactoryGirl.create(:user, :name => 'Admin User')
    @user_normal = FactoryGirl.create(:user, :name => 'Normal User')
  end

  def set_logged_in_admin
    controller.stub!(:current_user).and_return(@user_admin)
  end
  def set_logged_in_user
    controller.stub!(:current_user).and_return(@user_normal)
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
      event = FactoryGirl.create(:event)
      get :index
      assigns(:events).should eq([event])
    end
  end

  describe "GET show" do
    it "assigns the requested event as @event" do
      event = FactoryGirl.create(:event)
      get :show, :id => event.id
      assigns(:event).should eq(event)
    end
    it "shows an alert when an event is_cancelled" do
      event = FactoryGirl.create(:event, :is_cancelled => true)
      get :show, :id => event.id
      request.flash[:alert].should match /[Cc]ancelled/
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
      event = FactoryGirl.create(:event)
      get :edit, :id => event.id
      response.status.should eq 403
    end

    it "assigns the requested event as @event" do
      set_logged_in_admin
      event = FactoryGirl.create(:event)
      get :edit, :id => event.id
      assigns(:event).should eq(event)
    end
  end

  describe "PUT update" do
    it "requires the user to have authority" do
      set_logged_in_user
      event = FactoryGirl.create(:event)
      put :update, :id => event.id, :event => {'these' => 'params'}
      response.status.should eq 403
    end

    describe "with valid params" do
      it "updates the requested event" do
        set_logged_in_admin
        event = FactoryGirl.create(:event)
        # Assuming there are no other events in the database, this
        # specifies that the Event created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Event.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => event.id, :event => {'these' => 'params'}
      end

      it "assigns the requested event as @event" do
        set_logged_in_admin
        event = FactoryGirl.create(:event)
        put :update, :id => event.id, :event => valid_attributes
        assigns(:event).should eq(event)
      end

      it "redirects to the event" do
        set_logged_in_admin
        event = FactoryGirl.create(:event)
        put :update, :id => event.id, :event => valid_attributes
        response.should redirect_to(event)
      end
    end

    describe "with invalid params" do
      it "assigns the event as @event" do
        set_logged_in_admin
        event = FactoryGirl.create(:event)
        # Trigger the behavior that occurs when invalid params are submitted
        Event.any_instance.stub(:save).and_return(false)
        put :update, :id => event.id, :event => {}
        assigns(:event).should eq(event)
      end

      it "re-renders the 'edit' template" do
        set_logged_in_admin
        event = FactoryGirl.create(:event)
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
      event = FactoryGirl.create(:event)
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
      event = FactoryGirl.create(:event)
      delete :destroy, :id => event.id
      response.status.should eq 403
    end

    it "destroys the requested event" do
      set_logged_in_admin
      event = FactoryGirl.create(:event)
      expect {
        delete :destroy, :id => event.id
      }.to change(Event, :count).by(-1)
    end

    it "redirects to the events list" do
      set_logged_in_admin
      event = FactoryGirl.create(:event)
      delete :destroy, :id => event.id
      response.should redirect_to(events_url)
    end
  end

end
