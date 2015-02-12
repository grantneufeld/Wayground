require "spec_helper"

describe VersionsController, type: :routing do
  describe "routing" do
    describe "nested under pages" do
      it "recognizes and generates #index" do
        { :get => "/pages/1/versions" }.should route_to(
          :controller => "versions", :action => "index", :page_id => '1'
        )
      end
      it "recognizes and generates #show" do
        { :get => "/pages/1/versions/2" }.should route_to(
          :controller => "versions", :action => "show", :id => "2", :page_id => '1'
        )
      end
    end
    describe "nested under events" do
      it "recognizes and generates #index" do
        { :get => "/events/1/versions" }.should route_to(
          :controller => "versions", :action => "index", :event_id => '1'
        )
      end
      it "recognizes and generates #show" do
        { :get => "/events/1/versions/2" }.should route_to(
          :controller => "versions", :action => "show", :id => "2", :event_id => '1'
        )
      end
    end
  end
end
