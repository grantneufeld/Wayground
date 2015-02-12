require "spec_helper"

describe DocumentsController, type: :routing do
  describe "routing" do

    it "routes to #download" do
      expect(get('/download/1/filename.txt')).to route_to(
        'documents#download', id: '1', filename: 'filename', format: 'txt'
      )
    end

    it "routes to #index" do
      get("/documents").should route_to("documents#index")
    end
    it "routes to #show" do
      get("/documents/1").should route_to("documents#show", :id => "1")
    end

    it "routes to #new" do
      get("/documents/new").should route_to("documents#new")
    end
    it "routes to #create" do
      post("/documents").should route_to("documents#create")
    end

    it "routes to #edit" do
      get("/documents/1/edit").should route_to("documents#edit", :id => "1")
    end
    it "routes to #update" do
      expect( patch: '/documents/1' ).to route_to('documents#update', id: '1')
    end

    it "routes to #delete" do
      get("/documents/1/delete").should route_to("documents#delete", :id => "1")
    end
    it "routes to #destroy via delete" do
      delete("/documents/1/delete").should route_to("documents#destroy", :id => "1")
    end
    it "routes to #destroy" do
      delete("/documents/1").should route_to("documents#destroy", :id => "1")
    end

  end
end
