require 'spec_helper'

describe "authorities/index.html.erb" do
  before(:each) do
    assign(:authorities, [
      stub_model(Authority,
      :user => nil,
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
      ),
      stub_model(Authority,
      :user => nil,
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
      )
      ])
    end

    it "renders a list of authorities" do
      render
      #assert_select "tr>td", :text => nil.to_s, :count => 2
      #assert_select "tr>td", :text => nil.to_s, :count => 2
      assert_select "tr>td", :text => "Area".to_s, :count => 2
      #assert_select "tr>td", :text => false.to_s, :count => 2
      #assert_select "tr>td", :text => false.to_s, :count => 2
      #assert_select "tr>td", :text => false.to_s, :count => 2
      #assert_select "tr>td", :text => false.to_s, :count => 2
      #assert_select "tr>td", :text => false.to_s, :count => 2
      #assert_select "tr>td", :text => false.to_s, :count => 2
      #assert_select "tr>td", :text => false.to_s, :count => 2
    end
  end
