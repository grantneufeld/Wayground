require 'spec_helper'

describe ProjectsHelper do
  let(:project) { $project = FactoryGirl.create(:project, :filename => nil) }
  let(:named_project) { $named_project = FactoryGirl.create(:project, :filename => 'named') }
  describe ".project_smart_path" do
    it "should use the named path when the project has a filename" do
      helper.project_smart_path(named_project).should eq "/project/named"
    end
    it "should use the id path when the project doesn’t have a filename" do
      helper.project_smart_path(project).should eq "/projects/#{project.id}"
    end
  end
end
