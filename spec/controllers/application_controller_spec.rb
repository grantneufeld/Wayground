require 'spec_helper'
require 'application_controller'
require 'user'
require 'user_token'
require 'document'
require 'active_record'

describe ApplicationController, type: :controller do

  describe '#current_user' do
    # use controller.send(:current_user) to access the protected method
    it "should return nil when user is not signed-in" do
      request.cookies['remember_token'] = nil
      expect(controller.send(:current_user)).to be_nil
    end
    it "should return the user when signed-in" do
      user = User.new
      user_token = UserToken.new
      user_token.user = user
      allow(UserToken).to receive(:from_cookie_token).with('test/123').and_return(user_token)
      request.cookies['remember_token'] = 'test/123'
      expect( controller.send(:current_user) ).to be user
    end
    it "should clear the remember token cookie if user not found" do
      allow(User).to receive(:find).with(987).and_raise(ActiveRecord::RecordNotFound)
      request.cookies['remember_token'] = 'test/987'
      expect(controller.send(:current_user)).to be_nil
    end
  end

  describe '#missing' do
  end

  describe '#unauthorized' do
  end

  describe '#login_requried' do
  end

  describe '#page_metadata' do
  end

  describe '#add_submenu_item' do
    before(:each) do
      reset_submenu_items(controller)
    end
    it 'should add the given item to the submenu items' do
      item = { title: 'Test Submenu Item', path: 'submenu', attrs: { submenu: 'test' } }
      controller.send(:add_submenu_item, item)
      expect( controller.send(:page_submenu_items) ).to eq [item]
    end
  end

  describe '#page_submenu_items' do
    before(:each) do
      reset_submenu_items(controller)
    end
    it 'should default to an empty array' do
      expect( controller.send(:page_submenu_items) ).to eq []
    end
    it 'should return an array of the submenu items that have been added' do
      item1 = { title: 'One', path: '1', attrs: { test: 'one' } }
      item2 = { title: 'Two', path: '2', attrs: { other: 'two' } }
      controller.send(:add_submenu_item, item1)
      controller.send(:add_submenu_item, item2)
      expect( controller.send(:page_submenu_items) ).to eq [item1, item2]
    end
  end

  describe '#cookie_set_remember_me' do
  end

  describe '#cookie_set_remember_me_permanent' do
  end

  describe '#paginate' do
    it "should setup a bunch of variables" do
      controller.params ||= {}
      controller.params.merge!({:page => '2', :max => '10'})
      Document.delete_all
      user = FactoryGirl.create(:document).user
      11.times { FactoryGirl.create(:document, :user => user) }
      controller.send(:paginate, Document)
      expect(assigns[:default_max]).to eq 20
      expect(assigns[:max]).to eq 10
      expect(assigns[:pagenum]).to eq 2
      expect(assigns[:source_total]).to eq 12
      expect(assigns[:selected_total]).to eq 2
    end
  end

end


# HELPERS

def reset_submenu_items(controller)
  if controller.instance_variable_defined?('@page_submenu_items')
    controller.instance_variable_set('@page_submenu_items', nil)
  end
end
