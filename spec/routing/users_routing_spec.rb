require 'spec_helper'

describe UsersController, type: :routing do
  describe "routing" do
    it "recognizes and generates #new" do
      expect(get: "/signup").to route_to(controller: "users", action: "new")
    end
    it "recognizes and generates #create" do
      expect(post: "/signup").to route_to(controller: "users", action: "create")
    end

    it "recognizes and generates #confirm" do
      expect(get: "/account/confirm/1234").to route_to(controller: "users", action: "confirm",
        confirmation_code: '1234'
      )
    end

    it "recognizes and generates #show" do
      expect(get: "/account").to route_to(controller: "users", action: "show")
    end

    it "recognizes and generates #edit" do
      expect(get: "/account/edit").to route_to(controller: "users", action: "edit")
    end
    it "recognizes and generates #update" do
      expect(patch: '/account').to route_to(controller: 'users', action: 'update')
    end
  end
end
