require 'rails_helper'

describe EventsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get: "/events").to route_to("events#index")
    end
    it "routes to #show" do
      expect(get: "/events/1").to route_to("events#show", id: "1")
    end

    it "routes to #new" do
      expect(get: "/events/new").to route_to("events#new")
    end
    it "routes to #edit" do
      expect(get: "/events/1/edit").to route_to("events#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/events").to route_to("events#create")
    end
    it "routes to #update" do
      expect(patch: '/events/1').to route_to('events#update', id: '1')
    end
    it "routes to #update_tags" do
      expect(post: '/events/1/update_tags').to route_to('events#update_tags', id: '1')
    end

    it "routes to #delete" do
      expect(get: "/events/1/delete").to route_to("events#delete", id: "1")
    end
    it "routes to #destroy via delete" do
      expect(delete: "/events/1/delete").to route_to("events#destroy", id: "1")
    end
    it "routes to #destroy" do
      expect(delete: "/events/1").to route_to("events#destroy", id: "1")
    end

    it "routes to #approve" do
      expect(get: "/events/1/approve").to route_to("events#approve", id: "1")
    end
    it "routes to #set_approved" do
      expect(post: "/events/1/approve").to route_to("events#set_approved", id: "1")
    end

    it "routes to #merge" do
      expect(get: "/events/1/merge").to route_to("events#merge", id: "1")
    end
    it "routes to #perform_merge" do
      expect(post: "/events/1/merge").to route_to("events#perform_merge", id: "1")
    end

  end
end
