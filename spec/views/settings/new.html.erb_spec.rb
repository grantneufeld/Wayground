require 'spec_helper'

describe "settings/new" do
  before(:each) do
    assign(:setting, stub_model(Setting,
      :key => "MyString",
      :value => "MyText"
    ).as_new_record)
  end

  it "renders new setting form" do
    render

    assert_select "form", :action => settings_path, :method => "post" do
      assert_select "input#setting_key", :name => "setting[key]"
      assert_select "textarea#setting_value", :name => "setting[value]"
    end
  end
end
