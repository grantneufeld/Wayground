require 'spec_helper'

describe 'settings/show', type: :view do
  before(:each) do
    @setting = assign(:setting, stub_model(Setting,
      :key => "Key",
      :value => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    rendered.should match(/Key/)
    rendered.should match(/MyText/)
  end
end
