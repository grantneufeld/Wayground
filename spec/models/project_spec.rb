require 'spec_helper'

describe Project do
  let(:minimum_valid_params) { $minimum_valid_params = {
      :name => 'Project Name'
  } }


  before(:all) do
    Authority.delete_all
    User.destroy_all
    # first user is automatically an admin
    @user_admin = FactoryGirl.create(:user, :name => 'Admin User')
    @user_normal = FactoryGirl.create(:user, :name => 'Normal User')
  end

  describe "acts_as_authority_controlled" do
    it "should be in the “Projects” area" do
      Project.authority_area.should eq 'Projects'
    end
  end

  describe "attr_accessible" do
    it 'should not allow creator to be set' do
      expect {
        project = Project.new(:creator => @user_normal)
      }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should not allow creator_id to be set" do
      expect {
        project = Project.new(:creator_id => @user_normal.id)
      }.to raise_error ActiveModel::MassAssignmentSecurity::Error
    end
    it "should allow is_visible to be set" do
      project = Project.new(:is_visible => true)
      project.is_visible?.should be_true
    end
    it "should allow is_public_content to be set" do
      project = Project.new(:is_public_content => true)
      project.is_public_content?.should be_true
    end
    it "should allow is_visible_member_list to be set" do
      project = Project.new(:is_visible_member_list => true)
      project.is_visible_member_list?.should be_true
    end
    it "should allow is_joinable to be set" do
      project = Project.new(:is_joinable => true)
      project.is_joinable?.should be_true
    end
    it "should allow is_members_can_invite to be set" do
      project = Project.new(:is_members_can_invite => true)
      project.is_members_can_invite?.should be_true
    end
    it "should allow is_not_unsubscribable to be set" do
      project = Project.new(:is_not_unsubscribable => true)
      project.is_not_unsubscribable?.should be_true
    end
    it "should allow is_moderated to be set" do
      project = Project.new(:is_moderated => true)
      project.is_moderated?.should be_true
    end
    it "should allow is_only_admin_posts to be set" do
      project = Project.new(:is_only_admin_posts => true)
      project.is_only_admin_posts?.should be_true
    end
    it "should allow is_no_comments to be set" do
      project = Project.new(:is_no_comments => true)
      project.is_no_comments?.should be_true
    end
    it "should allow name to be set" do
      project = Project.new(:name => 'Can Set Name')
      project.name.should eq 'Can Set Name'
    end
    it "should allow filename to be set" do
      project = Project.new(:filename => 'can_set_filename')
      project.filename.should eq 'can_set_filename'
    end
    it "should allow description to be set" do
      project = Project.new(:description => 'Can set description.')
      project.description.should eq 'Can set description.'
    end
  end

  describe "validation" do
    describe "of creator" do
      it "should fail if no creator" do
        project = Project.new(minimum_valid_params)
        project.owner = @user_admin
        project.valid?.should be_false
      end
    end
    describe "of owner" do
      it "should fail if no owner" do
        project = Project.new(minimum_valid_params)
        project.creator = @user_admin
        project.valid?.should be_false
      end
    end
    describe "of name" do
      it "should fail if no name" do
        minimum_valid_params.delete(:name)
        project = Project.new(minimum_valid_params)
        project.creator = project.owner = @user_admin
        project.valid?.should be_false
      end
    end
    describe "of filename" do
      it "should allow a blank filename" do
        minimum_valid_params.delete(:filename)
        project = Project.new(minimum_valid_params)
        project.creator = project.owner = @user_admin
        project.valid?.should be_true
      end
      it "should not allow slashes in the filename" do
        project = Project.new(minimum_valid_params.merge(:filename => '/invalidfilename'))
        project.creator = project.owner = @user_admin
        project.valid?.should be_false
      end
      it "should not allow periods in the filename" do
        project = Project.new(minimum_valid_params.merge(:filename => 'file.name'))
        project.creator = project.owner = @user_admin
        project.valid?.should be_false
      end
      it "should not allow high-byte characters in the filename" do
        project = Project.new(minimum_valid_params.merge(:filename => 'ƒilename'))
        project.creator = project.owner = @user_admin
        project.valid?.should be_false
      end
      it "should not allow ampersands in the filename" do
        project = Project.new(minimum_valid_params.merge(:filename => 'file&name'))
        project.creator = project.owner = @user_admin
        project.valid?.should be_false
      end
      it "should not allow spaces in the filename" do
        project = Project.new(minimum_valid_params.merge(:filename => 'file name'))
        project.creator = project.owner = @user_admin
        project.valid?.should be_false
      end
      it "should not allow the filename to exceed 127 characters" do
        project = Project.new(minimum_valid_params.merge(:filename => 'a' * 128))
        project.creator = project.owner = @user_admin
        project.valid?.should be_false
      end
      it "should allow the filename to reach 127 characters" do
        project = Project.new(minimum_valid_params.merge(:filename => 'a' * 127))
        project.creator = project.owner = @user_admin
        project.valid?.should be_true
      end
      it "should not allow duplicate filenames" do
        filename = 'no_duplicate'
        FactoryGirl.create(:project, :filename => filename)
        project = Project.new(minimum_valid_params.merge(:filename => filename))
        project.creator = project.owner = @user_admin
        project.valid?.should be_false
      end
      it "should allow letters, numbers, dashes, and underscores in the filename" do
        project = Project.new(minimum_valid_params.merge(filename: 'abcdefghijklmnopqrstuvwxyz_0123456789-'))
        project.creator = project.owner = @user_admin
        project.valid?.should be_true
      end
    end
  end

  describe "scopes" do
    describe "default_scope" do
      it "should order by name by default" do
        Project.delete_all
        project3 = FactoryGirl.create(:project, :name => 'Dog')
        project1 = FactoryGirl.create(:project, :name => 'Aardvark')
        project4 = FactoryGirl.create(:project, :name => 'Rabbit')
        project2 = FactoryGirl.create(:project, :name => 'Cat')
        Project.all.should eq [project1, project2, project3, project4]
      end
    end
  end

end
