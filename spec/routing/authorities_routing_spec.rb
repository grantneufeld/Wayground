require "spec_helper"

describe AuthoritiesController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/authorities" }.should route_to(:controller => "authorities", :action => "index")
    end
    it "recognizes and generates #show" do
      { :get => "/authorities/1" }.should route_to(:controller => "authorities", :action => "show", :id => "1")
    end

    it "recognizes and generates #new" do
      { :get => "/authorities/new" }.should route_to(:controller => "authorities", :action => "new")
    end
    it "recognizes and generates #create (post)" do
      { :post => "/authorities" }.should route_to(:controller => "authorities", :action => "create")
    end

    it "recognizes and generates #edit" do
      { :get => "/authorities/1/edit" }.should route_to(:controller => "authorities", :action => "edit", :id => "1")
    end
    it 'recognizes and generates #update (patch)' do
      expect( patch: '/authorities/1' ).to route_to(controller: 'authorities', action: 'update', id: '1')
    end

    it "recognizes and generates #delete" do
      { :get => "/authorities/1/delete" }.should route_to(:controller => "authorities", :action => "delete", :id => "1")
    end
    it "routes to #destroy via delete" do
      delete("/authorities/1/delete").should route_to("authorities#destroy", :id => "1")
    end
    it "recognizes and generates #destroy (delete)" do
      { :delete => "/authorities/1" }.should route_to(:controller => "authorities", :action => "destroy", :id => "1")
    end
  end
end
