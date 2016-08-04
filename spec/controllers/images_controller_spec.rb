require 'rails_helper'
require 'images_controller'

describe ImagesController, type: :controller do

  before(:all) do
    Authority.delete_all
    @user_admin = User.first || FactoryGirl.create(:user, name: 'Admin User')
    @user_admin.make_admin!
    @user_normal = (
      User.where('users.id != ?', @user_admin.id).first || FactoryGirl.create(:user, name: 'Normal User')
    )
  end

  def set_logged_in_admin
    allow(controller).to receive(:current_user).and_return(@user_admin)
  end
  def set_logged_in_user
    allow(controller).to receive(:current_user).and_return(@user_normal)
  end

  let(:valid_attributes) { $valid_attributes = {} }
  let(:image) { $image = Image.first || FactoryGirl.create(:image) }

  describe "GET index" do
    it "assigns all images as @images" do
      image
      allow(Image).to receive(:all).and_return([image])
      get :index
      expect( assigns(:images) ).to eq([image])
    end
  end

  describe "GET show" do
    it "assigns the requested image as @image" do
      get :show, params: { id: image.id }
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
      post :create, params: { image: valid_attributes }
      expect( response.status ).to eq 403
    end
    it "fails if not admin" do
      set_logged_in_user
      post :create, params: { image: valid_attributes }
      expect( response.status ).to eq 403
    end

    describe "with valid params" do
      it "creates a new Image" do
        set_logged_in_admin
        expect {
          post :create, params: { image: valid_attributes }
        }.to change(Image, :count).by(1)
      end
      it "assigns a newly created image as @image" do
        set_logged_in_admin
        post :create, params: { image: valid_attributes }
        expect( assigns(:image) ).to be_a(Image)
        expect( assigns(:image) ).to be_persisted
      end
      it "notifies the user that the image was saved" do
        set_logged_in_admin
        post :create, params: { image: valid_attributes }
        expect( request.flash[:notice] ).to eq 'The image has been saved.'
      end
      it "redirects to the created image" do
        #Image.delete_all
        set_logged_in_admin
        post :create, params: { image: valid_attributes }
        expect( response ).to redirect_to(Image.last)
      end
    end

    context 'with valid image_variants params' do
      it 'should create the image and variants' do
        set_logged_in_admin
        post(
          :create,
          params: {
            image: {
              'title' => 'with variants',
              'image_variants_attributes' => [
                { 'url' => 'http://test.tld/1', 'style' => 'original', 'format' => 'jpeg' },
                { 'url' => 'http://test.tld/2', 'style' => 'preview', 'format' => 'png' }
              ]
            }
          }
        )
        image = assigns(:image)
        expect(image).not_to be_a_new(Image)
        expect(image).to be_an(Image)
        expect(image.errors.messages).to be_empty
        expect(image.image_variants.count).to eq 2
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved image as @image" do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Image).to receive(:save).and_return(false)
        post :create, params: { image: {} }
        expect( assigns(:image) ).to be_a_new(Image)
      end
      it "re-renders the 'new' template" do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Image).to receive(:save).and_return(false)
        post :create, params: { image: {} }
        expect( response ).to render_template("new")
      end
      context 'with invalid image variant params' do
        it 'should return an error' do
          set_logged_in_admin
          post(
            :create,
            params: {
              image: { 'title' => 'with variants', 'image_variants_attributes' => ['invalid' => 'param'] }
            }
          )
          image = assigns(:image)
          expect(image).to be_a_new(Image)
          expect(image.errors[:image_variants]).not_to be_nil
        end
      end
    end
  end

  describe "GET edit" do
    it "requires the user to have authority" do
      set_logged_in_user
      get :edit, params: { id: image.id }
      expect( response.status ).to eq 403
    end

    it "assigns the requested image as @image" do
      set_logged_in_admin
      get :edit, params: { id: image.id }
      expect( assigns(:image) ).to eq(image)
    end
  end

  describe "PUT update" do
    it "requires the user to have authority" do
      set_logged_in_user
      patch :update, params: { id: image.id, image: {} }
      expect( response.status ).to eq 403
    end

    describe "with valid params" do
      it "updates the requested image" do
        set_logged_in_admin
        expected_params = ActionController::Parameters.new('title' => 'valid_params').permit!
        expect_any_instance_of(Image).to receive(:update).with(expected_params)
        patch :update, params: { id: image.id, image: { 'title' => 'valid_params' } }
      end
      it "assigns the requested image as @image" do
        set_logged_in_admin
        patch :update, params: { id: image.id, image: valid_attributes }
        expect( assigns(:image) ).to eq(image)
      end
      it "notifies the user that the image was saved" do
        set_logged_in_admin
        patch :update, params: { id: image.id, image: valid_attributes }
        expect( request.flash[:notice] ).to eq 'The image has been saved.'
      end
      it "redirects to the image" do
        set_logged_in_admin
        patch :update, params: { id: image.id, image: valid_attributes }
        expect( response ).to redirect_to(image)
      end
    end

    describe "with invalid params" do
      it "assigns the image as @image" do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Image).to receive(:save).and_return(false)
        patch :update, params: { id: image.id, image: {} }
        expect( assigns(:image) ).to eq(image)
      end
      it "re-renders the 'edit' template" do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Image).to receive(:save).and_return(false)
        patch :update, params: { id: image.id, image: {} }
        expect( response ).to render_template("edit")
      end
    end
  end

  describe "GET delete" do
    it "requires the user to have authority" do
      set_logged_in_user
      get :delete, params: { id: image.id }
      expect( response.status ).to eq 403
    end

    it "shows a form for confirming deletion of an image" do
      set_logged_in_admin
      get :delete, params: { id: image.id }
      expect( assigns(:image) ).to eq image
    end
  end

  describe "DELETE destroy" do
    it "requires the user to have authority" do
      set_logged_in_user
      delete :destroy, params: { id: image.id }
      expect( response.status ).to eq 403
    end
    it "destroys the requested image" do
      set_logged_in_admin
      image
      expect {
        delete :destroy, params: { id: image.id }
      }.to change(Image, :count).by(-1)
    end
    it "redirects to the images list" do
      set_logged_in_admin
      delete :destroy, params: { id: image.id }
      expect( response ).to redirect_to(images_url)
    end
  end

end
