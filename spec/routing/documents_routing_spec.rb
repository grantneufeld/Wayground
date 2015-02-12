require "spec_helper"

describe DocumentsController, type: :routing do
  describe "routing" do

    it "routes to #download" do
      expect(get: '/download/1/filename.txt').to route_to(
        'documents#download', id: '1', filename: 'filename', format: 'txt'
      )
    end

    it "routes to #index" do
      expect(get: "/documents").to route_to("documents#index")
    end
    it "routes to #show" do
      expect(get: "/documents/1").to route_to("documents#show", id: "1")
    end

    it "routes to #new" do
      expect(get: "/documents/new").to route_to("documents#new")
    end
    it "routes to #create" do
      expect(post: "/documents").to route_to("documents#create")
    end

    it "routes to #edit" do
      expect(get: "/documents/1/edit").to route_to("documents#edit", id: "1")
    end
    it "routes to #update" do
      expect(patch: '/documents/1').to route_to('documents#update', id: '1')
    end

    it "routes to #delete" do
      expect(get: "/documents/1/delete").to route_to("documents#delete", id: "1")
    end
    it "routes to #destroy via delete" do
      expect(delete: "/documents/1/delete").to route_to("documents#destroy", id: "1")
    end
    it "routes to #destroy" do
      expect(delete: "/documents/1").to route_to("documents#destroy", id: "1")
    end

  end
end
