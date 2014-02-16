require "spec_helper"

describe ExternalLinksController do
  describe "routing" do
    describe "nested under events" do
      it "recognizes and generates #index" do
        { get: "/events/1/external_links" }.should route_to(
          controller: "external_links", action: "index", event_id: '1'
        )
      end
      it "routes to #index" do
        expect(get("/events/1/external_links")).to route_to("external_links#index", event_id: '1')
      end
      it "routes to #show" do
        expect(get("/events/1/external_links/2")).to route_to("external_links#show", id: "2", event_id: '1')
      end

      it "routes to #new" do
        expect(get("/events/1/external_links/new")).to route_to("external_links#new", event_id: '1')
      end
      it "routes to #create" do
        expect(post("/events/1/external_links")).to route_to("external_links#create", event_id: '1')
      end

      it "routes to #edit" do
        expect(get("/events/1/external_links/2/edit")).to route_to(
          "external_links#edit", id: "2", event_id: '1'
        )
      end
      it "routes to #update" do
        expect( patch: '/events/1/external_links/2' ).to route_to(
          'external_links#update', id: '2', event_id: '1'
        )
      end

      it "routes to #delete" do
        expect(get("/events/1/external_links/2/delete")).to route_to(
          "external_links#delete", id: "2", event_id: '1'
        )
      end
      it "routes to #destroy via delete" do
        expect(delete("/events/1/external_links/2/delete")).to route_to(
          "external_links#destroy", id: "2", event_id: '1'
        )
      end
      it "routes to #destroy" do
        expect(delete("/events/1/external_links/2")).to route_to(
          "external_links#destroy", id: "2", event_id: '1'
        )
      end
    end
  end
end
