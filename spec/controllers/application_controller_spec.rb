require 'spec_helper'

describe ApplicationController do
  context "#current_user" do
    # use controller.send(:current_user) to access the protected method
    it "should return nil when user is not signed-in" do
      request.cookies['remember_token'] = nil
      controller.send(:current_user).should be_nil
    end
    it "should return the user when signed-in" do
      mock_user = mock_model(User, {:id => 123, :remember_token_hash => 'test/123', :matches_token_hash? => true})
      User.stub(:find).and_return(mock_user)
      request.cookies['remember_token'] = 'test/123'
      controller.send(:current_user).id.should eq 123
    end
    it "should clear the remember token cookie if user not found" do
      User.stub(:find).with(987).and_raise(ActiveRecord::RecordNotFound)
      request.cookies['remember_token'] = 'test/987'
      controller.send(:current_user).should be_nil
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
      user = FactoryGirl.create(:document).user
      11.times { FactoryGirl.create(:document, :user => user) }
      controller.send(:paginate, Document)
      assigns[:default_max].should eq 20
      assigns[:max].should eq 10
      assigns[:pagenum].should eq 2
      assigns[:source_total].should eq 12
      assigns[:selected_total].should eq 2
    end
  end
end
