require 'rails_helper'

describe 'sources/new.html.erb', type: :view do
  before(:each) do
    assign(:source, stub_model(Source,
      :processor => 'Mystring',
      :url => 'Mystring',
      :method => 'Mystring',
      :post_args => 'Mystring',
      :title => 'MyString',
      :description => 'MyString',
      :options => 'MyString'
    ).as_new_record)
  end

  it 'renders new source form' do
    render
    assert_select 'form', :action => sources_path, :method => 'post' do
      assert_select 'input#source_title', :name => 'source[title]'
      assert_select 'textarea#source_description', :name => 'source[description]'
      assert_select 'select#source_processor', :name => 'source[processor]'
      assert_select 'input#source_url', :name => 'source[url]'
      assert_select 'select#source_method', :name => 'source[method]'
      assert_select 'textarea#source_post_args', :name => 'source[post_args]'
      assert_select 'textarea#source_options', :name => 'source[options]'
      assert_select 'input#source_refresh_after_at', :name => 'source[refresh_after_at]'
    end
  end
end
