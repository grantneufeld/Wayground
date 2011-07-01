# encoding: utf-8
require 'spec_helper'

describe VersionsController do

  before(:all) do
    Page.delete_all
    Path.delete_all
    Version.delete_all
    @page = Factory.create(:page)
    @version = @page.versions.first
  end

  describe "GET index" do
    it "assigns all versions as @versions" do
      get :index, :page_id => @page.id
      assigns(:versions).should eq(@version.item.versions)
    end
    it "restricts access for versions of items that require authorization to authorized users" do
      page = Factory.create(:page, :is_authority_controlled => true)
      version = page.versions.first
      user = version.user
      Factory.create(:owner_authority, :item => page, :user => user)
  		controller.stub!(:current_user).and_return(user)
      get :index, :page_id => page.id
      assigns(:versions).should eq(page.versions)
    end
    it "restricts access for versions of items that require authorization" do
      page = Factory.create(:page, :is_authority_controlled => true)
      get :index, :page_id => page.id
			response.status.should eq 403
    end
  end

  describe "GET show" do
    it "assigns the requested version as @version" do
      get :show, :id => @version.id, :page_id => @page.id
      assigns(:version).should eq(@version)
    end
  end

end
