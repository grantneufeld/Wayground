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
		it "should clear the session user_id if user not found" do
		  session[:user_id] = 987
		  controller.send(:current_user).should eq nil
	  end
	end

  context "#missing" do
  end

  context "#unauthorized" do
  end

  context "#browser_dont_cache" do
    it "should set the @browser_nocache variable" do
      controller.send(:browser_dont_cache)
      assigns[:browser_nocache].should be_true
    end
  end

  context "#paginate" do
    it "should setup a bunch of variables" do
      controller.params ||= {}
      controller.params.merge!({:page => '2', :max => '10'})
      Document.delete_all
      user = Factory.create(:document).user
      11.times { Factory.create(:document, :user => user) }
      controller.send(:paginate, Document)
      assigns[:default_max].should eq 20
      assigns[:max].should eq 10
      assigns[:pagenum].should eq 2
      assigns[:source_total].should eq 12
      assigns[:selected_total].should eq 2
    end
  end
end
