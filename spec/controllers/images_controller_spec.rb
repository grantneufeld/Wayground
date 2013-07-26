# encoding: utf-8
require 'spec_helper'
require 'images_controller'

describe ImagesController do

  before(:all) do
    Authority.delete_all
    @user_admin = User.first || FactoryGirl.create(:user, name: 'Admin User')
    @user_admin.make_admin!
    @user_normal = User.where('users.id != ?', @user_admin.id).first || FactoryGirl.create(:user, name: 'Normal User')
  end

  def set_logged_in_admin
    controller.stub!(:current_user).and_return(@user_admin)
  end
  def set_logged_in_user
    controller.stub!(:current_user).and_return(@user_normal)
  end

  let(:valid_attributes) { $valid_attributes = {} }
  let(:image) { $image = Image.first || FactoryGirl.create(:image) }

  describe "GET index" do
    it "assigns all images as @images" do
      image
      Image.stub(:all).and_return([image])
      get :index
      expect( assigns(:images) ).to eq([image])
    end
  end

  describe "GET show" do
    it "assigns the requested image as @image" do
      get :show, id: image.id
      expect( assigns(:image) ).to eq(image)
    end
  end

  describe "GET new" do
    it "fails if not logged in" do
      get :new
      expect( response.status ).to eq 403
    end
    it "fails if not admin" do
      set_logged_in_user
      get :new
      expect( response.status ).to eq 403
    end
    it "assigns a new image as @image" do
      set_logged_in_admin
      get :new
      expect( assigns(:image) ).to be_a_new(Image)
    end
  end

  describe "POST create" do
    it "fails if not logged in" do
      post :create, image: valid_attributes
      expect( response.status ).to eq 403
    end
    it "fails if not admin" do
      set_logged_in_user
      post :create, image: valid_attributes
      expect( response.status ).to eq 403
    end

    describe "with valid params" do
      it "creates a new Image" do
        set_logged_in_admin
        expect {
          post :create, image: valid_attributes
        }.to change(Image, :count).by(1)
      end
      it "assigns a newly created image as @image" do
        set_logged_in_admin
        post :create, image: valid_attributes
        expect( assigns(:image) ).to be_a(Image)
        expect( assigns(:image) ).to be_persisted
      end
      it "notifies the user that the image was saved" do
        set_logged_in_admin
        post :create, image: valid_attributes
        expect( request.flash[:notice] ).to eq 'The image has been saved.'
      end
      it "redirects to the created image" do
        #Image.delete_all
        set_logged_in_admin
        post :create, image: valid_attributes
        expect( response ).to redirect_to(Image.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved image as @image" do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        Image.any_instance.stub(:save).and_return(false)
        post :create, image: {}
        expect( assigns(:image) ).to be_a_new(Image)
      end
      it "re-renders the 'new' template" do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        Image.any_instance.stub(:save).and_return(false)
        post :create, image: {}
        expect( response ).to render_template("new")
      end
    end
  end

  describe "GET edit" do
    it "requires the user to have authority" do
      set_logged_in_user
      get :edit, id: image.id
      expect( response.status ).to eq 403
    end

    it "assigns the requested image as @image" do
      set_logged_in_admin
      get :edit, id: image.id
      expect( assigns(:image) ).to eq(image)
    end
  end

  describe "PUT update" do
    it "requires the user to have authority" do
      set_logged_in_user
      patch :update, id: image.id, image: {}
      expect( response.status ).to eq 403
    end

    describe "with valid params" do
      it "updates the requested image" do
        set_logged_in_admin
        Image.any_instance.should_receive(:update).with('these' => 'params')
        patch :update, id: image.id, image: { 'these' => 'params' }
      end
      it "assigns the requested image as @image" do
        set_logged_in_admin
        patch :update, id: image.id, image: valid_attributes
        expect( assigns(:image) ).to eq(image)
      end
      it "notifies the user that the image was saved" do
        set_logged_in_admin
        patch :update, id: image.id, image: valid_attributes
        expect( request.flash[:notice] ).to eq 'The image has been saved.'
      end
      it "redirects to the image" do
        set_logged_in_admin
        patch :update, id: image.id, image: valid_attributes
        expect( response ).to redirect_to(image)
      end
    end

    describe "with invalid params" do
      it "assigns the image as @image" do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        Image.any_instance.stub(:save).and_return(false)
        patch :update, id: image.id, image: {}
        expect( assigns(:image) ).to eq(image)
      end
      it "re-renders the 'edit' template" do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        Image.any_instance.stub(:save).and_return(false)
        patch :update, id: image.id, image: {}
        expect( response ).to render_template("edit")
      end
    end
  end

  describe "GET delete" do
    it "requires the user to have authority" do
      set_logged_in_user
      get :delete, id: image.id
      expect( response.status ).to eq 403
    end

    it "shows a form for confirming deletion of an image" do
      set_logged_in_admin
      get :delete, id: image.id
      expect( assigns(:image) ).to eq image
    end
  end

  describe "DELETE destroy" do
    it "requires the user to have authority" do
      set_logged_in_user
      delete :destroy, id: image.id
      expect( response.status ).to eq 403
    end
    it "destroys the requested image" do
      set_logged_in_admin
      image
      expect {
        delete :destroy, id: image.id
      }.to change(Image, :count).by(-1)
    end
    it "redirects to the images list" do
      set_logged_in_admin
      delete :destroy, id: image.id
      expect( response ).to redirect_to(images_url)
    end
  end

end
