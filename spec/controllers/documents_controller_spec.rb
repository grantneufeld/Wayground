# encoding: utf-8

require 'spec_helper'

describe DocumentsController do

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
      response['Content-Type'].should eq(document.content_type)
      response.body.should eq(document.data)
    end
    it "allows an authorized user to retrieve an access controlled document" do
    end
    it "blocks unauthorized users from retrieving an access controlled document" do
    end
  end

  describe "GET index" do
    it "assigns all documents as @documents" do
      document = Factory.create(:document)
      get :index
      assigns(:documents).should eq([document])
    end
  end

  describe "GET show" do
    it "assigns the requested document as @document" do
      document = Factory.create(:document)
      get :show, :id => document.id.to_s
      assigns(:document).should eq(document)
    end
  end

  describe "GET new" do
    it "assigns a new document as @document" do
      get :new
      assigns(:document).should be_a_new(Document)
    end
  end

  describe "POST create" do
    describe "with valid params" do
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

    describe "with invalid params" do
      it "assigns a newly created but unsaved document as @document" do
        # Trigger the behavior that occurs when invalid params are submitted
        Document.any_instance.stub(:save).and_return(false)
        post :create, :document => {}
        assigns(:document).should be_a_new(Document)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Document.any_instance.stub(:save).and_return(false)
        post :create, :document => {}
        response.should render_template("new")
      end
    end
  end

  describe "GET edit" do
    it "assigns the requested document as @document" do
      document = Factory.create(:document)
      get :edit, :id => document.id.to_s
      assigns(:document).should eq(document)
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested document" do
        document = Factory.create(:document)
        # Assuming there are no other documents in the database, this
        # specifies that the Document created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Document.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => document.id, :document => {'these' => 'params'}
      end

      it "assigns the requested document as @document" do
        document = Factory.create(:document)
        put :update, :id => document.id, :document => valid_attributes
        assigns(:document).should eq(document)
      end

      it "redirects to the document" do
        document = Factory.create(:document)
        put :update, :id => document.id, :document => valid_attributes
        response.should redirect_to(document)
      end
    end

    describe "with invalid params" do
      it "assigns the document as @document" do
        document = Factory.create(:document)
        # Trigger the behavior that occurs when invalid params are submitted
        Document.any_instance.stub(:save).and_return(false)
        put :update, :id => document.id.to_s, :document => {}
        assigns(:document).should eq(document)
      end

      it "re-renders the 'edit' template" do
        document = Factory.create(:document)
        # Trigger the behavior that occurs when invalid params are submitted
        Document.any_instance.stub(:save).and_return(false)
        put :update, :id => document.id.to_s, :document => {}
        response.should render_template("edit")
      end
    end
  end

  describe "GET delete" do
  end

  describe "DELETE destroy" do
    it "destroys the requested document" do
      document = Factory.create(:document)
      expect {
        delete :destroy, :id => document.id.to_s
      }.to change(Document, :count).by(-1)
    end

    it "redirects to the documents list" do
      document = Factory.create(:document)
      delete :destroy, :id => document.id.to_s
      response.should redirect_to(documents_url)
    end
  end

end
