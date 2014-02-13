require "spec_helper"

describe ExternalLinksController do
  describe "routing" do
    describe "nested under events" do
      it "recognizes and generates #index" do
        { :get => "/events/1/external_links" }.should route_to(
          :controller => "external_links", :action => "index", :event_id => '1'
        )
      end
      it "routes to #index" do
        get("/events/1/external_links").should route_to("external_links#index", :event_id => '1')
      end
      it "routes to #show" do
        get("/events/1/external_links/2").should route_to("external_links#show", :id => "2", :event_id => '1')
      end

      it "routes to #new" do
        get("/events/1/external_links/new").should route_to("external_links#new", :event_id => '1')
      end
      it "routes to #create" do
        post("/events/1/external_links").should route_to("external_links#create", :event_id => '1')
      end

      it "routes to #edit" do
        get("/events/1/external_links/2/edit").should route_to("external_links#edit", :id => "2", :event_id => '1')
      end
      it "routes to #update" do
        expect( patch: '/events/1/external_links/2' ).to route_to('external_links#update', id: '2', event_id: '1')
      end

      it "routes to #delete" do
        get("/events/1/external_links/2/delete").should route_to("external_links#delete", :id => "2", :event_id => '1')
      end
      it "routes to #destroy via delete" do
        delete("/events/1/external_links/2/delete").should route_to("external_links#destroy", :id => "2", :event_id => '1')
      end
      it "routes to #destroy" do
        delete("/events/1/external_links/2").should route_to("external_links#destroy", :id => "2", :event_id => '1')
      end
    end

    describe 'nested under candidates' do
      it 'routes to #index' do
        get('/levels/1/elections/2/ballots/3/candidates/4/external_links').should route_to(
          'external_links#index', level_id: '1', election_id: '2', ballot_id: '3', candidate_id: '4'
        )
      end
      it 'routes to #show' do
        get('/levels/1/elections/2/ballots/3/candidates/4/external_links/5').should route_to(
          'external_links#show', id: '5', level_id: '1', election_id: '2', ballot_id: '3', candidate_id: '4'
        )
      end

      it 'routes to #new' do
        get('/levels/1/elections/2/ballots/3/candidates/4/external_links/new').should route_to(
          'external_links#new', level_id: '1', election_id: '2', ballot_id: '3', candidate_id: '4'
        )
      end
      it 'routes to #create' do
        post('/levels/1/elections/2/ballots/3/candidates/4/external_links').should route_to(
          'external_links#create', level_id: '1', election_id: '2', ballot_id: '3', candidate_id: '4'
        )
      end

      it 'routes to #edit' do
        get('/levels/1/elections/2/ballots/3/candidates/4/external_links/5/edit').should route_to(
          'external_links#edit', id: '5', level_id: '1', election_id: '2', ballot_id: '3', candidate_id: '4'
        )
      end
      it 'routes to #update' do
        expect( patch: '/levels/1/elections/2/ballots/3/candidates/4/external_links/5' ).to route_to(
          'external_links#update', id: '5', level_id: '1', election_id: '2', ballot_id: '3', candidate_id: '4'
        )
      end

      it 'routes to #delete' do
        get('/levels/1/elections/2/ballots/3/candidates/4/external_links/5/delete').should route_to(
          'external_links#delete', id: '5', level_id: '1', election_id: '2', ballot_id: '3', candidate_id: '4'
        )
      end
      it 'routes to #destroy via delete' do
        delete('/levels/1/elections/2/ballots/3/candidates/4/external_links/5/delete').should route_to(
          'external_links#destroy', id: '5', level_id: '1', election_id: '2', ballot_id: '3', candidate_id: '4'
        )
      end
      it 'routes to #destroy' do
        delete('/levels/1/elections/2/ballots/3/candidates/4/external_links/5').should route_to(
          'external_links#destroy', id: '5', level_id: '1', election_id: '2', ballot_id: '3', candidate_id: '4'
        )
      end
    end

    describe 'nested under ballots' do
    end

    describe 'nested under offices' do
    end

  end
end
