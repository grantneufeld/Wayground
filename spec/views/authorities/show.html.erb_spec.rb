require 'spec_helper'

describe "authorities/show.html.erb" do
  before(:each) do
    @authority = assign(:authority, stub_model(Authority,
    :user => stub_model(User, {:id => 123, :email => 'user@test.tld'}),
    :item => nil,
    :area => "Area",
    :is_owner => false,
    :can_create => false,
    :can_view => false,
    :can_edit => false,
    :can_delete => false,
    :can_invite => false,
    :can_permit => false
    ))
  end

  it "renders attributes in <p>" do
    render
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(/Area/)
    rendered.should match(/false/)
    rendered.should match(/false/)
    rendered.should match(/false/)
    rendered.should match(/false/)
    rendered.should match(/false/)
    rendered.should match(/false/)
    rendered.should match(/false/)
  end
end
