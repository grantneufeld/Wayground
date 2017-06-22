require 'rails_helper'

describe 'settings/edit', type: :view do
  before(:each) do
    @setting = assign(:setting, stub_model(Setting, key: 'MyString', value: 'MyText'))
  end

  it 'renders the edit setting form' do
    render

    assert_select 'form', action: settings_path(@setting), method: 'post' do
      assert_select 'input#setting_key', name: 'setting[key]'
      assert_select 'textarea#setting_value', name: 'setting[value]'
    end
  end
end
