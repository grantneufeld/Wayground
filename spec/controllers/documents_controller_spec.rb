# encoding: utf-8

require 'spec_helper'

describe DocumentsController do

  def set_logged_in_admin(stubs={})
    controller.stub!(:current_user).and_return(mock_admin(stubs))
  end
  def mock_admin(stubs={})
    @mock_admin ||= mock_model(User, {:id => 1, :email => 'test+mockadmin@wayground.ca', :name => 'The Admin', :has_authority_for_area => mock_admin_authority, :has_authority_for_item => mock_admin_authority}.merge(stubs))
  end
  def mock_admin_authority(stubs={})
    @mock_admin_authority ||= mock_model(Authority, {:area => 'Content', :is_owner => true, :user => @mock_admin}.merge(stubs)).as_null_object
  end

  def mock_document(stubs={})
    @mock_document ||= mock_model(Document, stubs).as_null_object
  end

  # This should return the minimal set of attributes required to create a valid
  # Document. As you add validations to Document, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {:file => File.new("#{Rails.root}/spec/fixtures/files/sample.txt")}
  end

  describe "GET download" do
    it "returns the requested document" do
      document = Factory.create(:document)
      get :download, {:id => document.id.to_s, :filename => document.filename}
      response.status.should eq 200
      response['Content-Type'].should eq(document.content_type)
      response.body.should eq(document.data)
    end
    it "reports missing when requested document doesn’t exist" do
      get :download, {:id => '0', :filename => 'none'}
      response.status.should eq 404
      response.should render_template('missing')
    end
    it "doesn’t care what filename is specified" do
      document = Factory.create(:document, :filename => 'test')
      get :download, {:id => document.id.to_s, :filename => 'madeupname.pdf'}
      response.status.should eq 200
      response['Content-Type'].should eq(document.content_type)
      response.body.should eq(document.data)
    end

    context "authority controlled document" do
      before(:all) do
        @document = Factory.create(:document, :is_authority_controlled => true)
      end
      it "requires the user to have authority when access controlled" do
        get :download, {:id => @document.id.to_s, :filename => @document.filename}
        response.status.should eq 403
      end
      it "allows an authorized user to retrieve an access controlled document" do
        set_logged_in_admin
        get :download, {:id => @document.id.to_s, :filename => @document.filename}
        response.status.should eq 200
      end
    end
  end

  describe "GET index" do
    it "assigns all viewable documents as @documents" do
      Document.delete_all
      Authority.delete_all
      document = Factory.create(:document)
      # create a document that should nto be viewable without authority
      Factory.create(:document, :is_authority_controlled => true)
      get :index
      assigns(:documents).should eq([document])
    end
  end

  describe "GET show" do
    it "requires the user to have authority" do
      document = Factory.create(:document, :is_authority_controlled => true)
      get :show, :id => document.id.to_s
      response.status.should eq 403
    end

    it "assigns the requested document as @document" do
      document = Factory.create(:document)
      get :show, :id => document.id.to_s
      assigns(:document).should eq(document)
    end
  end

  describe "GET new" do
    it "requires the user to have authority" do
      get :new
      response.status.should eq 403
    end

    it "assigns a new document as @document" do
      set_logged_in_admin
      get :new
      assigns(:document).should be_a_new(Document)
    end
  end

  describe "POST create" do
    context "as anonymous user" do
      it "requires the user to have authority" do
        post :create, :document => valid_attributes
        response.status.should eq 403
      end
    end

    context "as an authorized user" do
      before(:each) do
        set_logged_in_admin
      end

      context "with valid params" do
        it "creates a new Document" do
          expect {
            post :create, :document => valid_attributes
          }.to change(Document, :count).by(1)
        end

        it "assigns a newly created document as @document" do
          post :create, :document => valid_attributes
          assigns(:document).should be_a(Document)
          assigns(:document).should be_persisted
        end

        it "redirects to the created document" do
          post :create, :document => valid_attributes
          response.should redirect_to(Document.last)
        end
      end

      context "with invalid params" do
        before(:each) do
          # Trigger the behavior that occurs when invalid params are submitted
          Document.any_instance.stub(:save).and_return(false)
          post :create, :document => {}
        end

        it "assigns a newly created but unsaved document as @document" do
          assigns(:document).should be_a_new(Document)
        end

        it "re-renders the 'new' template" do
          response.should render_template("new")
        end
      end
    end
  end

  describe "GET edit" do
    before(:each) do
      @document = Factory.create(:document)
    end

    it "requires the user to have authority" do
      get :delete, :id => @document.id.to_s
      response.status.should eq 403
    end

    it "assigns the requested document as @document" do
      set_logged_in_admin
      get :edit, :id => @document.id.to_s
      assigns(:document).should eq(@document)
    end
  end

  describe "PUT update" do
    before(:each) do
      @document = Factory.create(:document)
    end

    context "as anonymous user" do
      it "requires the user to have authority" do
        put :update, :id => @document.id.to_s
        response.status.should eq 403
      end
    end

    context "as an authorized user" do
      before(:each) do
        set_logged_in_admin
      end

      context "with valid params" do
        it "updates the requested document" do
          # Assuming there are no other documents in the database, this
          # specifies that the document receives the :update_attributes message
          # with whatever params are submitted in the request.
          Document.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
          put :update, :id => @document.id, :document => {'these' => 'params'}
        end

        it "assigns the requested document as @document" do
          put :update, :id => @document.id, :document => valid_attributes
          assigns(:document).should eq(@document)
        end

        it "redirects to the document" do
          put :update, :id => @document.id, :document => valid_attributes
          response.should redirect_to(@document)
        end
      end

      context "with invalid params" do
        before(:each) do
          # Trigger the behavior that occurs when invalid params are submitted
          Document.any_instance.stub(:save).and_return(false)
          put :update, :id => @document.id.to_s, :document => {}
        end

        it "assigns the document as @document" do
          assigns(:document).should eq(@document)
        end

        it "re-renders the 'edit' template" do
          response.should render_template("edit")
        end
      end
    end
  end

  describe "GET delete" do
    it "requires the user to have authority" do
      test_document = Factory.create(:document)
      get :delete, :id => test_document.id.to_s
      response.status.should eq 403
    end

    it "shows a form for confirming deletion of a document" do
      set_logged_in_admin
      Document.stub(:find).with("37") { mock_document }
      get :delete, :id => "37"
      assigns(:document).should be(mock_document)
    end
  end

  describe "DELETE destroy" do
    context "as anonymous user" do
      it "requires the user to have authority" do
        test_document = Factory.create(:document)
        delete :destroy, :id => test_document.id.to_s
        response.status.should eq 403
      end
    end

    context "as an authorized user" do
      before(:each) do
        set_logged_in_admin
        @document = Factory.create(:document)
      end
      it "destroys the requested document" do
        expect {
          delete :destroy, :id => @document.id.to_s
        }.to change(Document, :count).by(-1)
      end

      it "redirects to the documents list" do
        delete :destroy, :id => @document.id.to_s
        response.should redirect_to(documents_url)
      end
    end
  end

end
