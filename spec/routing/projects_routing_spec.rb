require "spec_helper"

describe ProjectsController do
  describe "routing" do

    it "routes to #index" do
      get("/projects").should route_to("projects#index")
    end
    it "routes to #show" do
      get("/projects/1").should route_to("projects#show", :id => "1")
    end
    it "routes to #show with a projecturl" do
      get("/project/filename").should route_to("projects#show", :projecturl => "filename")
    end

    it "routes to #new" do
      get("/projects/new").should route_to("projects#new")
    end
    it "routes to #create" do
      post("/projects").should route_to("projects#create")
    end

    it "routes to #edit" do
      get("/projects/1/edit").should route_to("projects#edit", :id => "1")
    end
    it "routes to #update" do
      put("/projects/1").should route_to("projects#update", :id => "1")
    end

    it "routes to #delete" do
      get("/projects/1/delete").should route_to("projects#delete", :id => "1")
    end
    it "routes to #destroy via delete" do
      delete("/projects/1/delete").should route_to("projects#destroy", :id => "1")
    end
    it "routes to #destroy" do
      delete("/projects/1").should route_to("projects#destroy", :id => "1")
    end

    context "using filename" do
      it "routes to #show" do
        get("/project/name/subname").should route_to("projects#show", :projecturl => 'name/subname')
      end
    end

  end
end
