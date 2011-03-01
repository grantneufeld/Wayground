require 'spec_helper'

describe UsersController do
	describe "routing" do
		it "recognizes and generates #new" do
			{ :get => "/sign_up" }.should route_to(:controller => "users", :action => "new")
		end

		it "recognizes and generates #create" do
			{ :post => "/sign_up" }.should route_to(:controller => "users", :action => "create") 
		end

		it "recognizes and generates #confirm" do
			{ :get => "/account/confirm/1234" }.should route_to(:controller => "users", :action => "confirm",
				:confirmation_code => '1234'
			)
		end

		it "recognizes and generates #show" do
			{ :get => "/account" }.should route_to(:controller => "users", :action => "show")
		end

		it "recognizes and generates #edit" do
			{ :get => "/account/edit" }.should route_to(:controller => "users", :action => "edit")
		end

		it "recognizes and generates #update" do
			{ :put => "/account" }.should route_to(:controller => "users", :action => "update") 
		end
	end
end
