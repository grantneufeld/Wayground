require 'spec_helper'

describe 'authorities/show.html.erb', type: :view do
  before(:each) do
    @authority = assign(:authority, stub_model(Authority,
    :user => stub_model(User, {:id => 123, :email => 'user@test.tld'}),
    :item => nil,
    :area => "Area",
    :is_owner => false,
    :can_create => false,
    :can_view => false,
    :can_update => false,
    :can_delete => false,
    :can_invite => false,
    :can_permit => false,
    :can_approve => false
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/Area/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
  end
end
