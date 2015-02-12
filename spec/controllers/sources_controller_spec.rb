require 'spec_helper'
require 'sources_controller'
require 'authority'
require 'event'
require 'source'
require 'sourced_item'
require 'user'
require 'import/ical_importer'

describe SourcesController, type: :controller do
  before(:all) do
    Source.destroy_all
    Authority.delete_all
    User.destroy_all
    # first user is automatically an admin
    @user_admin = FactoryGirl.create(:user, name: 'Admin User')
    @user_normal = FactoryGirl.create(:user, name: 'Normal User')
  end

  def set_logged_in_admin
    controller.stub(:current_user).and_return(@user_admin)
  end
  def set_logged_in_user
    controller.stub(:current_user).and_return(@user_normal)
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
      response.status.should eq 403
    end

    it "assigns all sources as @sources" do
      source = FactoryGirl.create(:source)
      set_logged_in_admin
      get :index
      assigns(:sources).should eq([source])
    end
  end

  describe "GET show" do
    it "fails if not logged in" do
      source = FactoryGirl.create(:source)
      get :show, id: source.id
      response.status.should eq 403
    end

    it "assigns the requested source as @source" do
      source = FactoryGirl.create(:source)
      set_logged_in_admin
      get :show, id: source.id
      assigns(:source).should eq(source)
    end
  end

  describe "GET new" do
    it "fails if not logged in" do
      get :new
      response.status.should eq 403
    end

    it "assigns a new source as @source" do
      set_logged_in_admin
      get :new
      assigns(:source).should be_a_new(Source)
    end
  end

  describe "POST create" do
    it "fails if not logged in" do
      post :create, source: valid_attributes
      response.status.should eq 403
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
        assigns(:source).should be_a(Source)
        assigns(:source).should be_persisted
      end

      it "redirects to the created source" do
        set_logged_in_admin
        post :create, source: valid_attributes
        response.should redirect_to(Source.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved source as @source" do
        # Trigger the behavior that occurs when invalid params are submitted
        Source.any_instance.stub(:save).and_return(false)
        set_logged_in_admin
        post :create, source: {}
        assigns(:source).should be_a_new(Source)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Source.any_instance.stub(:save).and_return(false)
        set_logged_in_admin
        post :create, source: {}
        response.should render_template("new")
      end
    end
  end

  describe "GET edit" do
    it "requires the user to have authority" do
      source = FactoryGirl.create(:source)
      set_logged_in_user
      get :edit, id: source.id
      response.status.should eq 403
    end

    it "assigns the requested source as @source" do
      source = FactoryGirl.create(:source)
      set_logged_in_admin
      get :edit, id: source.id
      assigns(:source).should eq(source)
    end
  end

  describe "PUT update" do
    it "requires the user to have authority" do
      source = FactoryGirl.create(:source)
      set_logged_in_user
      patch :update, id: source.id, source: { 'these' => 'params' }
      response.status.should eq 403
    end

    describe "with valid params" do
      it "updates the requested source" do
        source = FactoryGirl.create(:source)
        # Assuming there are no other sources in the database, this
        # specifies that the Source created on the previous line
        # receives the :update message with whatever params are
        # submitted in the request.
        Source.any_instance.should_receive(:update).with('these' => 'params')
        set_logged_in_admin
        patch :update, id: source.id, source: { 'these' => 'params' }
      end

      it "assigns the requested source as @source" do
        source = FactoryGirl.create(:source)
        set_logged_in_admin
        patch :update, id: source.id, source: valid_attributes
        assigns(:source).should eq(source)
      end

      it "redirects to the source" do
        source = FactoryGirl.create(:source)
        set_logged_in_admin
        patch :update, id: source.id, source: valid_attributes
        response.should redirect_to(source)
      end
    end

    describe "with invalid params" do
      it "assigns the source as @source" do
        source = FactoryGirl.create(:source)
        # Trigger the behavior that occurs when invalid params are submitted
        Source.any_instance.stub(:save).and_return(false)
        set_logged_in_admin
        patch :update, id: source.id, source: {}
        assigns(:source).should eq(source)
      end

      it "re-renders the 'edit' template" do
        source = FactoryGirl.create(:source)
        # Trigger the behavior that occurs when invalid params are submitted
        Source.any_instance.stub(:save).and_return(false)
        set_logged_in_admin
        patch :update, id: source.id, source: {}
        response.should render_template("edit")
      end
    end
  end

  describe "GET delete" do
    it "requires the user to have authority" do
      source = FactoryGirl.create(:source)
      set_logged_in_user
      get :delete, id: source.id
      response.status.should eq 403
    end

    it "shows a form for confirming deletion of an source" do
      Source.stub(:find).with("37") { mock_source }
      set_logged_in_admin
      get :delete, id: "37"
      assigns(:source).should be(mock_source)
    end
  end

  describe "DELETE destroy" do
    it "requires the user to have authority" do
      source = FactoryGirl.create(:source)
      set_logged_in_user
      delete :destroy, id: source.id
      response.status.should eq 403
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
      response.should redirect_to(sources_url)
    end
  end

  describe "GET processor" do
    let(:source) { $source = FactoryGirl.create(:source) }

    it "requires the user to have authority" do
      set_logged_in_user
      get :processor, id: source.id
      response.status.should eq 403
    end

    it "assigns the requested source as @source" do
      set_logged_in_admin
      get :processor, id: source.id
      assigns(:source).should eq(source)
    end
  end

  describe "POST runprocessor" do
    let(:source) do
      $source = FactoryGirl.create(:source,
        processor: 'iCalendar', url: "#{Rails.root}/spec/fixtures/files/sample.ics"
      )
    end

    it "requires the user to have authority" do
      set_logged_in_user
      post :runprocessor, id: source.id
      response.status.should eq 403
    end

    describe "with valid params" do
      it "processess the requested source" do
        SourcedItem.delete_all
        Event.delete_all
        # Assuming there are no other sources in the database, this
        # specifies that the Source created on the previous line
        # receives the :process message with the admin User as an arg.
        Source.any_instance.should_receive(:run_processor).
          with(@user_admin, false).and_return(Wayground::Import::IcalImporter.new)
        set_logged_in_admin
        post :runprocessor, id: source.id
      end
    end
  end

end
