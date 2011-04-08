require 'spec_helper'

describe "authorities/edit.html.erb" do
  before(:each) do
    @authority = assign(:authority, stub_model(Authority,
    :user => nil,
    :item => nil,
    :area => "MyString",
    :is_owner => false,
    :can_create => false,
    :can_view => false,
    :can_edit => false,
    :can_delete => false,
    :can_invite => false,
    :can_permit => false
    ))
  end

  it "renders the edit authority form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => authorities_path(@authority), :method => "post" do
      assert_select "input#authority_user_proxy", :name => "authority[user_proxy]"
      assert_select "input#authority_item", :name => "authority[item]"
      assert_select "input#authority_area", :name => "authority[area]"
      assert_select "input#authority_is_owner", :name => "authority[is_owner]"
      assert_select "input#authority_can_create", :name => "authority[can_create]"
      assert_select "input#authority_can_view", :name => "authority[can_view]"
      assert_select "input#authority_can_edit", :name => "authority[can_edit]"
      assert_select "input#authority_can_delete", :name => "authority[can_delete]"
      assert_select "input#authority_can_invite", :name => "authority[can_invite]"
      assert_select "input#authority_can_permit", :name => "authority[can_permit]"
    end
  end
end
