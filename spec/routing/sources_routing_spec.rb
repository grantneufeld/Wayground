require "spec_helper"

describe SourcesController do
  describe "routing" do

    it "routes to #index" do
      get("/sources").should route_to("sources#index")
    end
    it "routes to #show" do
      get("/sources/1").should route_to("sources#show", :id => "1")
    end

    it "routes to #new" do
      get("/sources/new").should route_to("sources#new")
    end
    it "routes to #create" do
      post("/sources").should route_to("sources#create")
    end

    it "routes to #edit" do
      get("/sources/1/edit").should route_to("sources#edit", :id => "1")
    end
    it "routes to #update" do
      put("/sources/1").should route_to("sources#update", :id => "1")
    end

    it "routes to #delete" do
      get("/sources/1/delete").should route_to("sources#delete", :id => "1")
    end
    it "routes to #destroy via delete" do
      delete("/sources/1/delete").should route_to("sources#destroy", :id => "1")
    end
    it "routes to #destroy" do
      delete("/sources/1").should route_to("sources#destroy", :id => "1")
    end

    it "routes to #processor" do
      get("/sources/1/processor").should route_to("sources#processor", :id => "1")
    end
    it "routes to #runprocessor" do
      post("/sources/1/processor").should route_to("sources#runprocessor", :id => "1")
    end

  end
end
