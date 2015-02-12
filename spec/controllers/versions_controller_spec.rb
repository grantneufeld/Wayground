require 'spec_helper'

describe VersionsController, type: :controller do

  before(:all) do
    Version.delete_all
    Page.delete_all
    Path.delete_all
    Event.delete_all
    User.delete_all
    @user = FactoryGirl.create(:user)
    @page = FactoryGirl.create(:page, editor: @user)
    @version = @page.versions.first
    @event = FactoryGirl.create(:event, user: @user, editor: @user)
  end

  describe "GET index" do
    it "assigns all versions as @versions" do
      get :index, page_id: @page.id
      expect( assigns(:versions).to_a ).to eq(@version.item.versions.to_a)
    end
    it "restricts access for versions of items that require authorization to authorized users" do
      page = FactoryGirl.create(:page, is_authority_controlled: true)
      version = page.versions.first
      user = version.user
      FactoryGirl.create(:owner_authority, item: page, user: user)
      allow(controller).to receive(:current_user).and_return(user)
      get :index, page_id: page.id
      expect( assigns(:versions).to_a ).to eq(page.versions.to_a)
    end
    it "restricts access for versions of items that require authorization" do
      page = FactoryGirl.create(:page, is_authority_controlled: true)
      get :index, page_id: page.id
      expect( response.status ).to eq 403
    end
  end

  describe "GET show" do
    it "assigns the requested version as @version" do
      get :show, id: @version.id, page_id: @page.id
      expect( assigns(:version) ).to eq(@version)
    end
  end

  describe "#set_item" do
    it "should assign the page to @item when page_id is passed in" do
      get :show, id: @version.id, page_id: @page.id
      expect( assigns(:item) ).to eq(@page)
    end
    it "should assign the event to @item when event_id is passed in" do
      get :show, id: @version.id, event_id: @event.id
      expect( assigns(:item) ).to eq(@event)
    end
  end
end
