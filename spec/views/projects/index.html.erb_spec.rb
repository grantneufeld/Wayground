require 'rails_helper'

describe 'projects/index', type: :view do
  before(:each) do
    assign(
      :projects,
      [
        stub_model(
          Project,
          parent: nil,
          creator: nil,
          owner: nil,
          is_visible: false,
          is_public_content: false,
          is_visible_member_list: false,
          is_joinable: false,
          is_members_can_invite: false,
          is_not_unsubscribable: false,
          is_moderated: false,
          is_only_admin_posts: false,
          is_no_comments: false,
          filename: 'a_filename',
          name: 'A Name',
          description: 'A description'
        ),
        stub_model(
          Project,
          parent: nil,
          creator: nil,
          owner: nil,
          is_visible: false,
          is_public_content: false,
          is_visible_member_list: false,
          is_joinable: false,
          is_members_can_invite: false,
          is_not_unsubscribable: false,
          is_moderated: false,
          is_only_admin_posts: false,
          is_no_comments: false,
          filename: 'a_filename',
          name: 'A Name',
          description: 'A description'
        )
      ]
    )
  end

  it 'renders a list of projects' do
    render
    assert_select 'tr>td', text: 'a_filename'.to_s, count: 2
    assert_select 'tr>td', text: 'A Name'.to_s, count: 2
    assert_select 'tr>td', text: 'A description'.to_s, count: 2
  end
end
