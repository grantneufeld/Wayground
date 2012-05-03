require 'spec_helper'

describe "projects/edit" do
  before(:each) do
    @project = assign(:project, stub_model(Project,
      :parent => nil,
      :creator => nil,
      :owner => nil,
      :is_visible => false,
      :is_public_content => false,
      :is_visible_member_list => false,
      :is_joinable => false,
      :is_members_can_invite => false,
      :is_not_unsubscribable => false,
      :is_moderated => false,
      :is_only_admin_posts => false,
      :is_no_comments => false,
      :filename => "MyString",
      :name => "MyString",
      :description => "MyText"
    ))
  end

  it "renders the edit project form" do
    render

    assert_select "form", :action => projects_path(@project), :method => "post" do
      assert_select "input#project_name", :name => "project[name]"
      assert_select "input#project_filename", :name => "project[filename]"
      assert_select "textarea#project_description", :name => "project[description]"
      assert_select "input#project_is_visible", :name => "project[is_visible]"
      assert_select "input#project_is_public_content", :name => "project[is_public_content]"
      assert_select "input#project_is_visible_member_list", :name => "project[is_visible_member_list]"
      assert_select "input#project_is_joinable", :name => "project[is_joinable]"
      assert_select "input#project_is_members_can_invite", :name => "project[is_members_can_invite]"
      assert_select "input#project_is_not_unsubscribable", :name => "project[is_not_unsubscribable]"
      assert_select "input#project_is_moderated", :name => "project[is_moderated]"
      assert_select "input#project_is_only_admin_posts", :name => "project[is_only_admin_posts]"
      assert_select "input#project_is_no_comments", :name => "project[is_no_comments]"
    end
  end
end
