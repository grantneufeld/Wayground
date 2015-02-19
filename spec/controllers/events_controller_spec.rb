require 'rails_helper'

describe EventsController, type: :controller do

  before(:all) do
    Event.delete_all
    Authority.delete_all
    User.delete_all
    # first user is automatically an admin
    @user_admin = FactoryGirl.create(:user, :name => 'Admin User')
    @user_normal = FactoryGirl.create(:user, :name => 'Normal User')
  end

  def set_logged_in_admin
    allow(controller).to receive(:current_user).and_return(@user_admin)
  end
  def set_logged_in_user
    allow(controller).to receive(:current_user).and_return(@user_normal)
  end

  def mock_event(stubs={})
    @mock_event ||= mock_model(Event, stubs).as_null_object
  end


  # This should return the minimal set of attributes required to create a valid
  # Event. As you add validations to Event, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { start_at: '2012-01-02 03:04:05', title: 'event controller title', tag_list: 'test, tag' }
  end

  describe "GET index" do
    before(:all) do
      Event.delete_all
      @event1 = FactoryGirl.create(:event, start_at: 1.day.from_now)
      @event2 = FactoryGirl.create(:event, start_at: 2.days.from_now, is_approved: false)
      @event3 = FactoryGirl.create(:event, start_at: 1.day.ago)
      @event4 = FactoryGirl.create(:event, start_at: 2.days.ago, is_approved: false)
    end
    it "assigns all approved upcoming events as @events" do
      get :index
      expect( assigns(:events).to_a ).to eq([@event1])
    end
    it "assigns all upcoming events, including unapproved, as @events for moderators" do
      set_logged_in_admin
      get :index
      expect(assigns(:events)).to eq([@event1, @event2])
    end
    it "should assign nil to @range the default “upcoming”" do
      get :index, {}
      expect(assigns(:range)).to eq 'upcoming'
    end
    context "past events" do
      it "assigns all approved past events as @events" do
        get :index, {r: 'past'}
        expect( assigns(:events).to_a ).to eq([@event3])
      end
      it "assigns all past events, including unapproved, as @events for moderators" do
        set_logged_in_admin
        get :index, {r: 'past'}
        expect(assigns(:events)).to eq([@event4, @event3])
      end
      it "should assign 'past' to @range" do
        get :index, {r: 'past'}
        expect( assigns(:range) ).to eq 'past'
      end
    end
    context "all events" do
      it "assigns all approved past events as @events" do
        get :index, {r: 'all'}
        expect( assigns(:events) ).to eq([@event3, @event1])
      end
      it "assigns all past events, including unapproved, as @events for moderators" do
        set_logged_in_admin
        get :index, {r: 'all'}
        expect(assigns(:events)).to eq([@event4, @event3, @event1, @event2])
      end
      it "should assign 'all' to @range" do
        get :index, {r: 'all'}
        expect( assigns(:range) ).to eq 'all'
      end
    end
    context 'tagged events' do
      before(:all) do
        @event2.tag_list = 'Test, Example'
        @event2.save!
        @event3.tag_list = 'Test, Example'
        @event3.save!
      end
      it 'should assign the events tagged with the given tag' do
        set_logged_in_admin
        get :index, {tag: 'test', r: 'all'}
        expect( assigns(:events) ).to eq [@event3, @event2]
      end
      it 'should assign the tag as @tag' do
        get :index, {tag: 'test', r: 'all'}
        expect( assigns(:tag) ).to eq 'test'
      end
    end
  end

  describe "GET show" do
    it "assigns the requested event as @event" do
      event = FactoryGirl.create(:event)
      get :show, :id => event.id
      expect(assigns(:event)).to eq(event)
    end
    it "shows an alert when an event is_cancelled" do
      event = FactoryGirl.create(:event, :is_cancelled => true)
      get :show, :id => event.id
      expect(request.flash[:alert]).to match /[Cc]ancelled/
    end
    it "shows an alert when an event is_tentative" do
      event = FactoryGirl.create(:event, is_tentative: true)
      get :show, :id => event.id
      expect(request.flash[:alert]).to match /[Tt]entative/
    end
    it "shows an alert when an event is not approved" do
      event = FactoryGirl.create(:event, :is_approved => false)
      get :show, :id => event.id
      expect(request.flash[:alert]).to match /not been approved/
    end
  end

  describe "GET new" do
    it "fails if not logged in" do
      get :new
      expect(response.status).to eq 401
    end

    it "assigns a new event as @event" do
      set_logged_in_user
      get :new
      expect(assigns(:event)).to be_a_new(Event)
    end
  end

  describe "POST create" do
    it "fails if not logged in" do
      post :create, :event => valid_attributes
      expect(response.status).to eq 401
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
        expect(assigns(:event)).to be_a(Event)
        expect(assigns(:event)).to be_persisted
      end

      it "redirects to the created event" do
        Event.delete_all
        set_logged_in_user
        post :create, :event => valid_attributes
        expect(response).to redirect_to(Event.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved event as @event" do
        set_logged_in_user
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Event).to receive(:save).and_return(false)
        post :create, :event => {}
        expect(assigns(:event)).to be_a_new(Event)
      end

      it "re-renders the 'new' template" do
        set_logged_in_user
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Event).to receive(:save).and_return(false)
        post :create, :event => {}
        expect(response).to render_template("new")
      end
    end

    describe "as admin" do
      it "saves and posts the event" do
        set_logged_in_admin
        post :create, :event => valid_attributes
        expect(request.flash[:notice]).to eq 'The event has been saved.'
        expect(assigns(:event).is_approved).to be_truthy
      end
    end
    describe "as non-admin user" do
      it "saves and submits the event for review" do
        set_logged_in_user
        post :create, :event => valid_attributes
        expect(request.flash[:notice]).to eq 'The event has been submitted.'
        expect(assigns(:event).is_approved).to be_falsey
      end
    end
  end

  describe "GET edit" do
    it "requires the user to have authority" do
      set_logged_in_user
      event = FactoryGirl.create(:event)
      get :edit, :id => event.id
      expect(response.status).to eq 403
    end

    it "assigns the requested event as @event" do
      set_logged_in_admin
      event = FactoryGirl.create(:event)
      get :edit, :id => event.id
      expect(assigns(:event)).to eq(event)
    end
  end

  describe "PUT update" do
    it "requires the user to have authority" do
      set_logged_in_user
      event = FactoryGirl.create(:event)
      patch :update, id: event.id, event: { 'these' => 'params' }
      expect(response.status).to eq 403
    end

    describe "with valid params" do
      it "updates the requested event" do
        set_logged_in_admin
        event = FactoryGirl.create(:event)
        # Assuming there are no other events in the database, this
        # specifies that the Event created on the previous line
        # receives the :update message with whatever params are
        # submitted in the request.
        expect_any_instance_of(Event).to receive(:update).with('these' => 'params')
        patch :update, id: event.id, event: { 'these' => 'params' }
      end

      it "assigns the requested event as @event" do
        set_logged_in_admin
        event = FactoryGirl.create(:event)
        patch :update, id: event.id, event: valid_attributes
        expect(assigns(:event)).to eq(event)
      end

      it "redirects to the event" do
        set_logged_in_admin
        event = FactoryGirl.create(:event)
        patch :update, id: event.id, event: valid_attributes
        expect(response).to redirect_to(event)
      end
    end

    describe "with invalid params" do
      it "assigns the event as @event" do
        set_logged_in_admin
        event = FactoryGirl.create(:event)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Event).to receive(:save).and_return(false)
        patch :update, id: event.id, event: {}
        expect(assigns(:event)).to eq(event)
      end

      it "re-renders the 'edit' template" do
        set_logged_in_admin
        event = FactoryGirl.create(:event)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Event).to receive(:save).and_return(false)
        patch :update, id: event.id, event: {}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "GET delete" do
    it "requires the user to have authority" do
      set_logged_in_user
      event = FactoryGirl.create(:event)
      get :delete, :id => event.id
      expect(response.status).to eq 403
    end

    it "shows a form for confirming deletion of an event" do
      set_logged_in_admin
      allow(Event).to receive(:find).with("37") { mock_event }
      get :delete, :id => "37"
      expect(assigns(:event)).to be(mock_event)
    end
  end

  describe "DELETE destroy" do
    it "requires the user to have authority" do
      set_logged_in_user
      event = FactoryGirl.create(:event)
      delete :destroy, :id => event.id
      expect(response.status).to eq 403
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
      expect(response).to redirect_to(events_url)
    end
  end

  describe "GET approve" do
    let(:event) { $event = FactoryGirl.create(:event, is_approved: false) }

    it "requires the user to have authority" do
      set_logged_in_user
      get :approve, :id => event.id
      expect(response.status).to eq 403
    end

    it "shows a form for confirming approval of an event" do
      set_logged_in_admin
      get :approve, :id => event.id
      expect(response).to render_template("approve")
    end
    it "should redirect to the event if already approved" do
      event.approve_by(@user_admin)
      set_logged_in_admin
      get :approve, :id => event.id
      expect(response).to redirect_to(event)
    end
  end

  describe "POST set_approved" do
    let(:event) { $event = FactoryGirl.create(:event, is_approved: false) }
    it "requires the user to have authority" do
      set_logged_in_user
      post :set_approved, :id => event.id
      expect(response.status).to eq 403
    end

    it "approves the requested event" do
      set_logged_in_admin
      post :set_approved, :id => event.id
      event.reload
      expect(event.is_approved?).to be_truthy
    end

    it "redirects to the event" do
      set_logged_in_admin
      post :set_approved, :id => event.id
      expect(response).to redirect_to(event)
    end

    it "posts an alert flash if fails to approve" do
      set_logged_in_admin
      allow_any_instance_of(Event).to receive(:approve_by).and_return(false)
      post :set_approved, :id => event.id
      expect(request.flash[:alert]).to match /[Ff]ailed/
    end
  end

  describe "GET merge" do
    let(:event) { $event = Event.first || FactoryGirl.create(:event) }

    it "requires the user to have authority" do
      set_logged_in_user
      get :merge, :id => event.id
      expect(response.status).to eq 403
    end

    it "shows a form for merging with another event" do
      set_logged_in_admin
      get :merge, :id => event.id
      expect(response).to render_template("merge")
    end

    it "shows a list of other events on the same day" do
      start = event.start_at
      events = []
      events << FactoryGirl.create(:event, start_at: start, title: 'Same Day and Time')
      events << FactoryGirl.create(:event,
        start_at: start - 2.days, end_at: start + 2.days, title: 'Multi-day Overlap'
      )
      events.sort_by! {|e| e.id }
      set_logged_in_admin
      get :merge, :id => event.id
      expect( assigns(:day_events).events.sort_by {|e| e.id} ).to eq events
    end
  end

  describe "POST perform_merge" do
    let(:time) { $time = 1.hour.from_now }
    let(:event) do
      $event = FactoryGirl.create(
        :event, user: @user_admin, editor: @user_admin, start_at: time, title: 'source'
      )
    end
    let(:merge_with) do
      $merge_with = FactoryGirl.create(
        :event, user: @user_admin, editor: @user_admin, start_at: time, title: 'destination'
      )
    end

    it "requires the user to have authority" do
      set_logged_in_user
      post :perform_merge, :id => event.id, :merge_with => merge_with.id
      expect(response.status).to eq 403
    end

    it "deletes the event" do
      set_logged_in_admin
      event_id = event.id
      post :perform_merge, :id => event_id, :merge_with => merge_with.id
      expect { Event.find(event_id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "assigns merge conflicts to @conflicts" do
      set_logged_in_admin
      post :perform_merge, :id => event.id, :merge_with => merge_with.id
      expect(assigns(:conflicts)[:title]).to eq 'source'
    end

    it "shows the merge results to the event" do
      set_logged_in_admin
      post :perform_merge, :id => event.id, :merge_with => merge_with.id
      expect(response).to render_template("perform_merge")
    end
  end

end
