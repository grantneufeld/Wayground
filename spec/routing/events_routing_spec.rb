require "spec_helper"

describe EventsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      get("/events").should route_to("events#index")
    end
    it "routes to #show" do
      get("/events/1").should route_to("events#show", :id => "1")
    end

    it "routes to #new" do
      get("/events/new").should route_to("events#new")
    end
    it "routes to #edit" do
      get("/events/1/edit").should route_to("events#edit", :id => "1")
    end

    it "routes to #create" do
      post("/events").should route_to("events#create")
    end
    it "routes to #update" do
      expect( patch: '/events/1' ).to route_to('events#update', id: '1')
    end

    it "routes to #delete" do
      get("/events/1/delete").should route_to("events#delete", :id => "1")
    end
    it "routes to #destroy via delete" do
      delete("/events/1/delete").should route_to("events#destroy", :id => "1")
    end
    it "routes to #destroy" do
      delete("/events/1").should route_to("events#destroy", :id => "1")
    end

    it "routes to #approve" do
      get("/events/1/approve").should route_to("events#approve", :id => "1")
    end
    it "routes to #set_approved" do
      post("/events/1/approve").should route_to("events#set_approved", :id => "1")
    end

    it "routes to #merge" do
      get("/events/1/merge").should route_to("events#merge", :id => "1")
    end
    it "routes to #perform_merge" do
      post("/events/1/merge").should route_to("events#perform_merge", :id => "1")
    end

  end
end
