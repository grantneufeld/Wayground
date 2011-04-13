require "spec_helper"

describe PathsController do
  describe "routing" do

    it "handles the root url" do
      { :get => '/' }.should route_to(:controller => 'paths', :action => 'sitepath', :url => '/')
    end
    it "recognizes custom paths" do
      { :get => '/custom/path' }.should route_to(:controller => 'paths', :action => 'sitepath', :url => 'custom/path')
    end

    it "recognizes and generates #index" do
      { :get => "/paths" }.should route_to(:controller => "paths", :action => "index")
    end
    it "recognizes and generates #show" do
      { :get => "/paths/1" }.should route_to(:controller => "paths", :action => "show", :id => "1")
    end

    it "recognizes and generates #new" do
      { :get => "/paths/new" }.should route_to(:controller => "paths", :action => "new")
    end
    it "recognizes and generates #create" do
      { :post => "/paths" }.should route_to(:controller => "paths", :action => "create")
    end

    it "recognizes and generates #edit" do
      { :get => "/paths/1/edit" }.should route_to(:controller => "paths", :action => "edit", :id => "1")
    end
    it "recognizes and generates #update" do
      { :put => "/paths/1" }.should route_to(:controller => "paths", :action => "update", :id => "1")
    end

    it "recognizes and generates #delete" do
      { :get => "/paths/1/delete" }.should route_to(:controller => "paths", :action => "delete", :id => "1")
    end
    it "recognizes and generates #destroy" do
      { :delete => "/paths/1" }.should route_to(:controller => "paths", :action => "destroy", :id => "1")
    end

  end
end
