require "spec_helper"

describe PagesController, type: :routing do
  describe "routing" do

    it "recognizes and generates #index" do
      expect(get: "/pages").to route_to(controller: "pages", action: "index")
    end
    it "recognizes and generates #show" do
      expect(get: "/pages/1").to route_to(controller: "pages", action: "show", id: "1")
    end

    it "recognizes and generates #new" do
      expect(get: "/pages/new").to route_to(controller: "pages", action: "new")
    end
    it "recognizes and generates #create" do
      expect(post: "/pages").to route_to(controller: "pages", action: "create")
    end

    it "recognizes and generates #edit" do
      expect(get: "/pages/1/edit").to route_to(controller: "pages", action: "edit", id: "1")
    end
    it "recognizes and generates #update" do
      expect(patch: '/pages/1').to route_to(controller: 'pages', action: 'update', id: '1')
    end

    it "recognizes and generates #delete" do
      expect(get: "/pages/1/delete").to route_to(controller: "pages", action: "delete", id: "1")
    end
    it "routes to #destroy via delete" do
      expect(delete: "/pages/1/delete").to route_to("pages#destroy", id: "1")
    end
    it "recognizes and generates #destroy" do
      expect(delete: "/pages/1").to route_to(controller: "pages", action: "destroy", id: "1")
    end

  end
end
