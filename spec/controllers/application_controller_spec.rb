require 'spec_helper'

describe ApplicationController do
	describe "current_user" do
		# use controller.send(:current_user) to access the protected method
		it "should return nil when user is not signed-in" do
			session[:user_id] = nil
			controller.send(:current_user).should be_nil
		end
		it "should return the user when signed-in" do
			mock_user = mock_model(User, {:id => 123})
			User.stub(:find).and_return(mock_user)
			session[:user_id] = 123
			controller.send(:current_user).id.should eq 123
		end
	end
end
