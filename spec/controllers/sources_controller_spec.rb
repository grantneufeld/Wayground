require 'rails_helper'
require 'sources_controller'
require 'authority'
require 'event'
require 'source'
require 'sourced_item'
require 'user'
require 'import/ical_importer'

describe SourcesController, type: :controller do
  before(:all) do
    Source.delete_all
    Authority.delete_all
    User.delete_all
    # first user is automatically an admin
    @user_admin = FactoryGirl.create(:user, name: 'Admin User')
    @user_normal = FactoryGirl.create(:user, name: 'Normal User')
  end

  def set_logged_in_admin
    allow(controller).to receive(:current_user).and_return(@user_admin)
  end
  def set_logged_in_user
    allow(controller).to receive(:current_user).and_return(@user_normal)
  end

  def mock_source(stubs={})
    @mock_source ||= mock_model(Source, stubs).as_null_object
  end

  # This should return the minimal set of attributes required to create a valid
  # Source. As you add validations to Source, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { processor: 'iCalendar', url: 'test://test.tld/valid.ics' }
  end

  describe "GET index" do
    it "fails if not logged in" do
      get :index
      expect(response.status).to eq 403
    end

    it "assigns all sources as @sources" do
      source = FactoryGirl.create(:source)
      set_logged_in_admin
      get :index
      expect(assigns(:sources)).to eq([source])
    end
  end

  describe "GET show" do
    it "fails if not logged in" do
      source = FactoryGirl.create(:source)
      get :show, id: source.id
      expect(response.status).to eq 403
    end

    it "assigns the requested source as @source" do
      source = FactoryGirl.create(:source)
      set_logged_in_admin
      get :show, id: source.id
      expect(assigns(:source)).to eq(source)
    end
  end

  describe "GET new" do
    it "fails if not logged in" do
      get :new
      expect(response.status).to eq 403
    end

    it "assigns a new source as @source" do
      set_logged_in_admin
      get :new
      expect(assigns(:source)).to be_a_new(Source)
    end
  end

  describe "POST create" do
    it "fails if not logged in" do
      post :create, source: valid_attributes
      expect(response.status).to eq 403
    end

    describe "with valid params" do
      it "creates a new Source" do
        set_logged_in_admin
        expect {
          post :create, source: valid_attributes
        }.to change(Source, :count).by(1)
      end

      it "assigns a newly created source as @source" do
        set_logged_in_admin
        post :create, source: valid_attributes
        expect(assigns(:source)).to be_a(Source)
        expect(assigns(:source)).to be_persisted
      end

      it "redirects to the created source" do
        set_logged_in_admin
        post :create, source: valid_attributes
        expect(response).to redirect_to(Source.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved source as @source" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Source).to receive(:save).and_return(false)
        set_logged_in_admin
        post :create, source: {}
        expect(assigns(:source)).to be_a_new(Source)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Source).to receive(:save).and_return(false)
        set_logged_in_admin
        post :create, source: {}
        expect(response).to render_template("new")
      end
    end
  end

  describe "GET edit" do
    it "requires the user to have authority" do
      source = FactoryGirl.create(:source)
      set_logged_in_user
      get :edit, id: source.id
      expect(response.status).to eq 403
    end

    it "assigns the requested source as @source" do
      source = FactoryGirl.create(:source)
      set_logged_in_admin
      get :edit, id: source.id
      expect(assigns(:source)).to eq(source)
    end
  end

  describe "PUT update" do
    it "requires the user to have authority" do
      source = FactoryGirl.create(:source)
      set_logged_in_user
      patch :update, id: source.id, source: { 'these' => 'params' }
      expect(response.status).to eq 403
    end

    describe "with valid params" do
      it "updates the requested source" do
        source = FactoryGirl.create(:source)
        # Assuming there are no other sources in the database, this
        # specifies that the Source created on the previous line
        # receives the :update message with whatever params are
        # submitted in the request.
        expect_any_instance_of(Source).to receive(:update).with('title' => 'valid_params')
        set_logged_in_admin
        patch :update, id: source.id, source: { 'title' => 'valid_params' }
      end

      it "assigns the requested source as @source" do
        source = FactoryGirl.create(:source)
        set_logged_in_admin
        patch :update, id: source.id, source: valid_attributes
        expect(assigns(:source)).to eq(source)
      end

      it "redirects to the source" do
        source = FactoryGirl.create(:source)
        set_logged_in_admin
        patch :update, id: source.id, source: valid_attributes
        expect(response).to redirect_to(source)
      end
    end

    describe "with invalid params" do
      it "assigns the source as @source" do
        source = FactoryGirl.create(:source)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Source).to receive(:save).and_return(false)
        set_logged_in_admin
        patch :update, id: source.id, source: {}
        expect(assigns(:source)).to eq(source)
      end

      it "re-renders the 'edit' template" do
        source = FactoryGirl.create(:source)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Source).to receive(:save).and_return(false)
        set_logged_in_admin
        patch :update, id: source.id, source: {}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "GET delete" do
    it "requires the user to have authority" do
      source = FactoryGirl.create(:source)
      set_logged_in_user
      get :delete, id: source.id
      expect(response.status).to eq 403
    end

    it "shows a form for confirming deletion of an source" do
      allow(Source).to receive(:find).with("37") { mock_source }
      set_logged_in_admin
      get :delete, id: "37"
      expect(assigns(:source)).to be(mock_source)
    end
  end

  describe "DELETE destroy" do
    it "requires the user to have authority" do
      source = FactoryGirl.create(:source)
      set_logged_in_user
      delete :destroy, id: source.id
      expect(response.status).to eq 403
    end

    it "destroys the requested source" do
      source = FactoryGirl.create(:source)
      set_logged_in_admin
      expect {
        delete :destroy, id: source.id
      }.to change(Source, :count).by(-1)
    end

    it "redirects to the sources list" do
      source = FactoryGirl.create(:source)
      set_logged_in_admin
      delete :destroy, id: source.id
      expect(response).to redirect_to(sources_url)
    end
  end

  describe "GET processor" do
    let(:source) { $source = FactoryGirl.create(:source) }

    it "requires the user to have authority" do
      set_logged_in_user
      get :processor, id: source.id
      expect(response.status).to eq 403
    end

    it "assigns the requested source as @source" do
      set_logged_in_admin
      get :processor, id: source.id
      expect(assigns(:source)).to eq(source)
    end
  end

  describe "POST runprocessor" do
    let(:source) { $source = Source.new(title: 'Test Source') }
    before(:each) do
      allow(Source).to receive(:find).with('123').and_return(source)
    end

    it "requires the user to have authority" do
      allow(source).to receive(:has_authority_for_user_to?).and_return(false)
      set_logged_in_user
      post :runprocessor, id: '123'
      expect(response.status).to eq 403
    end

    context 'with valid params' do
      let(:importer) { $importer = Wayground::Import::IcalImporter.new }
      before(:each) do
        set_logged_in_admin
      end
      it 'assigns source' do
        allow(source).to receive(:run_processor).with(@user_admin, false).and_return(importer)
        post :runprocessor, id: '123'
        expect(assigns(:source)).to eq source
      end
      it 'assigns the page metadata title' do
        allow(source).to receive(:run_processor).with(@user_admin, false).and_return(importer)
        post :runprocessor, id: '123'
        expect(assigns(:page_metadata).title).to match /^Processed Source:.*#{source.name}/
      end
      it 'processess the requested source' do
        expect(source).to receive(:run_processor).with(@user_admin, false).and_return(importer)
        post :runprocessor, id: '123'
      end
      it 'sets a flash notice' do
        new_event = Event.new
        new_event.sourced_items << SourcedItem.new
        updated_event = Event.new
        updated_event.sourced_items << SourcedItem.new
        skipped_event = Event.new
        skipped_event.sourced_items << SourcedItem.new
        allow(importer).to receive(:new_events).and_return([new_event])
        allow(importer).to receive(:updated_events).and_return([updated_event])
        allow(importer).to receive(:skipped_ievents).and_return([skipped_event])
        allow(source).to receive(:run_processor).with(@user_admin, false).and_return(importer)
        post :runprocessor, id: '123'
        expect(flash[:notice]).to match /Processing complete/
        expect(flash[:notice]).to match /1 items were created/
        expect(flash[:notice]).to match /1 items were updated/
        expect(flash[:notice]).to match /1 items were skipped/
      end
      it 'assigns sourced_items' do
        new_event = Event.new
        new_event.sourced_items << SourcedItem.new
        updated_event = Event.new
        updated_event.sourced_items << SourcedItem.new
        allow(importer).to receive(:new_events).and_return([new_event])
        allow(importer).to receive(:updated_events).and_return([updated_event])
        allow(source).to receive(:run_processor).with(@user_admin, false).and_return(importer)
        post :runprocessor, id: '123'
        expect(assigns(:sourced_items)).to eq(
          [new_event.sourced_items.first, updated_event.sourced_items.first]
        )
      end
      it 'renders the show template' do
        allow(source).to receive(:run_processor).with(@user_admin, false).and_return(importer)
        post :runprocessor, id: '123'
        expect(response).to render_template('show')
      end
    end
  end

end
