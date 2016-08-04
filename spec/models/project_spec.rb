require 'rails_helper'

describe Project, type: :model do
  let(:minimum_valid_params) { $minimum_valid_params = {
      :name => 'Project Name'
  } }


  before(:all) do
    Authority.delete_all
    User.delete_all
    # first user is automatically an admin
    @user_admin = FactoryGirl.create(:user, :name => 'Admin User')
    @user_normal = FactoryGirl.create(:user, :name => 'Normal User')
  end

  describe "acts_as_authority_controlled" do
    it "should be in the “Projects” area" do
      expect(Project.authority_area).to eq 'Projects'
    end
  end

  describe "validation" do
    describe "of creator" do
      it "should fail if no creator" do
        project = Project.new(minimum_valid_params)
        project.owner = @user_admin
        expect(project.valid?).to be_falsey
      end
    end
    describe "of owner" do
      it "should fail if no owner" do
        project = Project.new(minimum_valid_params)
        project.creator = @user_admin
        expect(project.valid?).to be_falsey
      end
    end
    describe "of name" do
      it "should fail if no name" do
        minimum_valid_params.delete(:name)
        project = Project.new(minimum_valid_params)
        project.creator = project.owner = @user_admin
        expect(project.valid?).to be_falsey
      end
    end
    describe "of filename" do
      it "should allow a blank filename" do
        minimum_valid_params.delete(:filename)
        project = Project.new(minimum_valid_params)
        project.creator = project.owner = @user_admin
        expect(project.valid?).to be_truthy
      end
      it "should not allow slashes in the filename" do
        project = Project.new(minimum_valid_params.merge(:filename => '/invalidfilename'))
        project.creator = project.owner = @user_admin
        expect(project.valid?).to be_falsey
      end
      it "should not allow periods in the filename" do
        project = Project.new(minimum_valid_params.merge(:filename => 'file.name'))
        project.creator = project.owner = @user_admin
        expect(project.valid?).to be_falsey
      end
      it "should not allow high-byte characters in the filename" do
        project = Project.new(minimum_valid_params.merge(:filename => 'ƒilename'))
        project.creator = project.owner = @user_admin
        expect(project.valid?).to be_falsey
      end
      it "should not allow ampersands in the filename" do
        project = Project.new(minimum_valid_params.merge(:filename => 'file&name'))
        project.creator = project.owner = @user_admin
        expect(project.valid?).to be_falsey
      end
      it "should not allow spaces in the filename" do
        project = Project.new(minimum_valid_params.merge(:filename => 'file name'))
        project.creator = project.owner = @user_admin
        expect(project.valid?).to be_falsey
      end
      it "should not allow the filename to exceed 127 characters" do
        project = Project.new(minimum_valid_params.merge(:filename => 'a' * 128))
        project.creator = project.owner = @user_admin
        expect(project.valid?).to be_falsey
      end
      it "should allow the filename to reach 127 characters" do
        project = Project.new(minimum_valid_params.merge(:filename => 'a' * 127))
        project.creator = project.owner = @user_admin
        expect(project.valid?).to be_truthy
      end
      it "should not allow duplicate filenames" do
        filename = 'no_duplicate'
        FactoryGirl.create(:project, :filename => filename)
        project = Project.new(minimum_valid_params.merge(:filename => filename))
        project.creator = project.owner = @user_admin
        expect(project.valid?).to be_falsey
      end
      it "should allow letters, numbers, dashes, and underscores in the filename" do
        project = Project.new(minimum_valid_params.merge(filename: 'abcdefghijklmnopqrstuvwxyz_0123456789-'))
        project.creator = project.owner = @user_admin
        expect(project.valid?).to be_truthy
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
        expect(Project.all).to eq [project1, project2, project3, project4]
      end
    end
  end

end
