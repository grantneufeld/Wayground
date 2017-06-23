require 'rails_helper'

describe 'projects/show', type: :view do
  before(:each) do
    @project = assign(
      :project,
      stub_model(
        Project,
        parent: stub_model(Project, name: 'Parent Project'),
        creator: stub_model(User, name: 'User Who Created'),
        owner: stub_model(User, name: 'User Who Owns'),
        is_visible: false, is_public_content: false, is_visible_member_list: false,
        is_joinable: false, is_members_can_invite: false, is_not_unsubscribable: false,
        is_moderated: false, is_only_admin_posts: false, is_no_comments: false,
        filename: 'view_spec_filename', name: 'View Spec Name', description: 'View Spec Description'
      )
    )
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Parent Project/)
    expect(rendered).to match(/User Who Created/)
    expect(rendered).to match(/User Who Owns/)
    expect(rendered).to match(/view_spec_filename/)
    expect(rendered).to match(/View Spec Name/)
    expect(rendered).to match(/View Spec Description/)
  end
end
