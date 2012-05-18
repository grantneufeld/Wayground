require 'spec_helper'

describe Source do
  before do
    Authority.delete_all
    User.destroy_all
    # first user is automatically an admin
    @user_admin = FactoryGirl.create(:user, :name => 'Admin User')
    @user_normal = FactoryGirl.create(:user, :name => 'Normal User')
  end

  describe "attr_accessible" do
    it "should not allow container to be set" do
      expect {
        Source.new(:container => Project.new)
      }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should not allow container_type to be set" do
      expect {
        Source.new(:container_type => 'Project')
      }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should not allow container_id to be set" do
      expect {
        Source.new(:container_id => '1')
      }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should not allow datastore to be set" do
      expect {
        Source.new(:datastore => Datastore.new)
      }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should not allow datastore_id to be set" do
      expect {
        Source.new(:datastore_id => '1')
      }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should not allow last_updated_at to be set" do
      expect {
        Source.new(:last_updated_at => '2012-01-02 03:04:05')
      }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should allow refresh_after_at to be set" do
      source = Source.new(:refresh_after_at => '2012-06-07 08:09:10')
      source.refresh_after_at?.should be_true
    end
    it "should allow processor to be set" do
      Source.new(:processor => 'Test').processor.should eq 'Test'
    end
    it "should allow url to be set" do
      Source.new(:url => 'Test').url.should eq 'Test'
    end
    it "should allow method to be set" do
      Source.new(:method => 'Test').method.should eq 'Test'
    end
    it "should allow post_args to be set" do
      Source.new(:post_args => 'Test').post_args.should eq 'Test'
    end
    it "should allow title to be set" do
      Source.new(:title => 'Test').title.should eq 'Test'
    end
    it "should allow description to be set" do
      Source.new(:description => 'Test').description.should eq 'Test'
    end
    it "should allow options to be set" do
      Source.new(:options => 'Test').options.should eq 'Test'
    end
  end

  describe "validation" do
    let(:minimum_valid_params) {
      $minimum_valid_params = { processor: 'IcalProcessor', url: 'http://test.tld/test.ics' }
    }
    it "should pass with minimum valid parameters" do
      Source.new(minimum_valid_params).valid?.should be_true
    end
    describe "of processor" do
      it "should fail if not set" do
        minimum_valid_params.delete :processor
        Source.new(minimum_valid_params).valid?.should be_false
      end
      it "should fail if set to an invalid value" do
        Source.new(minimum_valid_params.merge(processor: 'invalid')).valid?.should be_false
      end
      it "should pass if set to IcalProcessor" do
        source = Source.new(minimum_valid_params.merge( processor: 'IcalProcessor' ))
        source.valid?.should be_true
      end
    end
    describe "of url" do
      it "should fail if not set" do
        minimum_valid_params.delete :url
        Source.new(minimum_valid_params).valid?.should be_false
      end
      it "should fail if not a valid url format" do
        Source.new(minimum_valid_params.merge(url: 'invalid url')).valid?.should be_false
      end
    end
    describe "of method" do
      it "should default to get" do
        source = Source.new(minimum_valid_params)
        source.method.should eq 'get'
      end
      it "should fail if invalid" do
        source = Source.new(minimum_valid_params.merge( method: 'invalid' ))
        source.valid?.should be_false
      end
      it "should pass if set to get" do
        source = Source.new(minimum_valid_params.merge( method: 'get' ))
        source.valid?.should be_true
      end
      it "should pass if set to post" do
        source = Source.new(minimum_valid_params.merge( method: 'post' ))
        source.valid?.should be_true
      end
    end
    describe "of last_updated_at" do
      it "should fail if greater than the current time" do
        source = Source.new(minimum_valid_params)
        source.last_updated_at = 1.minute.from_now
        source.valid?.should be_false
      end
      it "should pass if equal to the current time" do
        source = Source.new(minimum_valid_params)
        source.last_updated_at = Time.now
        source.valid?.should be_true
      end
    end
  end

  describe "#name" do
    it "should return the title, if set" do
      Source.new(title: 'The Title').name.should eq 'The Title'
    end
    it "should return a Source & ID string if title is missing" do
      source = Source.new
      source.id = 123
      source.name.should eq 'Source 123'
    end
  end

  describe "#run_processor" do
    it "should do nothing when not a recognized processor" do
      Source.new.run_processor.should be_nil
    end
    context "with the IcalProcessor" do
      it "should run the process" do
        source = FactoryGirl.create(:source,
          processor: 'IcalProcessor', url: "#{Rails.root}/spec/fixtures/files/sample.ics"
        )
        expect { source.run_processor(@user_normal) }.to change(Event, :count).by(2)
      end
    end
  end

end
