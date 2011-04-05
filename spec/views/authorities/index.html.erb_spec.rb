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
      :can_edit => false,
      :can_delete => false,
      :can_invite => false,
      :can_permit => false
      ),
      stub_model(Authority,
      :user => nil,
      :item => nil,
      :area => "Area",
      :is_owner => false,
      :can_create => false,
      :can_view => false,
      :can_edit => false,
      :can_delete => false,
      :can_invite => false,
      :can_permit => false
      )
      ])
    end

    it "renders a list of authorities" do
      render
      ## Run the generator again with the --webrat flag if you want to use webrat matchers
      #assert_select "tr>td", :text => nil.to_s, :count => 2
      ## Run the generator again with the --webrat flag if you want to use webrat matchers
      #assert_select "tr>td", :text => nil.to_s, :count => 2
      # Run the generator again with the --webrat flag if you want to use webrat matchers
      assert_select "tr>td", :text => "Area".to_s, :count => 2
      ## Run the generator again with the --webrat flag if you want to use webrat matchers
      #assert_select "tr>td", :text => false.to_s, :count => 2
      ## Run the generator again with the --webrat flag if you want to use webrat matchers
      #assert_select "tr>td", :text => false.to_s, :count => 2
      ## Run the generator again with the --webrat flag if you want to use webrat matchers
      #assert_select "tr>td", :text => false.to_s, :count => 2
      ## Run the generator again with the --webrat flag if you want to use webrat matchers
      #assert_select "tr>td", :text => false.to_s, :count => 2
      ## Run the generator again with the --webrat flag if you want to use webrat matchers
      #assert_select "tr>td", :text => false.to_s, :count => 2
      ## Run the generator again with the --webrat flag if you want to use webrat matchers
      #assert_select "tr>td", :text => false.to_s, :count => 2
      ## Run the generator again with the --webrat flag if you want to use webrat matchers
      #assert_select "tr>td", :text => false.to_s, :count => 2
    end
  end
