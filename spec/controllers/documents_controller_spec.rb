require 'rails_helper'

describe DocumentsController, type: :controller do

  before(:all) do
    Authority.delete_all
    User.delete_all
    Document.delete_all
    @admin = FactoryGirl.create(:user)
    # create 11 public documents and 1 private
    @document = FactoryGirl.create(:document, user: @admin)
    FactoryGirl.create_list(:document, 10, :user => @document.user)
    # create a document that should not be viewable without authority
    @private_doc = FactoryGirl.create(:document, :is_authority_controlled => true)
  end

  def set_logged_in_admin(stubs={})
    allow(controller).to receive(:current_user).and_return(@admin)
  end

  def mock_document(stubs={})
    @mock_document ||= mock_model(Document, stubs).as_null_object
  end

  # This should return the minimal set of attributes required to create a valid
  # Document. As you add validations to Document, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    file = Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/files/sample.txt", 'text/plain')
    {file: file}
  end

  describe "GET download" do
    it "returns the requested document" do
      document = FactoryGirl.create(:document)
      get :download, {:id => document.id.to_s, :filename => document.filename}
      expect(response.status).to eq 200
      expect(response['Content-Type']).to eq(document.content_type)
      expect(response.body).to eq(document.data)
    end
    it "reports missing when requested document doesn’t exist" do
      get :download, {:id => '0', :filename => 'none'}
      expect(response.status).to eq 404
      expect(response).to render_template('missing')
    end
    it "doesn’t care what filename is specified" do
      document = FactoryGirl.create(:document, :filename => 'test')
      get :download, {:id => document.id.to_s, :filename => 'madeupname.pdf'}
      expect(response.status).to eq 200
      expect(response['Content-Type']).to eq(document.content_type)
      expect(response.body).to eq(document.data)
    end

    context "authority controlled document" do
      before(:all) do
        @document = FactoryGirl.create(:document, :is_authority_controlled => true)
      end
      it "requires the user to have authority when access controlled" do
        get :download, {:id => @document.id.to_s, :filename => @document.filename}
        expect(response.status).to eq 403
      end
      it "allows an authorized user to retrieve an access controlled document" do
        set_logged_in_admin
        get :download, {:id => @document.id.to_s, :filename => @document.filename}
        expect(response.status).to eq 200
      end
    end
  end

  describe "GET index" do
    it "assigns all viewable documents as @documents" do
      get :index, {:max => '100'}
      expect(assigns(:documents)).not_to include @private_doc
    end
    it "assigns the total number of viewable documents as @documents_total" do
      get :index, {:max => '100'}
      expect(assigns(:source_total)).to be 11
    end
    it "assigns the documents based on the pagination parameters" do
      get :index, {:page => '2', :max => '10'}
      expect(assigns(:documents).size).to be 1
    end
  end

  describe "GET show" do
    it "requires the user to have authority" do
      document = FactoryGirl.create(:document, :is_authority_controlled => true)
      get :show, :id => document.id.to_s
      expect(response.status).to eq 403
    end

    it "assigns the requested document as @document" do
      document = FactoryGirl.create(:document)
      get :show, :id => document.id.to_s
      expect(assigns(:document)).to eq(document)
    end
  end

  describe "GET new" do
    it "requires the user to have authority" do
      get :new
      expect(response.status).to eq 403
    end

    it "assigns a new document as @document" do
      set_logged_in_admin
      get :new
      expect(assigns(:document)).to be_a_new(Document)
    end
  end

  describe "POST create" do
    context "as anonymous user" do
      it "requires the user to have authority" do
        post :create, :document => valid_attributes
        expect(response.status).to eq 403
      end
    end

    context "as an authorized user" do
      before(:each) do
        set_logged_in_admin
      end

      context "with valid params" do
        after(:each) do
          Document.last.delete
        end
        it "creates a new Document" do
          expect {
            post :create, :document => valid_attributes
          }.to change(Document, :count).by(1)
        end

        it "assigns a newly created document as @document" do
          post :create, :document => valid_attributes
          expect(assigns(:document)).to be_a(Document)
          expect(assigns(:document)).to be_persisted
        end

        it "redirects to the created document" do
          post :create, :document => valid_attributes
          expect(response).to redirect_to(Document.last)
        end
      end

      context "with invalid params" do
        before(:each) do
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(Document).to receive(:save).and_return(false)
          post :create, :document => {}
        end

        it "assigns a newly created but unsaved document as @document" do
          expect(assigns(:document)).to be_a_new(Document)
        end

        it "re-renders the 'new' template" do
          expect(response).to render_template("new")
        end
      end
    end
  end

  describe "GET edit" do
    it "requires the user to have authority" do
      get :delete, :id => @document.id.to_s
      expect(response.status).to eq 403
    end

    it "assigns the requested document as @document" do
      set_logged_in_admin
      get :edit, :id => @document.id.to_s
      expect(assigns(:document)).to eq(@document)
    end
  end

  describe "PUT update" do
    context "as anonymous user" do
      it "requires the user to have authority" do
        patch :update, id: @document.id.to_s
        expect(response.status).to eq 403
      end
    end

    context "as an authorized user" do
      before(:each) do
        set_logged_in_admin
      end

      context "with valid params" do
        it "updates the requested document" do
          # Assuming there are no other documents in the database, this
          # specifies that the document receives the :update message
          # with whatever params are submitted in the request.
          expect_any_instance_of(Document).to receive(:update).with('custom_filename' => 'valid_params')
          patch :update, id: @document.id, document: { 'custom_filename' => 'valid_params' }
        end

        it "assigns the requested document as @document" do
          document = FactoryGirl.create(:document)
          patch :update, id: document.id, document: valid_attributes
          expect(assigns(:document)).to eq(document)
          document.delete
        end

        it "redirects to the document" do
          document = FactoryGirl.create(:document)
          patch :update, id: document.id, document: valid_attributes
          expect(response).to redirect_to(document)
          document.delete
        end
      end

      context "with invalid params" do
        before(:each) do
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(Document).to receive(:save).and_return(false)
          patch :update, id: @document.id.to_s, document: {}
        end

        it "assigns the document as @document" do
          expect(assigns(:document)).to eq(@document)
        end

        it "re-renders the 'edit' template" do
          expect(response).to render_template("edit")
        end
      end
    end
  end

  describe "GET delete" do
    it "requires the user to have authority" do
      get :delete, :id => @private_doc.id.to_s
      expect(response.status).to eq 403
    end

    it "shows a form for confirming deletion of a document" do
      set_logged_in_admin
      allow(Document).to receive(:find).with("37") { mock_document }
      get :delete, :id => "37"
      expect(assigns(:document)).to be(mock_document)
    end
  end

  describe "DELETE destroy" do
    context "as anonymous user" do
      it "requires the user to have authority" do
        delete :destroy, :id => @document.id.to_s
        expect(response.status).to eq 403
      end
    end

    context "as an authorized user" do
      before(:each) do
        set_logged_in_admin
        @delete_document = FactoryGirl.create(:document)
      end
      it "destroys the requested document" do
        expect {
          delete :destroy, :id => @delete_document.id.to_s
        }.to change(Document, :count).by(-1)
      end

      it "redirects to the documents list" do
        delete :destroy, :id => @delete_document.id.to_s
        expect(response).to redirect_to(documents_url)
      end
    end
  end

end
