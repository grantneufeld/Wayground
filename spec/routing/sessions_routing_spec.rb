require 'spec_helper'

describe SessionsController, type: :routing do
  describe "routing" do
    it "recognizes and generates #new" do
      { :get => "/signin" }.should route_to(:controller => "sessions", :action => "new")
    end
    it "recognizes and generates #create" do
      { :post => "/signin" }.should route_to(:controller => "sessions", :action => "create")
    end

    it "recognizes and generates #delete" do
      { :get => "/signout" }.should route_to(:controller => "sessions", :action => "delete")
    end
    it "recognizes and generates #destroy" do
      { :delete => "/signout" }.should route_to(:controller => "sessions", :action => "destroy")
    end
  end
end
