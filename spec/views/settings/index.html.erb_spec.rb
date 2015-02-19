require 'rails_helper'

describe 'settings/index', type: :view do
  before(:each) do
    assign(:settings, [
      stub_model(Setting,
        :key => "Key",
        :value => "MyText"
      ),
      stub_model(Setting,
        :key => "Key",
        :value => "MyText"
      )
    ])
  end

  it "renders a list of settings" do
    render
    assert_select "tr>th", :text => "Key:".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
