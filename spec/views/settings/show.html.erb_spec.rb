require 'rails_helper'

describe 'settings/show', type: :view do
  before(:each) do
    @setting = assign(:setting, stub_model(Setting, key: 'Key', value: 'MyText'))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Key/)
    expect(rendered).to match(/MyText/)
  end
end
